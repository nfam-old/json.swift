//
//  JSON+parse.swift
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension JSON {
    public static func parse(bytes: UnsafePointer<UInt8>, count: Int) throws -> JSON {
        let parser = Parser(bytes: bytes, count: count)
        if let any = parser.parse() {
            return JSON(any)
        }
        throw parser.error!
    }

    public static func parse(bytes: [UInt8]) throws -> JSON {
        return try bytes.withUnsafeBufferPointer { bp in
            return try JSON.parse(bytes: bp.baseAddress!, count: bp.count)
        }
    }

    public static func parse(string: String) throws -> JSON {
        return try string.utf8CString.withUnsafeBytes { bp in
            return try JSON.parse(bytes: bp.baseAddress!.assumingMemoryBound(to: UInt8.self), count: bp.count - 1)
        }
    }
}

extension JSON {
    public struct ParsingError: Error, CustomStringConvertible, CustomDebugStringConvertible {
        public let description: String
        fileprivate init(description: String) {
            self.description = description
        }
        public var debugDescription: String {
            return description
        }
    }
}

private enum ParsingErrorType {
    case emptyDocument
    case unexpectedToken
    case unclosedArray
    case unclosedDictionary
    case unclosedString
    case invalidCharacter
    case unpairedSurrogate
    case numberSyntax
    case escapeSyntax
}

private class Parser {
    let bytes: UnsafePointer<UInt8>
    let count: Int
    var index: Int = 0

    var buffer: [UInt8] = []

    // From RFC 4627, 2.5. Strings:
    //
    // To escape an extended character that is not in the Basic Multilingual
    // Plane, the character is represented as a twelve-character sequence,
    // encoding the UTF-16 surrogate pair.  So, for example, a string
    // containing only the G clef character (U+1D11E) may be represented as
    // "\uD834\uDD1E".
    var highSurrogate: UInt? // UTF16 high surrogate
    var highSurrogateIndex = 0

    var error: JSON.ParsingError?
    var line = 0
    var lineStartOffset = 0

    init(bytes: UnsafePointer<UInt8>, count: Int) {
        self.bytes = bytes
        self.count = count
    }

    fileprivate func parse() -> Any? {
        guard index < count else {
            makeError(.emptyDocument)
            return nil
        }
        let any = parseValue()
        if any == nil {
            if error == nil {
                makeError(.emptyDocument)
                return nil
            }
        } else if index < count {
            skipWhitespaces()
            if index < count {
                makeError(.unexpectedToken)
                return nil
            }
        }
        return any
    }

    // value = false / null / true / object / array / number / string
    private func parseValue() -> Any? {
        let byte = bytes[index]
        if byte == 0x2D || (byte >= 0x30 && byte <= 0x39) { // -, 0..9
            return parseNumber()
        } else {
            switch byte {
            case 0x22: // \"
                return parseString()
            case 0x5B: // [
                return parseArray()
            case 0x7B: // {
                return parseDictionary()
            case 0x20, 0x09, 0x0A, 0x0D: // space \t \n \r
                skipWhitespaces()
                if index < count {
                    return parseValue()
                } else {
                    return nil
                }
            default:
                return parseName()
            }
        }
    }

    // array           = begin-array [ value *( value-separator value ) ] end-array
    // begin-array     = ws %x5B ws  ; [ left square bracket
    // end-array       = ws %x5D ws  ; ] right square bracket
    // value-separator = ws %x2C ws  ; , comma
    private func parseArray() -> Any? {
        var array = [JSON]()

        index += 1 // [
        while index < count {

            // ws
            skipWhitespaces()
            if index >= count { // unclosed ]
                makeError(.unclosedArray)
                return nil
            }

            // ]
            if bytes[index] == 0x5D {
                index += 1
                return array
            }

            // value
            guard let value = parseValue() else {
                makeError(.unclosedArray)
                return nil
            }
            array.append(JSON(value))

            // ws
            skipWhitespaces()
            if index >= count { // unclosed ]
                makeError(.unclosedArray)
                return nil
            }

            // , or ]
            let byte = bytes[index]
            if byte == 0x2C {
                index += 1
                continue
            } else if byte == 0x5D {
                continue
            }

            // unepxected token
            makeError(.unexpectedToken)
            return nil
        }

        makeError(.unclosedArray)
        return nil // unclosed ]
    }

