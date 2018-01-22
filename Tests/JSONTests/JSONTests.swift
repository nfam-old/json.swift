//
//  JSONTests.swift
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

class JSONTests: XCTestCase {

    static var allTests = [
        ("testValueType", testValueType),
        ("testNull", testNull),
        ("testBool", testBool),
        ("testInt", testInt),
        ("testDouble", testDouble),
        ("testString", testString),
        ("testArray", testArray),
        ("testArrayOfBool", testArrayOfBool),
        ("testArrayOfInt", testArrayOfInt),
        ("testArrayOfDouble", testArrayOfDouble),
        ("testArrayOfString", testArrayOfString),
        ("testDictionary", testDictionary),
        ("testDictionaryOfBool", testDictionaryOfBool),
        ("testDictionaryOfInt", testDictionaryOfInt),
        ("testDictionaryOfDouble", testDictionaryOfDouble),
        ("testDictionaryOfString", testDictionaryOfString),
        ("testExpressible", testExpressible),
        ("testDescription", testDescription),
        ("testDebugDescription", testDebugDescription)
    ]

    func testValueType() {
        XCTAssertEqual(JSON().type, .null)
        XCTAssertEqual(JSON(nil).type, .null)
        XCTAssertEqual(JSON(true).type, .bool)
        XCTAssertEqual(JSON(false).type, .bool)
        XCTAssertEqual(JSON(1).type, .number)
        XCTAssertEqual(JSON(1.0).type, .number)
        XCTAssertEqual(JSON("string").type, .string)
        XCTAssertEqual(JSON([1, 2]).type, .array)
        XCTAssertEqual(JSON([JSON(1), JSON(2)]).type, .array)
        XCTAssertEqual(JSON(["name": "value"]).type, .dictionary)
        XCTAssertEqual(JSON(["name": JSON("value")]).type, .dictionary)
        XCTAssertEqual(JSON(InvalidObject()).type, .unknown)
    }

    func testNull() {
        XCTAssertEqual(JSON().null, true)
        XCTAssertEqual(JSON(0).null, false)
    }

    func testBool() {
        XCTAssertEqual(JSON(true).bool, true)
        XCTAssertEqual(JSON(false).bool, false)
        XCTAssertEqual(JSON(0).bool, nil)
    }

    func testInt() {
        XCTAssertEqual(JSON(1).int, 1)
        XCTAssertEqual(JSON(1.0).int, 1)
        XCTAssertEqual(JSON(1.1).int, nil)
        XCTAssertEqual(JSON("").int, nil)
    }

    func testDouble() {
        XCTAssertEqual(JSON(1).int, 1)
        XCTAssertEqual(JSON(1.0).int, 1)
        XCTAssertEqual(JSON("").int, nil)
    }

    func testString() {
        XCTAssertEqual(JSON("test").string, "test")
        XCTAssertEqual(JSON(0).string, nil)
    }

    func testArray() {

        // not array
        XCTAssertNil(JSON("").array)

        XCTAssertNotNil(JSON([false, true]).array)
        XCTAssertNotNil(JSON([0, 1]).array)
        XCTAssertNotNil(JSON([0.0, 1.1]).array)
        XCTAssertNotNil(JSON(["0", "1"]).array)

        XCTAssertNotNil(JSON([JSON(false), JSON(0), JSON(1.1), JSON("2")]).array)
        XCTAssertNotNil(JSON([false, 0, 1.1, "2"]).array)

        XCTAssertEqual(JSON([JSON(false), JSON(0)])[1].int, 0)
        XCTAssertEqual(JSON([JSON(false), JSON(0)])[2].int, nil)
        XCTAssertEqual(JSON([false, 0, 1.1, "2"])[1].int, 0)
        XCTAssertEqual(JSON([false, 0])[2].int, nil)
    }

    func testArrayOfBool() {

        XCTAssertNil(JSON("").array?.map(to: Bool.self))

        // array of Bool
        let arrayOfBool = [true, false]
        XCTAssertNotNil(JSON(arrayOfBool).array?.map(to: Bool.self))
        if let array = JSON(arrayOfBool).array?.map(to: Bool.self) {
            XCTAssertEqual(array, arrayOfBool)
        }

        // array of JSON Bool
        let arrayOfJSONBool = [JSON(true), JSON(false)]
        XCTAssertNotNil(JSON(arrayOfJSONBool).array?.map(to: Bool.self))
        if let array = JSON(arrayOfJSONBool).array?.map(to: Bool.self) {
            XCTAssertEqual(array, arrayOfBool)
        }
        let arrayOfJSONBool1 = [JSON(true), JSON(0)]
        XCTAssertNil(JSON(arrayOfJSONBool1).array?.map(to: Bool.self))

        // array of Any Bool
        let arrayOfAnyBool: [Any] = [true, false]
        XCTAssertNotNil(JSON(arrayOfAnyBool).array?.map(to: Bool.self))
        if let array = JSON(arrayOfAnyBool).array?.map(to: Bool.self) {
            XCTAssertEqual(array, arrayOfBool)
        }
        let arrayOfAnyBool1: [Any] = [true, 0]
        XCTAssertNil(JSON(arrayOfAnyBool1).array?.map(to: Bool.self))
    }

