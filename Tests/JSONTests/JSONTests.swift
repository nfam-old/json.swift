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
        ("null", testNull),
        ("bool", testBool),
        ("int", testInt),
        ("double", testDouble),
        ("string", testString),
        ("array", testArray),
        ("arrayOfBool", testArrayOfBool),
        ("arrayOfInt", testArrayOfInt),
        ("arrayOfDouble", testArrayOfDouble),
        ("arrayOfString", testArrayOfString),
        ("dictionary", testDictionary),
        ("dictionaryOfBool", testDictionaryOfBool),
        ("dictionaryOfInt", testDictionaryOfInt),
        ("dictionaryOfDouble", testDictionaryOfDouble),
        ("dictionaryOfString", testDictionaryOfString),
        ("expressible", testExpressible),
        ("description", testDescription),
        ("debugDescription", testDebugDescription)
    ]

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

        XCTAssertNil(JSON("").arrayOfBool)

        // array of Bool
        let arrayOfBool = [true, false]
        XCTAssertNotNil(JSON(arrayOfBool).arrayOfBool)
        if let array = JSON(arrayOfBool).arrayOfBool {
            XCTAssertEqual(array, arrayOfBool)
        }

        // array of JSON Bool
        let arrayOfJSONBool = [JSON(true), JSON(false)]
        XCTAssertNotNil(JSON(arrayOfJSONBool).arrayOfBool)
        if let array = JSON(arrayOfJSONBool).arrayOfBool {
            XCTAssertEqual(array, arrayOfBool)
        }
        let arrayOfJSONBool1 = [JSON(true), JSON(0)]
        XCTAssertNil(JSON(arrayOfJSONBool1).arrayOfBool)

        // array of Any Bool
        let arrayOfAnyBool: [Any] = [true, false]
        XCTAssertNotNil(JSON(arrayOfAnyBool).arrayOfBool)
        if let array = JSON(arrayOfAnyBool).arrayOfBool {
            XCTAssertEqual(array, arrayOfBool)
        }
        let arrayOfAnyBool1: [Any] = [true, 0]
        XCTAssertNil(JSON(arrayOfAnyBool1).arrayOfBool)
    }

    func testArrayOfInt() {

        XCTAssertNil(JSON("").arrayOfInt)

        // array of Int
        let arrayOfInt = [0, 1]
        XCTAssertNotNil(JSON(arrayOfInt).arrayOfInt)
        if let array = JSON(arrayOfInt).arrayOfInt {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfInt1 = [0.0, 1.0]
        XCTAssertNotNil(JSON(arrayOfInt1).arrayOfInt)
        if let array = JSON(arrayOfInt1).arrayOfInt {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfInt2 = [0.0, 1.1]
        XCTAssertNil(JSON(arrayOfInt2).arrayOfInt)

        // array of JSON Int
        let arrayOfJSONInt = [JSON(0), JSON(1)]
        XCTAssertNotNil(JSON(arrayOfJSONInt).arrayOfInt)
        if let array = JSON(arrayOfJSONInt).arrayOfInt {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfJSONInt1 = [JSON(0), JSON(1.0)]
        XCTAssertNotNil(JSON(arrayOfJSONInt1).arrayOfInt)
        if let array = JSON(arrayOfJSONInt1).arrayOfInt {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfJSONInt2 = [JSON(0), JSON(1.1)]
        XCTAssertNil(JSON(arrayOfJSONInt2).arrayOfInt)
        let arrayOfJSONInt3 = [JSON(0), JSON(true)]
        XCTAssertNil(JSON(arrayOfJSONInt3).arrayOfInt)

        // array of Any Int
        let arrayOfAnyInt: [Any] = [0, 1]
        XCTAssertNotNil(JSON(arrayOfAnyInt).arrayOfInt)
        if let array = JSON(arrayOfAnyInt).arrayOfInt {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfAnyInt1: [Any] = [0, 1.0]
        XCTAssertNotNil(JSON(arrayOfAnyInt1).arrayOfInt)
        if let array = JSON(arrayOfAnyInt1).arrayOfInt {
            XCTAssertEqual(array, arrayOfInt)
        }
        let arrayOfAnyInt2: [Any] = [0, 1.1]
        XCTAssertNil(JSON(arrayOfAnyInt2).arrayOfInt)
        let arrayOfAnyInt3: [Any] = [0, true]
        XCTAssertNotNil(JSON(arrayOfAnyInt3).array)
        XCTAssertNil(JSON(arrayOfAnyInt3).arrayOfInt)
    }

    func testArrayOfDouble() {

        XCTAssertNil(JSON("").arrayOfDouble)

        // array of Double
        let arrayOfDouble = [0.0, 1.0]
        XCTAssertNotNil(JSON(arrayOfDouble).arrayOfDouble)
        if let array = JSON(arrayOfDouble).arrayOfDouble {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfDouble1 = [0, 1]
        XCTAssertNotNil(JSON(arrayOfDouble1).arrayOfDouble)
        if let array = JSON(arrayOfDouble1).arrayOfDouble {
            XCTAssertEqual(array, arrayOfDouble)
        }

        // array of JSON Double
        let arrayOfJSONDouble = [JSON(0), JSON(1)]
        XCTAssertNotNil(JSON(arrayOfJSONDouble).arrayOfDouble)
        if let array = JSON(arrayOfJSONDouble).arrayOfDouble {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfJSONDouble1 = [JSON(0), JSON(1.0)]
        XCTAssertNotNil(JSON(arrayOfJSONDouble1).arrayOfDouble)
        if let array = JSON(arrayOfJSONDouble1).arrayOfDouble {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfJSONDouble2 = [JSON(0), JSON(true)]
        XCTAssertNil(JSON(arrayOfJSONDouble2).arrayOfDouble)

        // array of Any Double
        let arrayOfAnyDouble: [Any] = [0, 1]
        XCTAssertNotNil(JSON(arrayOfAnyDouble).arrayOfDouble)
        if let array = JSON(arrayOfAnyDouble).arrayOfDouble {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfAnyDouble1: [Any] = [0, 1.0]
        XCTAssertNotNil(JSON(arrayOfAnyDouble1).arrayOfDouble)
        if let array = JSON(arrayOfAnyDouble1).arrayOfDouble {
            XCTAssertEqual(array, arrayOfDouble)
        }
        let arrayOfAnyDouble2: [Any] = [0, true]
        XCTAssertNil(JSON(arrayOfAnyDouble2).arrayOfDouble)
    }

    func testArrayOfString() {

        XCTAssertNil(JSON("").arrayOfString)

        // array of String
        let arrayOfString = ["test"]
        XCTAssertNotNil(JSON(arrayOfString).arrayOfString)
        if let array = JSON(arrayOfString).arrayOfString {
            XCTAssertEqual(array, arrayOfString)
        }

        // array of JSON String
        let arrayOfJSONString = [JSON("test")]
        XCTAssertNotNil(JSON(arrayOfJSONString).arrayOfString)
        if let array = JSON(arrayOfJSONString).arrayOfString {
            XCTAssertEqual(array, arrayOfString)
        }
        let arrayOfJSONString1 = [JSON("test"), JSON(0)]
        XCTAssertNil(JSON(arrayOfJSONString1).arrayOfString)

        // array of Any String
        let arrayOfAnyString: [Any] = ["test"]
        XCTAssertNotNil(JSON(arrayOfAnyString).arrayOfString)
        if let array = JSON(arrayOfAnyString).arrayOfString {
            XCTAssertEqual(array, arrayOfString)
        }
        let arrayOfAnyString1: [Any] = ["test", 0]
        XCTAssertNil(JSON(arrayOfAnyString1).arrayOfString)
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

        XCTAssertNil(JSON("").dictionaryOfBool)

        // dictionary of Bool
        let dictionaryOfBool = ["true": true, "false": false]
        XCTAssertNotNil(JSON(dictionaryOfBool).dictionaryOfBool)
        if let dictionary = JSON(dictionaryOfBool).dictionaryOfBool {
            XCTAssertEqual(dictionary, dictionaryOfBool)
        }

        // dictionary of JSON Bool
        let dictionaryOfJSONBool = ["true": JSON(true), "false": JSON(false)]
        XCTAssertNotNil(JSON(dictionaryOfJSONBool).dictionaryOfBool)
        if let dictionary = JSON(dictionaryOfJSONBool).dictionaryOfBool {
            XCTAssertEqual(dictionary, dictionaryOfBool)
        }
        let dictionaryOfJSONBool1 = ["true": JSON(true), "0": JSON(0)]
        XCTAssertNil(JSON(dictionaryOfJSONBool1).dictionaryOfBool)

        // dictionary of Any Bool
        let dictionaryOfAnyBool: [String: Any] = ["true": true, "false": false]
        XCTAssertNotNil(JSON(dictionaryOfAnyBool).dictionaryOfBool)
        if let dictionary = JSON(dictionaryOfAnyBool).dictionaryOfBool {
            XCTAssertEqual(dictionary, dictionaryOfBool)
        }
        let dictionaryOfAnyBool1: [String: Any] = ["true": true, "0": 0]
        XCTAssertNil(JSON(dictionaryOfAnyBool1).dictionaryOfBool)
    }

    func testDictionaryOfInt() {

        XCTAssertNil(JSON("").dictionaryOfInt)

        // dictionary of Int
        let dictionaryOfInt = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfInt).dictionaryOfInt)
        if let dictionary = JSON(dictionaryOfInt).dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfInt1 = ["0": 0.0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfInt1).dictionaryOfInt)
        if let dictionary = JSON(dictionaryOfInt1).dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfInt2 = ["0": 0.0, "1": 1.1]
        XCTAssertNil(JSON(dictionaryOfInt2).dictionaryOfInt)

        // dictionary of JSON Int
        let dictionaryOfJSONInt = ["0": JSON(0), "1": JSON(1)]
        XCTAssertNotNil(JSON(dictionaryOfJSONInt).dictionaryOfInt)
        if let dictionary = JSON(dictionaryOfJSONInt).dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfJSONInt1 = ["0": JSON(0), "1": JSON(1.0)]
        XCTAssertNotNil(JSON(dictionaryOfJSONInt1).dictionaryOfInt)
        if let dictionary = JSON(dictionaryOfJSONInt1).dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfJSONInt2 = ["0": JSON(0), "1": JSON(1.1)]
        XCTAssertNil(JSON(dictionaryOfJSONInt2).dictionaryOfInt)
        let dictionaryOfJSONInt3 = ["0": JSON(0), "true": JSON(true)]
        XCTAssertNil(JSON(dictionaryOfJSONInt3).dictionaryOfInt)

        // dictionary of Any Int
        let dictionaryOfAnyInt: [String: Any] = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfAnyInt).dictionaryOfInt)
        if let dictionary = JSON(dictionaryOfAnyInt).dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfAnyInt1: [String: Any] = ["0": 0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfAnyInt1).dictionaryOfInt)
        if let dictionary = JSON(dictionaryOfAnyInt1).dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionaryOfInt)
        }
        let dictionaryOfAnyInt2: [String: Any] = ["0": 0, "1": 1.1]
        XCTAssertNil(JSON(dictionaryOfAnyInt2).dictionaryOfInt)
        let dictionaryOfAnyInt3: [String: Any] = ["0": 0, "true": true]
        XCTAssertNotNil(JSON(dictionaryOfAnyInt3).dictionary)
        XCTAssertNil(JSON(dictionaryOfAnyInt3).dictionaryOfInt)
    }

    func testDictionaryOfDouble() {

        XCTAssertNil(JSON("").dictionaryOfDouble)

        // dictionary of Double
        let dictionaryOfDouble = ["0": 0.0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfDouble).dictionaryOfDouble)
        if let dictionary = JSON(dictionaryOfDouble).dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfDouble1 = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfDouble1).dictionaryOfDouble)
        if let dictionary = JSON(dictionaryOfDouble1).dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }

        // dictionary of JSON Double
        let dictionaryOfJSONDouble = ["0": JSON(0), "1": JSON(1)]
        XCTAssertNotNil(JSON(dictionaryOfJSONDouble).dictionaryOfDouble)
        if let dictionary = JSON(dictionaryOfJSONDouble).dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfJSONDouble1 = ["0": JSON(0), "1": JSON(1.0)]
        XCTAssertNotNil(JSON(dictionaryOfJSONDouble1).dictionaryOfDouble)
        if let dictionary = JSON(dictionaryOfJSONDouble1).dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfJSONDouble2 = ["0": JSON(0), "true": JSON(true)]
        XCTAssertNil(JSON(dictionaryOfJSONDouble2).dictionaryOfDouble)

        // dictionary of Any Double
        let dictionaryOfAnyDouble: [String: Any] = ["0": 0, "1": 1]
        XCTAssertNotNil(JSON(dictionaryOfAnyDouble).dictionaryOfDouble)
        if let dictionary = JSON(dictionaryOfAnyDouble).dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfAnyDouble1: [String: Any] = ["0": 0, "1": 1.0]
        XCTAssertNotNil(JSON(dictionaryOfAnyDouble1).dictionaryOfDouble)
        if let dictionary = JSON(dictionaryOfAnyDouble1).dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionaryOfDouble)
        }
        let dictionaryOfAnyDouble2: [String: Any] = ["0": 0, "true": true]
        XCTAssertNil(JSON(dictionaryOfAnyDouble2).dictionaryOfDouble)
    }

    func testDictionaryOfString() {

        XCTAssertNil(JSON("").dictionaryOfString)

        // dictionary of String
        let dictionaryOfString = ["test": "test"]
        XCTAssertNotNil(JSON(dictionaryOfString).dictionaryOfString)
        if let dictionary = JSON(dictionaryOfString).dictionaryOfString {
            XCTAssertEqual(dictionary, dictionaryOfString)
        }

        // dictionary of JSON String
        let dictionaryOfJSONString = ["test": JSON("test")]
        XCTAssertNotNil(JSON(dictionaryOfJSONString).dictionaryOfString)
        if let dictionary = JSON(dictionaryOfJSONString).dictionaryOfString {
            XCTAssertEqual(dictionary, dictionaryOfString)
        }
        let dictionaryOfJSONString1 = ["test": JSON("test"), "0": JSON(0)]
        XCTAssertNil(JSON(dictionaryOfJSONString1).dictionaryOfString)

        // dictionary of Any String
        let dictionaryOfAnyString: [String: Any] = ["test": "test"]
        XCTAssertNotNil(JSON(dictionaryOfAnyString).dictionaryOfString)
        if let dictionary = JSON(dictionaryOfAnyString).dictionaryOfString {
            XCTAssertEqual(dictionary, dictionaryOfString)
        }
        let dictionaryOfAnyString1: [String: Any] = ["test": "test", "0": 0]
        XCTAssertNil(JSON(dictionaryOfAnyString1).dictionaryOfString)
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