    // object          = begin-object [ member *( value-separator member ) ] end-object
    // begin-array     = ws %x5B ws  ; [ left square bracket
    // end-object      = ws %x7D ws  ; } right curly bracket
    // member          = string name-separator value
    // name-separator  = ws %x3A ws  ; : colon
    // value-separator = ws %x2C ws  ; , comma
    private func parseDictionary() -> Any? {
        var dictionary = [String: JSON]()

        index += 1 // {
        while index < count {

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // }
            if bytes[index] == 0x7D {
                index += 1
                return dictionary
            }

            // " is expected - "key"
            guard bytes[index] == 0x22 else {
                makeError(.unexpectedToken)
                return nil
            }
            guard let key = parseString() else {
                return nil
            }

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // : is expected
            guard bytes[index] == 0x3A else {
                makeError(.unexpectedToken)
                return nil
            }
            index += 1

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // value
            guard let value = parseValue() else {
                makeError(.unclosedDictionary)
                return nil
            }

            // add to dictionary
            dictionary[key] = JSON(value)

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // , or }
            let byte = bytes[index]
            if byte == 0x2C {
                index += 1
                continue
            } else if byte == 0x7D {
                continue
            }

            // unexpected token
            makeError(.unexpectedToken)
            return nil
        }

        makeError(.unclosedDictionary)
        return nil // unclosed }
    }

    // number        = [ minus ] int [ frac ] [ exp ]
    // decimal-point = %x2E       ; .
    // digit1-9      = %x31-39         ; 1-9
    // e             = %x65 / %x45            ; e E
    // exp           = e [ minus / plus ] 1*DIGIT
    // frac          = decimal-point 1*DIGIT
    // int           = zero / ( digit1-9 *DIGIT )
    // minus         = %x2D               ; -
    // plus          = %x2B                ; +
    // zero          = %x30                ; 0
    private func parseNumber() -> Any? {
        enum State {
            case minusOrInt
            case zero
            case int
            case intDigits
            case frac
            case fracDigits
            case expSign
            case exp
            case expDigits
        }
        var state = State.minusOrInt
        var string = ""
        let firstIndex = index

        read: while index < count {
            let byte = bytes[index]
            switch byte {
            case 0x2D: // -
                switch state {
                case .minusOrInt:
                    state = .int
                case .expSign:
                    state = .exp
                default:
                    makeError(.numberSyntax)
                    return nil
                }
                string.append("-")

            case 0x30 ... 0x39: // 0..9
                switch state {
                case .minusOrInt:
                    if byte == 0x30 { // 0
                        state = .zero
                    } else {
                        state = .intDigits
                    }
                case .int:
                    guard byte != 0x30 else { // must not be 0
                        makeError(.numberSyntax)
                        return nil
                    }
                    state = .intDigits
                case .intDigits:
                    break
                case .frac:
                    state = .fracDigits
                case .fracDigits:
                    break
                case .exp:
                    state = .expDigits
                case .expDigits:
                    break
                default:
                    makeError(.numberSyntax)
                    return nil
                }
                string.append(String(byte - 0x30, radix: 10))

            case 0x2E: // .
                switch state {
                case .zero, .intDigits:
                    state = .frac
                default:
                    makeError(.numberSyntax)
                    return nil
                }
                string.append(".")

            case 0x65, 0x45: // e E
                switch state {
                case .zero, .intDigits, .fracDigits:
                    state = .expSign
                default:
                    makeError(.numberSyntax)
                    return nil
                }
                string.append(byte == 0x65 ? "e" : "E")

            case 0x2B: // +
                switch state {
                case .expSign:
                    state = .exp
                default:
                    makeError(.numberSyntax)
                    return nil
                }
                string.append("+")

            case 0x2C, 0x5D, 0x7D, 0x20, 0x09, 0x0A, 0x0D:  // , ] } space \t \n \r
                break read

            default:
                makeError(.numberSyntax)
                return nil
            }

            index += 1
        }

        // number must be terminated at state of only Zero, or
        // reading remainding digits (from the 2nd on) of int, frac or exp
        switch state {
        case .zero:
            return Int(0)
        case .intDigits:
            guard let int = Int(string, radix: 10) else {
                index = firstIndex
                makeError(.numberSyntax)
                return nil
            }
            return int
        case .fracDigits, .expDigits:
            guard let double = Double(string) else {
                index = firstIndex
                makeError(.numberSyntax)
                return nil
            }
            return double
        default:
            makeError(.numberSyntax)
            return nil
        }
    }

