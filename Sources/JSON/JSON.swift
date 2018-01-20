//
//  JSON.swift
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

// MARK: - init
public struct JSON {

    internal struct Null { }

    public static let null: Any = Null()

    internal struct Undefined { }

    public static let undefined: Any = Undefined()

    public var value: Any

    public init() {
        self.value = JSON.null
    }

    public init(_ any: Any) {
        self.value = any
    }
}

// MARK: - value
extension JSON {

    public var null: Bool {
        if self.value as? Null != nil {
            return true
        }
        return false
    }

    public var bool: Bool? {
        if let value = self.value as? Bool {
            return value
        }
        return nil
    }

    public var int: Int? {
        if let value = self.value as? Int {
            return value
        }
        else if let value = self.value as? Double {
            let valueInt = Int(value)
            if Double(valueInt) == value {
                return valueInt
            }
        }
        return nil
    }

    public var double: Double? {
        if let value = self.value as? Int {
            return Double(value)
        }
        else if let value = self.value as? Double {
            return value
        }
        return nil
    }

    public var string: String? {
        if let value = self.value as? String {
            return value
        }
        return nil
    }

    public var array: [JSON]?  {
        switch self.value {
        case let array as [JSON]:
            return array
        case let values as [Any]:
            var array = Array<JSON>(repeating: JSON(), count: values.count)
            for (index, value) in values.enumerated() {
                array[index].value = value
            }
            return array
        default:
            return nil
        }
    }

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
}

// MARK: - arrayOf
extension JSON {
    public var arrayOfBool: [Bool]? {
        switch self.value {
        case let array as [Bool]:
            return array
        case let array as [JSON]:
            return arrayOfType(array, defaultValue: false)
        case let array as [Any]:
            return arrayOfType(array, defaultValue: false)
        default:
            return nil
        }
    }

    public var arrayOfInt: [Int]? {
        switch self.value {
        case let array as [Int]:
            return array
        case let values as [Double]:
            var array = Array<Int>(repeating: 0, count: values.count)
            for (index, value) in values.enumerated() {
                let valueInt = Int(value)
                if value == Double(valueInt) {
                    array[index] = valueInt
                }
                else {
                    return nil
                }
            }
            return array
        case let jsons as [JSON]:
            var array = Array<Int>(repeating: 0, count: jsons.count)
            for (index, json) in jsons.enumerated() {
                if let value = json.int {
                    array[index] = value
                }
                else {
                    return nil
                }
            }
            return array
        case let values as [Any]:
            var array = Array<Int>(repeating: 0, count: values.count)
            for (index, value) in values.enumerated() {
                if let value = JSON(value).int {
                    array[index] = value
                }
                else {
                    return nil
                }
            }
            return array
        default:
            return nil
        }
    }

    public var arrayOfDouble: [Double]? {
        switch self.value {
        case let values as [Int]:
            var array = Array<Double>(repeating: 0, count: values.count)
            for (index, value) in values.enumerated() {
                array[index] = Double(value)
            }
            return array
        case let array as [Double]:
            return array
        case let jsons as [JSON]:
            var array = Array<Double>(repeating: 0, count: jsons.count)
            for (index, json) in jsons.enumerated() {
                if let value = json.double {
                    array[index] = value
                }
                else {
                    return nil
                }
            }
            return array
        case let values as [Any]:
            var array = Array<Double>(repeating: 0, count: values.count)
            for (index, value) in values.enumerated() {
                if let value = JSON(value).double {
                    array[index] = value
                }
                else {
                    return nil
                }
            }
            return array
        default:
            return nil
        }
    }

    public var arrayOfString: [String]? {
        switch self.value {
        case let array as [String]:
            return array
        case let array as [JSON]:
            return arrayOfType(array, defaultValue: "")
        case let array as [Any]:
            return arrayOfType(array, defaultValue: "")
        default:
            return nil
        }
    }

    private func arrayOfType<T>(_ elements: [JSON], defaultValue: T) -> [T]? {
        var array = Array<T>(repeating: defaultValue, count: elements.count)
        for (index, json) in elements.enumerated() {
            if let value = json.value as? T {
                array[index] = value
            }
            else {
                return nil
            }
        }
        return array
    }

