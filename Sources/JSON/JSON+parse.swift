//
//  JSON+parse.swift
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

import Byte

extension JSON {
    public static func parse(bytes: UnsafePointer<UInt8>, count: Int) throws -> JSON {
        let parser = Parser(bytes: bytes, count: count)
        if let any = parser.parse() {
            return JSON(any)
        }
        throw parser.error!
    }

    public static func parse(bytes: Bytes) throws -> JSON {
        return try bytes.withUnsafeBytes { bp in
            return try JSON.parse(bytes: bp.baseAddress!.assumingMemoryBound(to: UInt8.self), count: bp.count)
        }
    }

    public static func parse(string: String) throws -> JSON {
        return try string.utf8CString.withUnsafeBytes { bp in
            return try JSON.parse(bytes: bp.baseAddress!.assumingMemoryBound(to: UInt8.self), count: bp.count - 1)
        }
    }
}

extension JSON {

    public struct Error: Swift.Error, CustomStringConvertible {
        public let description: String
        public let code: Code
    }
}

extension JSON.Error {
    public enum Code {
        case emptyDocument
        case unexpectedToken
        case unclosedArray
        case unclosedDictionary
        case unclosedString
        case numberSyntax
        case escapeSyntax
        case invalidJSON
    }
}

private class Parser {
    let bytes: UnsafePointer<UInt8>
    let count: Int
    var index: Int = 0

    var buffer: Bytes = []

