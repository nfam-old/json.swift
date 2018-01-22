//
//  JSON.swift
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

public struct JSON {

    internal struct Null { }

    public static let null: Any = Null()

    public var value: Any

    fileprivate init(value: Any) {
        self.value = value
    }

    public init() {
        self = jsonOfNull
    }

    public init(_ value: Any?) {
        if let value = value {
            if (value as? Null) != nil {
                self = jsonOfNull
            } else {
                self.value = value
            }
        } else {
            self = jsonOfNull
        }
    }
}

let jsonOfNull = JSON(value: JSON.null)

extension JSON {

    /// List of data type available in JSON.
    public enum ValueType {
        /// array
        case array

        /// false or true
        case bool

        /// object
        case dictionary

        /// number
        case number

        /// null
        case null

        /// string
        case string

        /// not supported in JSON spec.
        case unknown
    }

    /// Returns the data type of value in JSON.
    public var type: ValueType {
        switch self.value {
        case _ as [JSON]:
            return .array
        case _ as [Any]:
            return .array
        case _ as Bool:
            return .bool
        case _ as [String: JSON]:
            return .dictionary
        case _ as [String: Any]:
            return .dictionary
        case _ as Int:
            return .number
        case _ as Double:
            return .number
        case _ as Null:
            return .null
        case _ as String:
            return .string
        default:
            return .unknown
        }
    }
}

extension JSON {

    /// Returns an `Array` if the data type is array, otherwise `nil`.
    public var array: [JSON]? {
        switch self.value {
        case let array as [JSON]:
            return array
        case let array as [Any]:
            return array.map { JSON($0) }
        default:
            return nil
        }
    }

    /// Returns a `Bool` value if the data type is boolean, otherwise `nil`.
    public var bool: Bool? {
        return self.value(of: Bool.self)
    }

    /// Returns an `Dictionary` if the data type is dictionary, otherwise `nil`.
    public var dictionary: [String: JSON]? {
        switch self.value {
        case let dict as [String: JSON]:
            return dict
        case let dict as [String: Any]:
            var dictionary = [String: JSON](minimumCapacity: dict.count)
            for (key, value) in dict {
                dictionary[key] = JSON(value)
            }
            return dictionary
        default:
            return nil
        }
    }

    /// Returns a `Double` value if the data type is number, otherwise `nil`.
    public var double: Double? {
        return self.value(of: Double.self)
    }

    /// Returns a `Int` value if the data type is number and
    /// convertable to integer without losing precision, otherwise `nil`.
    public var int: Int? {
        return self.value(of: Int.self)
    }

    /// Returns `true` if the value is null, otherwise `false`.
    public var null: Bool {
        if self.value as? Null != nil {
            return true
        }
        return false
    }

    /// Returns a `String` if the data type is string, otherwise `nil`.
    public var string: String? {
        return self.value(of: String.self)
    }

    /// Returns the value if the data type is correct, otherwise `nil`.
    fileprivate func value<T>(of type: T.Type) -> T? {
        if let value = self.value as? T {
            return value
        }
        return nil
    }

    /// Returns the value if the data type is correct, otherwise `nil`.
    fileprivate func value(of type: Double.Type) -> Double? {
        if let value = self.value as? Int {
            return Double(value)
        } else if let value = self.value as? Double {
            return value
        }
        return nil
    }

    /// Returns the value if the data type is correct, otherwise `nil`.
    fileprivate func value(of type: Int.Type) -> Int? {
        if let value = self.value as? Int {
            return value
        } else if let value = self.value as? Double, value == value.rounded(.towardZero) {
            return Int(value)
        }
        return nil
    }
}

extension RandomAccessCollection where Element == JSON, IndexDistance == Int {
    public func map<T>(to type: T.Type) -> [T]? {
        var array = [T]()
        array.reserveCapacity(self.count)
        for json in self {
            guard let value = json.value(of: type) else {
                return nil
            }
            array.append(value)
        }
        return array
    }

    public func map(to type: Double.Type) -> [Double]? {
        var array = [Double]()
        array.reserveCapacity(self.count)
        for json in self {
            guard let value = json.value(of: type) else {
                return nil
            }
            array.append(value)
        }
        return array
    }

    public func map(to type: Int.Type) -> [Int]? {
        var array = [Int]()
        array.reserveCapacity(self.count)
        for json in self {
            guard let value = json.value(of: type) else {
                return nil
            }
            array.append(value)
        }
        return array
    }
}

extension Dictionary where Key == String, Value == JSON {
    public func map<T>(to type: T.Type) -> [String: T]? {
        var dictionary = [String: T]()
        dictionary.reserveCapacity(self.count)
        for (key, json) in self {
            guard let value = json.value(of: type) else {
                return nil
            }
            dictionary[key] = value
        }
        return dictionary
    }

    public func map(to type: Double.Type) -> [String: Double]? {
        var dictionary = [String: Double]()
        dictionary.reserveCapacity(self.count)
        for (key, json) in self {
            guard let value = json.value(of: type) else {
                return nil
            }
            dictionary[key] = value
        }
        return dictionary
    }

    public func map(to type: Int.Type) -> [String: Int]? {
        var dictionary = [String: Int]()
        dictionary.reserveCapacity(self.count)
        for (key, json) in self {
            guard let value = json.value(of: type) else {
                return nil
            }
            dictionary[key] = value
        }
        return dictionary
    }
}

extension JSON {

    public subscript(index: Int) -> JSON {
        if index >= 0 {
            if let array = self.value as? [JSON], array.count > index {
                return array[index]
            }
            if let array = self.value as? [Any], array.count > index {
                return JSON(array[index])
            }
        }
        return jsonOfNull
    }

    public subscript(key: String) -> JSON {
        if let dictionary = self.value as? [String: JSON] {
            if let value = dictionary[key] {
                return value
            }
        }
        if let dictionary = self.value as? [String: Any] {
            if let value = dictionary[key] {
                return JSON(value)
            }
        }
        return jsonOfNull
    }

}

extension JSON: CustomStringConvertible {
    public var description: String {
        return stringified() ?? "error: Invalid JSON object"
    }
}

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return stringified(pretty: true) ?? "error: Invalid JSON object"
    }
}

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral value: Void) {
        self.value = JSON.null
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.value = value
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.value = value
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.value = value
    }
}

extension JSON: ExpressibleByStringLiteral {
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self.value = elements
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dictionary = [String: JSON](minimumCapacity: elements.count)

        for pair in elements {
            dictionary[pair.0] = pair.1
        }

        self.value = dictionary
    }
}
