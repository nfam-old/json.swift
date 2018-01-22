//
//  JSON+serialize.swift
//
//  Created by Ninh on 12/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension JSON {

    // Returns stringifed JSON in UTF8 encoding.
    public func serialized(pretty: Bool = false) -> [UInt8]? {
        let result: [UInt8]?
        do {
            result = try JSON.serialize(self, pretty: pretty)
        } catch {
            result = nil
        }
        return result
    }

    // Returns stringifed JSON in `String`.
    public func stringified(pretty: Bool = false) -> String? {
        let result: String?
        do {
            result = try JSON.stringify(self, pretty: pretty)
        } catch {
            result = nil
        }
        return result
    }
}

extension JSON {
    public struct InvalidError: Error, CustomStringConvertible, CustomDebugStringConvertible {
        public let description = "Invalid JSON object"
        fileprivate init() {
        }
        public var debugDescription: String {
            return description
        }
    }
}

extension JSON {

    // Returns stringifed JSON in UTF8 encoding.
    public static func serialize(_ json: JSON, pretty: Bool = false) throws -> [UInt8] {
        let result: [UInt8]
        let serializer = Serializer(pretty: pretty)
        if serializer.serialize(any: json.value) {
            result = serializer.buffer
        } else {
            throw JSON.InvalidError()
        }
        return result
    }

    // Returns stringifed JSON in `String`.
    public static func stringify(_ json: JSON, pretty: Bool = false) throws -> String {
        let bytes = try serialize(json, pretty: pretty)
        return bytes.makeString()
    }
}

private class Serializer {

    var buffer: [UInt8] = []
    var pretty: Bool
    var level: Int = 0
    var line: Int = 0

    init(pretty: Bool) {
        self.pretty = pretty
    }

    func serialize(any: Any) -> Bool {
        switch any {

        case let string as String:
            append(string: string)
            return true

        case let bool as Bool:
            if bool {
                buffer.append(0x74)
                buffer.append(0x72)
                buffer.append(0x75)
                buffer.append(0x65)
            } else {
                buffer.append(0x66)
                buffer.append(0x61)
                buffer.append(0x6C)
                buffer.append(0x73)
                buffer.append(0x65)
            }
            return true

        case let int as Int:
            append(integer: int)
            return true

        case let double as Double:
            buffer.append(contentsOf: String(double).utf8)
            return true

        case let array as [JSON]:
            buffer.append(0x5B) // [
            if !array.isEmpty {
                level += 1
                var hasItems = false
                for element in array {
                    if hasItems {
                        buffer.append(0x2C) // ,
                    } else {
                        hasItems = true
                    }
                    if pretty {
                        appendIndent()
                    }
                    if !serialize(any: element.value) {
                        return false
                    }
                }
                level -= 1
                if pretty {
                    appendIndent()
                }
            }
            buffer.append(0x5D) // ]
            return true

        case let dictionary as [String: JSON]:
            buffer.append(0x7B) // {
            if !dictionary.isEmpty {
                level += 1
                var hasItems = false
                for key in dictionary.keys.sorted() {
                    if hasItems {
                        buffer.append(0x2C) // ,
                    } else {
                        hasItems = true
                    }

                    if pretty {
                        appendIndent()
                    }

                    append(string: key)
                    buffer.append(0x3A) // :

                    if pretty {
                        buffer.append(0x20) // ws
                    }

                    if !serialize(any: dictionary[key]!.value) {
                        return false
                    }
                }
                level -= 1
                if pretty {
                    appendIndent()
                }
            }
            buffer.append(0x7D) // }
            return true

        case _ as JSON.Null:
            buffer.append(0x6E)
            buffer.append(0x75)
            buffer.append(0x6C)
            buffer.append(0x6C)
            return true

        case let array as [Any]:
            return serialize(array: array)

        case let dictionary as [String: Any]:
            return serialize(dictionary: dictionary)

        default:
            return false
        }
    }

    private func serialize<T>(array: [T]) -> Bool where T: Any {
        buffer.append(0x5B) // [
        if !array.isEmpty {
            level += 1
            var hasItems = false
            for element in array {
                if hasItems {
                    buffer.append(0x2C) // ,
                } else {
                    hasItems = true
                }
                if pretty {
                    appendIndent()
                }
                if !serialize(any: element) {
                    return false
                }
            }
            level -= 1
            if pretty {
                appendIndent()
            }
        }
        buffer.append(0x5D) // ]
        return true
    }

    private func serialize<T>(dictionary: [String: T]) -> Bool where T: Any {
        buffer.append(0x7B) // {
        if !dictionary.isEmpty {
            level += 1
            var hasItems = false
            for key in dictionary.keys.sorted() {
                if hasItems {
                    buffer.append(0x2C) // ,
                } else {
                    hasItems = true
                }

                if pretty {
                    appendIndent()
                }

                append(string: key)
                buffer.append(0x3A) // :

                if pretty {
                    buffer.append(0x20) // ws
                }

                if !serialize(any: dictionary[key]!) {
                    return false
                }
            }
            level -= 1
            if pretty {
                appendIndent()
            }
        }
        buffer.append(0x7D) // }
        return true
    }

    private func appendIndent() {
        if pretty {
            buffer.append(0x0D)
            buffer.append(0x0A)
            for _ in 0 ..< level {
                buffer.append(0x09)
            }
        }
    }

    private func append(integer: Int) {
        var value = integer
        if value < 0 {
            buffer.append(0x2D) // '-'
            value = -value
        }

        var stack: [UInt8] = []
        repeat {
            let next = value / 10
            stack.append(UInt8(value - (next * 10)))
            value = next
        } while value > 0

        for digit in stack.reversed() {
            buffer.append(digit + 0x30)
        }
    }

    private func append(string: String) {
        buffer.append(0x22) // "
        for byte in string.utf8 {
            switch byte {
            case 0x22: // \"
                buffer.append(0x5C)
                buffer.append(0x22)
            case 0x2F: // \/
                buffer.append(0x5C)
                buffer.append(0x2F)
            case 0x5C: // \\
                buffer.append(0x5C)
                buffer.append(0x5C)
            case 0x08: // \b
                buffer.append(0x5C)
                buffer.append(0x62)
            case 0x0C: // \f
                buffer.append(0x5C)
                buffer.append(0x66)
            case 0x0A: // \n
                buffer.append(0x5C)
                buffer.append(0x6E)
                line += 1
            case 0x0D: // \r
                buffer.append(0x5C)
                buffer.append(0x72)
            case 0x09: // \t
                buffer.append(0x5C)
                buffer.append(0x74)
            default:
                if byte < 0x20 { // \u00XX
                    buffer.append(0x5C)
                    buffer.append(0x75)
                    buffer.append(0x30)
                    buffer.append(0x30)
                    buffer.append(byte.hexEncoded(of: .high))
                    buffer.append(byte.hexEncoded(of: .low))
                } else {
                    buffer.append(byte)
                }
            }
        }
        buffer.append(0x22) // "
    }
}