    var error: JSON.Error?
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
        let any = parseAny()
        if any == nil {
            if error == nil {
                makeError(.emptyDocument)
                return nil
            }
        }
        else if index < count {
            skipWhitespaces()
            if index < count {
                makeError(.unexpectedToken)
                return nil
            }
        }
        return any
    }

    private func parseAny() -> Any? {
        let byte = bytes[index]
        if byte == 0x2D || (byte >= 0x30 && byte <= 0x39) { // -, 0..9
            return parseNumber()
        }
        else {
            switch byte {
            case 0x22: // \"
                return parseString()
            case 0x5B: // [
                return parseArray()
            case 0x7B: // {
                return parseDictionary()
            case 0x08, 0x09, 0x0A, 0x00B, 0x0C, 0x0D, 0x20: // \t \n \f \r space
                skipWhitespaces()
                if index < count {
                    return parseAny()
                }
                else {
                    return nil
                }
            default:
                return parseIdent()
            }
        }
    }

    private func parseArray() -> Any? {

        index += 1 // [
        var array = [JSON]()

        while index < count {

            // skip whitespace if any
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

            // element
            guard let element = parseAny() else {
                makeError(.unclosedArray)
                return nil
            }
            if index >= count { // unclosed ]
                makeError(.unclosedArray)
                return nil
            }

            // add to array
            array.append(JSON(element))

            // skip whitespace if any
            skipWhitespaces()
            if index >= count { // unclosed ]
                makeError(.unclosedArray)
                return nil
            }

            // ,
            let byte = bytes[index]
            if byte == 0x2C {
                index += 1
                continue
            }

            // ]
            else if byte == 0x5D {
                continue
            }

            // unepxected token
            makeError(.unexpectedToken)
            return nil
        }

        makeError(.unclosedArray)
        return nil // unclosed ]
    }

    private func parseDictionary() -> Any? {

        index += 1 // {
        var dictionary = [String: JSON]()

        while index < count {

            // skip whitespace if any
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

            // "key"
            if bytes[index] != 0x22 {
                makeError(.unexpectedToken)
                return nil
            }
            guard let key = parseString() else {
                return nil
            }

            // skip whitespace if any
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // : is expected
            if bytes[index] != 0x3A {
                makeError(.unexpectedToken)
                return nil
            }
            index += 1

            // skip whitespace if any
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // value
            guard let value = parseAny() else {
                makeError(.unclosedDictionary)
                return nil
            }

            // add to dictionary
            dictionary[key] = JSON(value)

            // skip whitespace if any
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // ,
            let byte = bytes[index]
            if byte == 0x2C {
                index += 1
                continue
            }

            // }
            if byte == 0x7D {
                continue
            }

            // invalid
            makeError(.unexpectedToken)
            return nil
        }

        makeError(.unclosedDictionary)
        return nil // unclosed }
    }

    private func parseNumber() -> Any? {

        var acceptsDash = true
        var acceptsDot = true
        var hasDot = false
        var hasDigits = false
        var negative = false

        var integer = 0
        var fraction: Double = 0
        var fractionDigits: Double = 1

        while index < count {
            let byte = bytes[index]

            if byte == 0x2D { // -
                guard acceptsDash else {
                    makeError(.numberSyntax)
                    return nil
                }
                negative = true
                acceptsDash = false
                index += 1
            }
            else if byte == 0x2E { // .
                guard acceptsDot else {
                    makeError(.numberSyntax)
                    return nil
                }
                hasDot = true
                acceptsDot = false
                index += 1
            }
            else if byte >= 0x30 && byte <= 0x39 { // 0..9
                hasDigits = true
                acceptsDash = false
                if hasDot {
                    fractionDigits *= 10
                    fraction += Double(byte - 0x30) / fractionDigits
                }
                else {
                    integer = integer * 10 + Int(byte - 0x30)
                }
                index += 1
            }
            else if byte == 0x2C    // ,
            || byte == 0x5D         // ]
            || byte == 0x7D         // }
            || byte == 0x20         // ws
            || (0x08 <= byte && byte <= 0x0D) {
                break
            }
            else {
                makeError(.numberSyntax)
                return nil
            }
        }

        if !hasDigits { // only happend with dash (-) not followed by digits
            makeError(.numberSyntax)
            return nil
        }

        if fractionDigits > 1 {
            let double = Double(integer) + fraction
            return negative ? -double : double
        }
        else if hasDot {
            makeError(.numberSyntax)
            return nil
        }

        return negative ? -integer : integer
    }

    private func parseString() -> String? {

        buffer.removeAll(keepingCapacity: true)

        // skip "
        index += 1

        while index < count {
            let byte = bytes[index]
            if byte == 0x22 { // "
                index += 1
                return buffer.makeString()
            }
            else if byte == 0x5C { // \
                if !parseEscape() {
                    return nil
                }
            }
            else if byte == 0x0A {
                buffer.append(byte)
                index += 1
                line += 1
                lineStartOffset = index
            }
            else {
                buffer.append(byte)
                index += 1
            }
        }

        makeError(.unclosedString)
        return nil // unclosed "
    }

    private func parseEscape() -> Bool {
        index += 1 // \
        if index >= count {
            buffer.append(.backSlash)
            return true
        }
        switch bytes[index] {
        case 0x62: // \b
            index += 1
            buffer.append(0x08)
            return true
        case 0x74: // \t
            index += 1
            buffer.append(0x09)
            return true
        case 0x6E: // \n
            index += 1
            buffer.append(0x0A)
            return true
        case 0x76: // \v
            index += 1
            buffer.append(0x0B)
            return true
        case 0x66: // \f
            index += 1
            buffer.append(0x0C)
            return true
        case 0x72: // \r
            index += 1
            buffer.append(0x0D)
            return true
        case 0x22: // \"
            index += 1
            buffer.append(0x22)
            return true
        case 0x2F: // \/
            index += 1
            buffer.append(0x2F)
            return true
        case 0x5C: // \\
            index += 1
            buffer.append(0x5C)
            return true
        case 0x30 ... 0x39: // \(0-255) -> octal escape sequences
            var number = Int(bytes[index]) - 0x30
            index += 1
            if index < count && bytes[index].isDigit {
                number = number * 10 + (Int(bytes[index]) - 0x30)
                index += 1
            }
            if index < count && bytes[index].isDigit {
                number = number * 10 + (Int(bytes[index]) - 0x30)
                index += 1
            }
            let scalar = Unicode.Scalar(number)!
            buffer.append(contentsOf: String(Character(scalar)).makeBytes())
            return true

        case 0x78: // \xXX -> hexadecimal escape sequences
            index += 1
            guard index + 2 <= count &&
                bytes[index].isHexDigit &&
                bytes[index + 1].isHexDigit
            else {
                makeError(.escapeSyntax)
                return false
            }
            let number = Int([bytes[index], bytes[index + 1]], radix: 16)!
            let scalar = Unicode.Scalar(number)!
            buffer.append(contentsOf: String(Character(scalar)).makeBytes())
            index += 2
            return true
        case 0x75: // \uXXXX -> Unicode escape sequences
            index += 1
            guard index + 4 <= count &&
                bytes[index].isHexDigit &&
                bytes[index + 1].isHexDigit &&
                bytes[index + 2].isHexDigit &&
                bytes[index + 3].isHexDigit
            else {
                makeError(.escapeSyntax)
                return false
            }
            guard let number = Int(
                    [
                        bytes[index],
                        bytes[index + 1],
                        bytes[index + 2],
                        bytes[index + 3]
                    ],
                    radix: 16
                ),
                let scalar = Unicode.Scalar(number)
            else {
                makeError(.escapeSyntax)
                return false
            }
            buffer.append(contentsOf: String(Character(scalar)).makeBytes())
            index += 4
            return true
        default:
            buffer.append(bytes[index])
            index += 1
            return true
        }
    }

    func parseIdent() -> Any? { // true, false, null
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

    func skipWhitespaces() {
        while index < count {
            let byte = bytes[index]
            if (0x08 <= byte && byte <= 0x0D) || byte == 0x20 {
                index += 1
                if byte == 0x0A {
                    line += 1
                    lineStartOffset = index
                }
            }
            else {
                break
            }
        }
    }

    func makeError(_ code: JSON.Error.Code) {
        if error == nil {
            let x = (index < count ? index : (count - 1)) - lineStartOffset + 1
            let y = line + 1

            switch code {
            case .emptyDocument:
                error = JSON.Error(description: "Empty document", code: code)
            case .unexpectedToken:
                error = JSON.Error(description: "Unexpected token at (\(y),\(x))", code: code)
            case .unclosedArray:
                error = JSON.Error(description: "Unclosed array", code: code)
            case .unclosedDictionary:
                error = JSON.Error(description: "Unclosed dictionary", code: code)
            case .unclosedString:
                error = JSON.Error(description: "Unclosed string", code: code)
            case .numberSyntax:
                error = JSON.Error(description: "Invalid number syntax at (\(y),\(x))", code: code)
            case .escapeSyntax:
                error = JSON.Error(description: "Invalid escape syntax at (\(y),\(x))", code: code)
            case .invalidJSON: // serialize only
                break
            }
        }
    }
}