    func testArrayOfInt() {

        XCTAssertNil(JSON("").array?.map(to: Int.self))

        // array of Int
        let arrayOfInt = [0, 1]
        XCTAssertNotNil(JSON(arrayOfInt).array?.map(to: Int.self))
        if let array = JSON(arrayOfInt).array?.map(to: Int.self) {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfInt1 = [0.0, 1.0]
        XCTAssertNotNil(JSON(arrayOfInt1).array?.map(to: Int.self))
        if let array = JSON(arrayOfInt1).array?.map(to: Int.self) {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfInt2 = [0.0, 1.1]
        XCTAssertNil(JSON(arrayOfInt2).array?.map(to: Int.self))

        // array of JSON Int
        let arrayOfJSONInt = [JSON(0), JSON(1)]
        XCTAssertNotNil(JSON(arrayOfJSONInt).array?.map(to: Int.self))
        if let array = JSON(arrayOfJSONInt).array?.map(to: Int.self) {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfJSONInt1 = [JSON(0), JSON(1.0)]
        XCTAssertNotNil(JSON(arrayOfJSONInt1).array?.map(to: Int.self))
        if let array = JSON(arrayOfJSONInt1).array?.map(to: Int.self) {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfJSONInt2 = [JSON(0), JSON(1.1)]
        XCTAssertNil(JSON(arrayOfJSONInt2).array?.map(to: Int.self))
        let arrayOfJSONInt3 = [JSON(0), JSON(true)]
        XCTAssertNil(JSON(arrayOfJSONInt3).array?.map(to: Int.self))

        // array of Any Int
        let arrayOfAnyInt: [Any] = [0, 1]
        XCTAssertNotNil(JSON(arrayOfAnyInt).array?.map(to: Int.self))
        if let array = JSON(arrayOfAnyInt).array?.map(to: Int.self) {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfAnyInt1: [Any] = [0, 1.0]
        XCTAssertNotNil(JSON(arrayOfAnyInt1).array?.map(to: Int.self))
        if let array = JSON(arrayOfAnyInt1).array?.map(to: Int.self) {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfAnyInt2: [Any] = [0, 1.1]
        XCTAssertNil(JSON(arrayOfAnyInt2).array?.map(to: Int.self))
        let arrayOfAnyInt3: [Any] = [0, true]
        XCTAssertNotNil(JSON(arrayOfAnyInt3).array)
        XCTAssertNil(JSON(arrayOfAnyInt3).array?.map(to: Int.self))
    }

    func testArrayOfDouble() {

        XCTAssertNil(JSON("").array?.map(to: Double.self))

        // array of Double
        let arrayOfDouble = [0.0, 1.0]
        XCTAssertNotNil(JSON(arrayOfDouble).array?.map(to: Double.self))
        if let array = JSON(arrayOfDouble).array?.map(to: Double.self) {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfDouble1 = [0, 1]
        XCTAssertNotNil(JSON(arrayOfDouble1).array?.map(to: Double.self))
        if let array = JSON(arrayOfDouble1).array?.map(to: Double.self) {
            XCTAssertEqual(array, arrayOfDouble)
        }

        // array of JSON Double
        let arrayOfJSONDouble = [JSON(0), JSON(1)]
        XCTAssertNotNil(JSON(arrayOfJSONDouble).array?.map(to: Double.self))
        if let array = JSON(arrayOfJSONDouble).array?.map(to: Double.self) {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfJSONDouble1 = [JSON(0), JSON(1.0)]
        XCTAssertNotNil(JSON(arrayOfJSONDouble1).array?.map(to: Double.self))
        if let array = JSON(arrayOfJSONDouble1).array?.map(to: Double.self) {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfJSONDouble2 = [JSON(0), JSON(true)]
        XCTAssertNil(JSON(arrayOfJSONDouble2).array?.map(to: Double.self))

        // array of Any Double
        let arrayOfAnyDouble: [Any] = [0, 1]
        XCTAssertNotNil(JSON(arrayOfAnyDouble).array?.map(to: Double.self))
        if let array = JSON(arrayOfAnyDouble).array?.map(to: Double.self) {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfAnyDouble1: [Any] = [0, 1.0]
        XCTAssertNotNil(JSON(arrayOfAnyDouble1).array?.map(to: Double.self))
        if let array = JSON(arrayOfAnyDouble1).array?.map(to: Double.self) {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfAnyDouble2: [Any] = [0, true]
        XCTAssertNil(JSON(arrayOfAnyDouble2).array?.map(to: Double.self))
    }

    func testArrayOfString() {

        XCTAssertNil(JSON("").array?.map(to: String.self))

        // array of String
        let arrayOfString = ["test"]
        XCTAssertNotNil(JSON(arrayOfString).array?.map(to: String.self))
        if let array = JSON(arrayOfString).array?.map(to: String.self) {
            XCTAssertEqual(array, arrayOfString)
        }

        // array of JSON String
        let arrayOfJSONString = [JSON("test")]
        XCTAssertNotNil(JSON(arrayOfJSONString).array?.map(to: String.self))
        if let array = JSON(arrayOfJSONString).array?.map(to: String.self) {
            XCTAssertEqual(array, arrayOfString)
        }
        let arrayOfJSONString1 = [JSON("test"), JSON(0)]
        XCTAssertNil(JSON(arrayOfJSONString1).array?.map(to: String.self))

        // array of Any String
        let arrayOfAnyString: [Any] = ["test"]
        XCTAssertNotNil(JSON(arrayOfAnyString).array?.map(to: String.self))
        if let array = JSON(arrayOfAnyString).array?.map(to: String.self) {
            XCTAssertEqual(array, arrayOfString)
        }
        let arrayOfAnyString1: [Any] = ["test", 0]
        XCTAssertNil(JSON(arrayOfAnyString1).array?.map(to: String.self))
    }

    func testDictionary() {

        // not dictionary
        XCTAssertNil(JSON("").dictionary)

        XCTAssertNotNil(JSON(["false": false, "true": true]).dictionary)
        XCTAssertNotNil(JSON(["0": 0, "1": 1]).dictionary)
        XCTAssertNotNil(JSON(["0": 0.0, "1": 1.1]).dictionary)
        XCTAssertNotNil(JSON(["0": "0", "1": "1"]).dictionary)

        XCTAssertNotNil(JSON(["false": JSON(false), "0": JSON(0), "1": JSON(1.1), "2": JSON("2")]).dictionary)
        XCTAssertNotNil(JSON(["false": false, "0": 0, "1": 1.1, "2": "2"]).dictionary)

        XCTAssertEqual(JSON(["false": JSON(false), "0": JSON(0)])["0"].int, 0)
        XCTAssertEqual(JSON(["false": JSON(false), "0": JSON(0)])["1"].int, nil)
        XCTAssertEqual(JSON(["false": false, "0": 0, "1": 1.1, "2": "2"])["0"].int, 0)
        XCTAssertEqual(JSON(["false": false])["0"].int, nil)
    }

    func testDictionaryOfBool() {

        XCTAssertNil(JSON("").dictionary?.map(to: Bool.self))

        // dictionary of Bool
        let dictionaryOfBool = ["true": true, "false": false]
        XCTAssertNotNil(JSON(dictionaryOfBool).dictionary?.map(to: Bool.self))
        if let dictionary = JSON(dictionaryOfBool).dictionary?.map(to: Bool.self) {
            XCTAssertEqual(dictionary, dictionaryOfBool)
        }

        // dictionary of JSON Bool
        let dictionaryOfJSONBool = ["true": JSON(true), "false": JSON(false)]
        XCTAssertNotNil(JSON(dictionaryOfJSONBool).dictionary?.map(to: Bool.self))
        if let dictionary = JSON(dictionaryOfJSONBool).dictionary?.map(to: Bool.self) {
            XCTAssertEqual(dictionary, dictionaryOfBool)
        }
        let dictionaryOfJSONBool1 = ["true": JSON(true), "0": JSON(0)]
        XCTAssertNil(JSON(dictionaryOfJSONBool1).dictionary?.map(to: Bool.self))

        // dictionary of Any Bool
        let dictionaryOfAnyBool: [String: Any] = ["true": true, "false": false]
        XCTAssertNotNil(JSON(dictionaryOfAnyBool).dictionary?.map(to: Bool.self))
        if let dictionary = JSON(dictionaryOfAnyBool).dictionary?.map(to: Bool.self) {
            XCTAssertEqual(dictionary, dictionaryOfBool)
        }
        let dictionaryOfAnyBool1: [String: Any] = ["true": true, "0": 0]
        XCTAssertNil(JSON(dictionaryOfAnyBool1).dictionary?.map(to: Bool.self))
    }

    func testDictionaryOfInt() {

        XCTAssertNil(JSON("").dictionary?.map(to: Int.self))

        // dictionary of Int
        let dictionaryOfInt = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfInt).dictionary?.map(to: Int.self))
        if let dictionary = JSON(dictionaryOfInt).dictionary?.map(to: Int.self) {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfInt1 = ["0": 0.0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfInt1).dictionary?.map(to: Int.self))
        if let dictionary = JSON(dictionaryOfInt1).dictionary?.map(to: Int.self) {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfInt2 = ["0": 0.0, "1": 1.1]
        XCTAssertNil(JSON(dictionaryOfInt2).dictionary?.map(to: Int.self))

        // dictionary of JSON Int
        let dictionaryOfJSONInt = ["0": JSON(0), "1": JSON(1)]
        XCTAssertNotNil(JSON(dictionaryOfJSONInt).dictionary?.map(to: Int.self))
        if let dictionary = JSON(dictionaryOfJSONInt).dictionary?.map(to: Int.self) {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfJSONInt1 = ["0": JSON(0), "1": JSON(1.0)]
        XCTAssertNotNil(JSON(dictionaryOfJSONInt1).dictionary?.map(to: Int.self))
        if let dictionary = JSON(dictionaryOfJSONInt1).dictionary?.map(to: Int.self) {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfJSONInt2 = ["0": JSON(0), "1": JSON(1.1)]
        XCTAssertNil(JSON(dictionaryOfJSONInt2).dictionary?.map(to: Int.self))
        let dictionaryOfJSONInt3 = ["0": JSON(0), "true": JSON(true)]
        XCTAssertNil(JSON(dictionaryOfJSONInt3).dictionary?.map(to: Int.self))

        // dictionary of Any Int
        let dictionaryOfAnyInt: [String: Any] = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfAnyInt).dictionary?.map(to: Int.self))
        if let dictionary = JSON(dictionaryOfAnyInt).dictionary?.map(to: Int.self) {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfAnyInt1: [String: Any] = ["0": 0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfAnyInt1).dictionary?.map(to: Int.self))
        if let dictionary = JSON(dictionaryOfAnyInt1).dictionary?.map(to: Int.self) {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfAnyInt2: [String: Any] = ["0": 0, "1": 1.1]
        XCTAssertNil(JSON(dictionaryOfAnyInt2).dictionary?.map(to: Int.self))
        let dictionaryOfAnyInt3: [String: Any] = ["0": 0, "true": true]
        XCTAssertNotNil(JSON(dictionaryOfAnyInt3).dictionary)
        XCTAssertNil(JSON(dictionaryOfAnyInt3).dictionary?.map(to: Int.self))
    }

    func testDictionaryOfDouble() {

        XCTAssertNil(JSON("").dictionary?.map(to: Double.self))

        // dictionary of Double
        let dictionaryOfDouble = ["0": 0.0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfDouble).dictionary?.map(to: Double.self))
        if let dictionary = JSON(dictionaryOfDouble).dictionary?.map(to: Double.self) {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfDouble1 = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfDouble1).dictionary?.map(to: Double.self))
        if let dictionary = JSON(dictionaryOfDouble1).dictionary?.map(to: Double.self) {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }

        // dictionary of JSON Double
        let dictionaryOfJSONDouble = ["0": JSON(0), "1": JSON(1)]
        XCTAssertNotNil(JSON(dictionaryOfJSONDouble).dictionary?.map(to: Double.self))
        if let dictionary = JSON(dictionaryOfJSONDouble).dictionary?.map(to: Double.self) {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfJSONDouble1 = ["0": JSON(0), "1": JSON(1.0)]
        XCTAssertNotNil(JSON(dictionaryOfJSONDouble1).dictionary?.map(to: Double.self))
        if let dictionary = JSON(dictionaryOfJSONDouble1).dictionary?.map(to: Double.self) {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfJSONDouble2 = ["0": JSON(0), "true": JSON(true)]
        XCTAssertNil(JSON(dictionaryOfJSONDouble2).dictionary?.map(to: Double.self))

        // dictionary of Any Double
        let dictionaryOfAnyDouble: [String: Any] = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfAnyDouble).dictionary?.map(to: Double.self))
        if let dictionary = JSON(dictionaryOfAnyDouble).dictionary?.map(to: Double.self) {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfAnyDouble1: [String: Any] = ["0": 0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfAnyDouble1).dictionary?.map(to: Double.self))
        if let dictionary = JSON(dictionaryOfAnyDouble1).dictionary?.map(to: Double.self) {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfAnyDouble2: [String: Any] = ["0": 0, "true": true]
        XCTAssertNil(JSON(dictionaryOfAnyDouble2).dictionary?.map(to: Double.self))
    }

    func testDictionaryOfString() {

        XCTAssertNil(JSON("").dictionary?.map(to: String.self))

        // dictionary of String
        let dictionaryOfString = ["test": "test"]
        XCTAssertNotNil(JSON(dictionaryOfString).dictionary?.map(to: String.self))
        if let dictionary = JSON(dictionaryOfString).dictionary?.map(to: String.self) {
            XCTAssertEqual(dictionary, dictionaryOfString)
        }

        // dictionary of JSON String
        let dictionaryOfJSONString = ["test": JSON("test")]
        XCTAssertNotNil(JSON(dictionaryOfJSONString).dictionary?.map(to: String.self))
        if let dictionary = JSON(dictionaryOfJSONString).dictionary?.map(to: String.self) {
            XCTAssertEqual(dictionary, dictionaryOfString)
        }
        let dictionaryOfJSONString1 = ["test": JSON("test"), "0": JSON(0)]
        XCTAssertNil(JSON(dictionaryOfJSONString1).dictionary?.map(to: String.self))

        // dictionary of Any String
        let dictionaryOfAnyString: [String: Any] = ["test": "test"]
        XCTAssertNotNil(JSON(dictionaryOfAnyString).dictionary?.map(to: String.self))
        if let dictionary = JSON(dictionaryOfAnyString).dictionary?.map(to: String.self) {
            XCTAssertEqual(dictionary, dictionaryOfString)
        }
        let dictionaryOfAnyString1: [String: Any] = ["test": "test", "0": 0]
        XCTAssertNil(JSON(dictionaryOfAnyString1).dictionary?.map(to: String.self))
    }

    func testExpressible() {
        let json: JSON = [
            "null": nil,
            "int": 1,
            "double": -1.1,
            "string1": "Foo Bar",
            "string2": "\" \t \n \r \\ \u{2665}",
            "bool": true,
            "array": [
                "1",
                2,
                nil,
                true,
                [
                    "1",
                    2,
                    nil,
                    false
                ],
                [
                    "a": "b"
                ]
            ],
            "object": [
                "a": "1",
                "b": 2,
                "c": nil,
                "d": false,
                "e": ["1", 2, nil, false],
                "f": ["1", 2, nil, true, ["1", 2, nil, false], ["a": "b"]],
                "g": ["a": "b"]
            ],
            "number": 1969
        ]

        XCTAssertEqual(json["null"].null, true)
        XCTAssertEqual(json["int"].null, false)
        XCTAssertEqual(json["null"].bool, nil)
        XCTAssertEqual(json["null"].int, nil)
        XCTAssertEqual(json["null"].double, nil)
        XCTAssertEqual(json["null"].string, nil)
        XCTAssertTrue(json["null"].array == nil)
        XCTAssertTrue(json["null"].dictionary == nil)
        XCTAssertEqual(json["string1"].string, "Foo Bar")
        XCTAssertEqual(json["string2"].string, "\" \t \n \r \\ \u{2665}")
        XCTAssertEqual(json["bool"].bool, true)
        XCTAssertEqual(json["int"].int, 1)
        XCTAssertEqual(json["int"].double, 1)
        XCTAssertEqual(json["double"].double, -1.1)
        XCTAssertEqual(json["array"][1].int, 2)
        XCTAssertEqual(json["object"]["d"].bool, false)
        XCTAssertEqual(json["object"]["e"][2].null, true)
        XCTAssertEqual(json["object"]["f"][3].bool, true)
        XCTAssertEqual(json["object"]["f"][5]["a"].string, "b")
    }

    func testDescription() {
        XCTAssertEqual(JSON(0).description, "0")
        XCTAssertEqual(JSON(InvalidObject()).description, "error: Invalid JSON object")
    }

    func testDebugDescription() {
        XCTAssertEqual(JSON([ "name": 1]).debugDescription, "{\r\n\t\"name\": 1\r\n}")
        XCTAssertEqual(JSON(InvalidObject()).debugDescription, "error: Invalid JSON object")
    }

    struct InvalidObject {}
}