    private func arrayOfType<T>(_ elements: [Any], defaultValue: T) -> [T]? {
        var array = Array<T>(repeating: defaultValue, count: elements.count)
        for (index, element) in elements.enumerated() {
            if let value = element as? T {
                array[index] = value
            }
            else {
                return nil
            }
        }
        return array
    }
}

// MARK: - dictionaryOf
extension JSON {
    public var dictionaryOfBool: [String: Bool]? {
        switch self.value {
        case let dictionary as [String: Bool]:
            return dictionary
        case let dictionary as [String: JSON]:
            return dictionaryOfType(dictionary)
        case let dictionary as [String: Any]:
            return dictionaryOfType(dictionary)
        default:
            return nil
        }
    }

    public var dictionaryOfInt: [String: Int]? {
        switch self.value {
        case let dictionary as [String: Int]:
            return dictionary
        case let dict as [String: Double]:
            var dictionary = Dictionary<String, Int>(minimumCapacity: dict.count)
            for (key, value) in dict {
                let valueInt = Int(value)
                if value == Double(valueInt) {
                    dictionary[key] = valueInt
                }
                else {
                    return nil
                }
            }
            return dictionary
        case let jsons as [String: JSON]:
            var dictionary = Dictionary<String, Int>(minimumCapacity: jsons.count)
            for (key, json) in jsons {
                if let value = json.int {
                    dictionary[key] = value
                }
                else {
                    return nil
                }
            }
            return dictionary
        case let dict as [String: Any]:
            var dictionary = Dictionary<String, Int>(minimumCapacity: dict.count)
            for (key, value) in dict {
                if let value = JSON(value).int {
                    dictionary[key] = value
                }
                else {
                    return nil
                }
            }
            return dictionary
        default:
            return nil
        }
    }

    public var dictionaryOfDouble: [String: Double]? {
        switch self.value {
        case let dict as [String: Int]:
            var dictionary = Dictionary<String, Double>(minimumCapacity: dict.count)
            for (key, value) in dict {
                dictionary[key] = Double(value)
            }
            return dictionary
        case let dictionary as [String: Double]:
            return dictionaryOfType(dictionary)
        case let jsons as [String: JSON]:
            var dictionary = Dictionary<String, Double>(minimumCapacity: jsons.count)
            for (key, json) in jsons {
                if let value = json.double {
                    dictionary[key] = value
                }
                else {
                    return nil
                }
            }
            return dictionary
        case let dict as [String: Any]:
            var dictionary = Dictionary<String, Double>(minimumCapacity: dict.count)
            for (key, value) in dict {
                if let value = JSON(value).double {
                    dictionary[key] = value
                }
                else {
                    return nil
                }
            }
            return dictionary
        default:
            return nil
        }
    }

    public var dictionaryOfString: [String: String]? {
        switch self.value {
        case let dictionary as [String: String]:
            return dictionary
        case let dictionary as [String: JSON]:
            return dictionaryOfType(dictionary)
        case let dictionary as [String: Any]:
            return dictionaryOfType(dictionary)
        default:
            return nil
        }
    }

    private func dictionaryOfType<T>(_ dict: [String: JSON]) -> [String: T]? {
        var dictionary = Dictionary<String, T>(minimumCapacity: dict.count)
        for (index, json) in dict {
            if let value = json.value as? T {
                dictionary[index] = value
            }
            else {
                return nil
            }
        }
        return dictionary
    }

    private func dictionaryOfType<T>(_ dict: [String: Any]) -> [String: T]? {
        var dictionary = Dictionary<String, T>(minimumCapacity: dict.count)
        for (key, value) in dict {
            if let value = value as? T {
                dictionary[key] = value
            }
            else {
                return nil
            }
        }
        return dictionary
    }
}

// MARK: - subscript
let jsonOfNull = JSON(JSON.Null())

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

// MARK: - Convertable

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

// MARK: - Expressible

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