    // string         = quotation-mark *char quotation-mark
    // char           = unescaped / escaped
    // quotation-mark = %x22      ; "
    // unescaped      = %x20-21 / %x23-5B / %x5D-10FFFF
    private func parseString() -> String? {
        buffer.removeAll(keepingCapacity: true)

        // skip "
        index += 1
        while index < count {
            let byte = bytes[index]
            if byte == 0x5C { // \
                guard parseEscaped() else {
                    return nil
                }
            } else {
                if hasSurrogateError() {
                    return nil
                }
                if byte == 0x22 { // "
                    index += 1
                    return buffer.makeString()
                } else if byte >= 0x20 { // valid unit, check code
                    if byte & 0x80 == 0 { // 1 bytes
                        buffer.append(byte)
                        index += 1
                    } else if byte & 0xE0 == 0xC0 { // 2 bytes
                        guard index + 1 < count else {
                            index += 1
                            makeError(.unclosedString)
                            return nil
                        }
                        let byte1 = bytes[index + 1]

                        let code = (UInt(byte & 0x1F) << 6) | UInt(byte1 & 0x3F)
                        guard code >= 0x80 else {
                            makeError(.invalidCharacter)
                            return nil
                        }

                        buffer.append(byte)
                        buffer.append(byte1)
                        index += 2
                    } else if byte & 0xF0 == 0xE0 { // 3 bytes
                        guard index + 2 < count else {
                            index += 1
                            makeError(.unclosedString)
                            return nil
                        }
                        let byte1 = bytes[index + 1]
                        let byte2 = bytes[index + 2]

                        let code = (UInt(byte & 0x0F) << 12) | (UInt(byte1 & 0x3F) << 6) | UInt(byte2 & 0x3F)
                        guard (0x800 <= code && code < 0xD800) || (0xDFFF < code && code <= 0xFFFF) else {
                            makeError(.invalidCharacter)
                            return nil
                        }

                        buffer.append(byte)
                        buffer.append(byte1)
                        buffer.append(byte2)
                        index += 3
                    } else if byte & 0xF8 == 0xF0 { // 4 bytes
                        guard index + 3 < count else {
                            index += 1
                            makeError(.unclosedString)
                            return nil
                        }
                        let byte1 = bytes[index + 1]
                        let byte2 = bytes[index + 2]
                        let byte3 = bytes[index + 3]

                        let code = (UInt(byte & 0x07) << 18) | (UInt(byte1 & 0x3F) << 12) | (UInt(byte2 & 0x3F) << 6) | UInt(byte3)
                        guard 0x10000 <= code && code < 0x10FFFF else {
                            makeError(.invalidCharacter)
                            return nil
                        }

                        buffer.append(byte)
                        buffer.append(byte1)
                        buffer.append(byte2)
                        buffer.append(byte3)
                        index += 4
                    } else {
                        makeError(.invalidCharacter)
                        return nil
                    }
                } else {
                    makeError(.invalidCharacter)
                    return nil
                }
            }
        }

        makeError(.unclosedString)
        return nil // unclosed "
    }

    // escaped =  escape (
    //            %x22 /          ; "    quotation mark  U+0022
    //            %x5C /          ; \    reverse solidus U+005C
    //            %x2F /          ; /    solidus         U+002F
    //            %x62 /          ; b    backspace       U+0008
    //            %x66 /          ; f    form feed       U+000C
    //            %x6E /          ; n    line feed       U+000A
    //            %x72 /          ; r    carriage return U+000D
    //            %x74 /          ; t    tab             U+0009
    //            %x75 4HEXDIG )  ; uXXXX                U+XXXX
    // escape = %x5C              ; \
    private func parseEscaped() -> Bool {
        index += 1 // \
        if index >= count {
            buffer.append(0x5C)
            return true // end of data, return true so it will raise unclosedString error
        }
        let byte = bytes[index]

        // \uXXXX -> Unicode escape sequences
        if byte == 0x75 {
            index += 1
            guard index + 4 <= count,
            let u0 = bytes[index].hexDecoded(),
            let u1 = bytes[index + 1].hexDecoded(),
            let u2 = bytes[index + 2].hexDecoded(),
            let u3 = bytes[index + 3].hexDecoded() else {
                makeError(.escapeSyntax)
                return false
            }
            let code = (UInt(u0) << 12) + (UInt(u1) << 8) + (UInt(u2) << 4) + UInt(u3)

            if 0xD800 <= code && code <= 0xDBFF { // UTF16 high surrogate
                if hasSurrogateError() {
                    return false
                }
                self.highSurrogate = code
                self.highSurrogateIndex = index
            } else if 0xDC00 <= code && code <= 0xDFFF { // UTF16 low surrogate
                guard let surrogate = self.highSurrogate else {
                    makeError(.unpairedSurrogate)
                    return false
                }
                self.highSurrogate = nil
                buffer.append(unicode: 0x10000 + ((surrogate & 0x03FF) << 10) + (code & 0x03FF))
            } else {
                if hasSurrogateError() {
                    return false
                }
                buffer.append(unicode: code)
            }
            index += 4
        } else {
            if hasSurrogateError() {
                return false
            }
            switch byte {
            case 0x22, 0x5C, 0x2F: // \", \\, \/
                buffer.append(byte)
            case 0x62: // \b
                buffer.append(0x08)
            case 0x66: // \f
                buffer.append(0x0C)
            case 0x6E: // \n
                buffer.append(0x0A)
            case 0x72: // \r
                buffer.append(0x0D)
            case 0x74: // \t
                buffer.append(0x09)
            default:
                makeError(.escapeSyntax)
                return false
            }
            index += 1
        }
        return true
    }

