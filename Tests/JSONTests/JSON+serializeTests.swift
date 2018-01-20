//
//  JSONTests.swift
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

class JSONSerializeTests: XCTestCase {

    static var allTests = [
        ("null", testNull),
        ("bool", testBool),
        ("int", testInt),
        ("double", testDouble),
        ("string", testString),
        ("array", testArray),
        ("dictionary", testDictionary),
        ("invalidJSON", testInvalidJSON)
    ]

    func testNull() {
        XCTAssertEqual(JSON().stringified(), "null")
        XCTAssertEqual(JSON().stringified(pretty: true), "null")
    }

    func testBool() {
        XCTAssertEqual(JSON(true).stringified(), "true")
        XCTAssertEqual(JSON(false).stringified(), "false")
        XCTAssertEqual(JSON(true).stringified(pretty: true), "true")
        XCTAssertEqual(JSON(false).stringified(pretty: true), "false")
    }

    func testInt() {
        XCTAssertEqual(JSON(1).stringified(), "1")
        XCTAssertEqual(JSON(1).serialized()?.makeString(), "1")
        XCTAssertEqual(JSON(-1).stringified(), "-1")
        XCTAssertEqual(JSON(1).stringified(pretty: true), "1")
    }

    func testDouble() {
        XCTAssertEqual(JSON(1.1).stringified(), "1.1")
        XCTAssertEqual(JSON(1.1).stringified(pretty: true), "1.1")
    }

    func testString() {
        let string1 = "test\"\\?/\u{08}\u{0b}\u{0c}\n\r\t"
        let string2 = "\"test\\\"\\\\?\\/\\b\\v\\f\\n\\r\\t\""
        XCTAssertEqual(JSON(string1).stringified(), string2)
        XCTAssertEqual(JSON(string1).stringified(pretty: true), string2)
    }

    func testArray() {
        let json: JSON = [false, 0, 1.1, "2"]
        let array: [Any] = [false, 0, 1.1, "2"]
        XCTAssertEqual(json.stringified(),
            "[false,0,1.1,\"2\"]")
        XCTAssertEqual(JSON(array).stringified(),
            "[false,0,1.1,\"2\"]")
        XCTAssertEqual(json.stringified(pretty: true),
            "[\r\n\tfalse,\r\n\t0,\r\n\t1.1,\r\n\t\"2\"\r\n]")
        XCTAssertEqual(JSON(array).stringified(pretty: true),
            "[\r\n\tfalse,\r\n\t0,\r\n\t1.1,\r\n\t\"2\"\r\n]")
    }

    func testDictionary() {
        let json: JSON = ["0": 0, "1.1": 1.1, "2": "2", "false": false]
        let dictionary: [String: Any] = ["0": 0, "1.1": 1.1, "2": "2", "false": false]
        XCTAssertEqual(json.stringified(),
            "{\"0\":0,\"1.1\":1.1,\"2\":\"2\",\"false\":false}")
        XCTAssertEqual(JSON(dictionary).stringified(),
            "{\"0\":0,\"1.1\":1.1,\"2\":\"2\",\"false\":false}")
        XCTAssertEqual(json.stringified(pretty: true),
            "{\r\n\t\"0\": 0,\r\n\t\"1.1\": 1.1,\r\n\t\"2\": \"2\",\r\n\t\"false\": false\r\n}")
        XCTAssertEqual(JSON(dictionary).stringified(pretty: true),
            "{\r\n\t\"0\": 0,\r\n\t\"1.1\": 1.1,\r\n\t\"2\": \"2\",\r\n\t\"false\": false\r\n}")
    }

    func testInvalidJSON() {
        XCTAssertNil(JSON(InvalidObject()).serialized())
        XCTAssertNil(JSON([InvalidObject()]).serialized())
        XCTAssertNil(JSON([JSON(InvalidObject())]).serialized())
        XCTAssertNil(JSON(["invalid": InvalidObject()]).serialized())
        XCTAssertNil(JSON(["invalid": JSON(InvalidObject())]).serialized())

        XCTAssertNil(JSON(InvalidObject()).stringified())
        XCTAssertNil(JSON([InvalidObject()]).stringified())
        XCTAssertNil(JSON([JSON(InvalidObject())]).stringified())
        XCTAssertNil(JSON(["invalid": InvalidObject()]).stringified())
        XCTAssertNil(JSON(["invalid": JSON(InvalidObject())]).stringified())
    }

    struct InvalidObject {}
}