    // Returns the value indicating the UTF16 high surrogate is not paired
    private func hasSurrogateError() -> Bool {
        if highSurrogate != nil {
            index = highSurrogateIndex
            makeError(.unpairedSurrogate)
            return true
        }
        return false
    }

    // name = false / null / true
    func parseName() -> Any? {
        var result: Any?
        if result == nil
        && index + 4 <= count {

            if result == nil
            && bytes[index + 0] == 0x74 // true
            && bytes[index + 1] == 0x72
            && bytes[index + 2] == 0x75
            && bytes[index + 3] == 0x65 {
                index += 4
                result = true
            }

            if result == nil
            && bytes[index + 0] == 0x6E // null
            && bytes[index + 1] == 0x75
            && bytes[index + 2] == 0x6C
            && bytes[index + 3] == 0x6C {
                index += 4
                return JSON.null
            }
        }
        if result == nil
        && index + 5 <= count {
            if bytes[index + 0] == 0x66 // false
            && bytes[index + 1] == 0x61
            && bytes[index + 2] == 0x6C
            && bytes[index + 3] == 0x73
            && bytes[index + 4] == 0x65 {
                index += 5
                result = false
            }
        }

        if result == nil {
            makeError(.unexpectedToken)
        } else if index < count {
            let byte = bytes[index]
            if !(byte == 0x2C   // ,
            || byte == 0x5D     // ]
            || byte == 0x7D     // }
            || byte == 0x20     // ws
            || (0x08 <= byte && byte <= 0x0D)) {
                makeError(.unexpectedToken)
                result = nil
            }
        }
        return result
    }

    // ws = *(
    //            %x20 /              ; Space
    //            %x09 /              ; Horizontal tab
    //            %x0A /              ; Line feed or New line
    //            %x0D                ; Carriage return
    //        )
    func skipWhitespaces() {
        while index < count {
            let byte = bytes[index]
            if byte == 0x20 || byte == 0x09 || byte == 0x0A || byte == 0x0D {
                index += 1
                if byte == 0x0A {
                    line += 1
                    lineStartOffset = index
                }
            } else {
                break
            }
        }
    }

    func makeError(_ type: ParsingErrorType) {
        if error == nil {
            let x = (index < count ? index : (count - 1)) - lineStartOffset + 1
            let y = line + 1

            switch type {
            case .emptyDocument:
                error = JSON.ParsingError(description: "Empty document")
            case .unexpectedToken:
                error = JSON.ParsingError(description: "Unexpected token at (\(y),\(x))")
            case .unclosedArray:
                error = JSON.ParsingError(description: "Unclosed array")
            case .unclosedDictionary:
                error = JSON.ParsingError(description: "Unclosed dictionary")
            case .unclosedString:
                error = JSON.ParsingError(description: "Unclosed string")
            case .unpairedSurrogate:
                error = JSON.ParsingError(description: "Unpaired escaped surrogate at (\(y),\(x))")
            case .invalidCharacter:
                error = JSON.ParsingError(description: "Invalid character at (\(y),\(x))")
            case .numberSyntax:
                error = JSON.ParsingError(description: "Invalid number syntax at (\(y),\(x))")
            case .escapeSyntax:
                error = JSON.ParsingError(description: "Invalid escape syntax at (\(y),\(x))")
            }
        }
    }
}
