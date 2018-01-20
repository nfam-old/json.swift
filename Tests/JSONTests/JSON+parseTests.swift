//
//  JSONParseTests.swift
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

func assertThrows(
    _ expression: @autoclosure () throws -> JSON,
    _ errorDescription: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertThrowsError(try expression(), file: file, line: line) { error in
        if let error = error as? JSON.Error {
             XCTAssertEqual(error.description, errorDescription, file: file, line: line)
        } else {
            XCTFail("\((error))", file: file, line: line)
        }
    }
}

func assertNoThrow(
    _ expression: @autoclosure () throws -> JSON,
    file: StaticString = #file,
    line: UInt = #line,
    completion: (JSON) -> Void
) {
    var json: JSON?
    do {
        json = try expression()
    } catch {
        XCTFail("\((error))", file: file, line: line)
    }
    if let json = json {
        completion(json)
    }
}

class JSONParseTests: XCTestCase {

    static var allTests = [
        ("document", testDocument),
        ("null", testNull),
        ("bool", testBool),
        ("int", testInt),
        ("double", testDouble),
        ("string", testString),
        ("array", testArray),
        ("dictionary", testDictionary)
    ]

    func testDocument() {
        assertThrows(try JSON.parse(string: ""), "Empty document")
        assertThrows(try JSON.parse(string: "  "), "Empty document")
        assertThrows(try JSON.parse(string: "+  "), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: " + "), "Unexpected token at (1,2)")
        assertThrows(try JSON.parse(string: " a "), "Unexpected token at (1,2)")
    }

    func testNull() {
        assertNoThrow(try JSON.parse(bytes: "null".makeBytes())) { json in
            XCTAssertTrue(json.null)
        }
        assertNoThrow(try JSON.parse(string: "null")) { json in
            XCTAssertTrue(json.null)
        }
        assertNoThrow(try JSON.parse(string: "null ")) { json in
            XCTAssertTrue(json.null)
        }
        assertNoThrow(try JSON.parse(string: " null")) { json in
            XCTAssertTrue(json.null)
        }
        assertNoThrow(try JSON.parse(string: "null ")) { json in
            XCTAssertTrue(json.null)
        }
        assertThrows(try JSON.parse(string: "null+"), "Unexpected token at (1,5)")
        assertThrows(try JSON.parse(string: "null +"), "Unexpected token at (1,6)")
    }

    func testBool() {
        assertNoThrow(try JSON.parse(string: "true")) { json in
            XCTAssertEqual(json.bool, true)
        }
        assertNoThrow(try JSON.parse(string: "false ")) { json in
            XCTAssertEqual(json.bool, false)
        }
        assertNoThrow(try JSON.parse(string: " true")) { json in
            XCTAssertEqual(json.bool, true)
        }
        assertNoThrow(try JSON.parse(string: "false ")) { json in
            XCTAssertEqual(json.bool, false)
        }
        assertThrows(try JSON.parse(string: "true+"), "Unexpected token at (1,5)")
        assertThrows(try JSON.parse(string: "false +"), "Unexpected token at (1,7)")
    }

    func testInt() {
        assertNoThrow(try JSON.parse(string: "12345")) { json in
            XCTAssertEqual(json.int, 12345)
        }
        assertNoThrow(try JSON.parse(string: "12345.0 ")) { json in
            XCTAssertEqual(json.int, 12345)
        }
        assertNoThrow(try JSON.parse(string: "-12345")) { json in
            XCTAssertEqual(json.int, -12345)
        }
        assertNoThrow(try JSON.parse(string: " 12345")) { json in
            XCTAssertEqual(json.int, 12345)
        }
        assertNoThrow(try JSON.parse(string: " -12345")) { json in
            XCTAssertEqual(json.int, -12345)
        }
        assertNoThrow(try JSON.parse(string: " 12345 ")) { json in
            XCTAssertEqual(json.int, 12345)
        }
        assertNoThrow(try JSON.parse(string: " -12345 ")) { json in
            XCTAssertEqual(json.int, -12345)
        }
        assertThrows(try JSON.parse(string: "+12345"), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: "-"), "Invalid number syntax at (1,1)")
        assertThrows(try JSON.parse(string: "12345-"), "Invalid number syntax at (1,6)")
        assertThrows(try JSON.parse(string: "12345 -"), "Unexpected token at (1,7)")
        assertThrows(try JSON.parse(string: "12+345"), "Invalid number syntax at (1,3)")
    }

    func testDouble() {
        assertNoThrow(try JSON.parse(string: "12345")) { json in
            XCTAssertEqual(json.double, 12345)
        }
        assertNoThrow(try JSON.parse(string: "12345.1 ")) { json in
            XCTAssertEqual(json.double, 12345.1)
        }
        assertNoThrow(try JSON.parse(string: "-12345.1")) { json in
            XCTAssertEqual(json.double, -12345.1)
        }
        assertNoThrow(try JSON.parse(string: " 12345.1")) { json in
            XCTAssertEqual(json.double, 12345.1)
        }
        assertNoThrow(try JSON.parse(string: " -12345.1")) { json in
            XCTAssertEqual(json.double, -12345.1)
        }
        assertNoThrow(try JSON.parse(string: " 12345.1 ")) { json in
            XCTAssertEqual(json.double, 12345.1)
        }
        assertNoThrow(try JSON.parse(string: " -12345 ")) { json in
            XCTAssertEqual(json.double, -12345)
        }
        assertThrows(try JSON.parse(string: "1234."), "Invalid number syntax at (1,5)")
        assertThrows(try JSON.parse(string: "1234.-"), "Invalid number syntax at (1,6)")
        assertThrows(try JSON.parse(string: "123.4 -"), "Unexpected token at (1,7)")
        assertThrows(try JSON.parse(string: "12.3.4"), "Invalid number syntax at (1,5)")
    }

    func testString() {
        assertNoThrow(try JSON.parse(string: "\"test\"")) { json in
            XCTAssertEqual(json.string, "test")
        }
        assertNoThrow(try JSON.parse(string: "\"test\" ")) { json in
            XCTAssertEqual(json.string, "test")
        }
        assertNoThrow(try JSON.parse(string: " \"test\"")) { json in
            XCTAssertEqual(json.string, "test")
        }
        assertNoThrow(try JSON.parse(string: " \"test\\m\"")) { json in
            XCTAssertEqual(json.string, "testm")
        }
        assertNoThrow(try JSON.parse(string: "\"test\\\"\\\\?\\/\\b\\v\\f\\n\\r\\t\"")) { json in
            XCTAssertEqual(json.string, "test\"\\?/\u{08}\u{0b}\u{0c}\n\r\t")
        }
        assertNoThrow(try JSON.parse(string: " \"\\9\"")) { json in
            XCTAssertEqual(json.string, "\t")
        }
        assertNoThrow(try JSON.parse(string: " \"\\10\"")) { json in
            XCTAssertEqual(json.string, "\n")
        }
        assertNoThrow(try JSON.parse(string: " \"\\101\"")) { json in
            XCTAssertEqual(json.string, "e")
        }
        assertNoThrow(try JSON.parse(string: " \"\\x65\"")) { json in
            XCTAssertEqual(json.string, "e")
        }
        assertNoThrow(try JSON.parse(string: " \"\\u0065\"")) { json in
            XCTAssertEqual(json.string, "e")
        }
        assertThrows(try JSON.parse(string: "\"test\"+"), "Unexpected token at (1,7)")
        assertThrows(try JSON.parse(string: "\"test\" +"), "Unexpected token at (1,8)")
        assertThrows(try JSON.parse(string: "\"test"), "Unclosed string")
        assertThrows(try JSON.parse(string: "\"test\\"), "Unclosed string")
        assertThrows(try JSON.parse(string: "\"test\\x"), "Invalid escape syntax at (1,7)")
        assertThrows(try JSON.parse(string: "\"test\\x0"), "Invalid escape syntax at (1,8)")
        assertThrows(try JSON.parse(string: "\"test\\x0 "), "Invalid escape syntax at (1,8)")
        assertThrows(try JSON.parse(string: "\"test\\u"), "Invalid escape syntax at (1,7)")
        assertThrows(try JSON.parse(string: "\"test\\u0"), "Invalid escape syntax at (1,8)")
        assertThrows(try JSON.parse(string: "\"test\\u0a"), "Invalid escape syntax at (1,8)")
        assertThrows(try JSON.parse(string: "\"test\\u0ab"), "Invalid escape syntax at (1,8)")
        assertThrows(try JSON.parse(string: "\"test\\u0ab "), "Invalid escape syntax at (1,8)")
        assertThrows(try JSON.parse(string: "[\"test"), "Unclosed string")
        assertThrows(try JSON.parse(string: "{\"test"), "Unclosed string")
        assertThrows(try JSON.parse(string: "{\"test\":\"x"), "Unclosed string")
        assertThrows(try JSON.parse(string: "\"\\ua"), "Invalid escape syntax at (1,4)")
        assertThrows(try JSON.parse(string: "\"\\u123456789"), "Unclosed string")
    }

    func testArray() {
        assertNoThrow(try JSON.parse(string: "[12]")) { json in
            XCTAssertEqual(json.arrayOfInt ?? [], [12])
        }
        assertThrows(try JSON.parse(string: "[12"), "Unclosed array")
        assertThrows(try JSON.parse(string: "[12 "), "Unclosed array")
        assertThrows(try JSON.parse(string: "[12,"), "Unclosed array")
        assertThrows(try JSON.parse(string: "[12, "), "Unclosed array")
        assertThrows(try JSON.parse(string: "[\n+12"), "Unexpected token at (2,1)")
        assertThrows(try JSON.parse(string: "[12\n+"), "Unexpected token at (2,1)")
        assertThrows(try JSON.parse(string: "[1] \na"), "Unexpected token at (2,1)")
    }

    func testDictionary() {
        assertNoThrow(try JSON.parse(string: "{\"1\":1, \"2\":2 }" )) { json in
            XCTAssertEqual(json.dictionaryOfInt ?? [:], ["1":1, "2": 2])
        }

        assertThrows(try JSON.parse(string: "{"), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{ "), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{name"), "Unexpected token at (1,2)")
        assertThrows(try JSON.parse(string: "{\"name\""), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{\"name\" "), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{\"name\":"), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{\"name\"x"), "Unexpected token at (1,8)")
        assertThrows(try JSON.parse(string: "{\"name\":\"value\""), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{\"name\":\"value\""), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{\"name\":\"value\""), "Unclosed dictionary")
        assertThrows(try JSON.parse(string: "{\"name\":\"value\"\nx"), "Unexpected token at (2,1)")
        assertThrows(try JSON.parse(string: "{\n\"a\":+12"), "Unexpected token at (2,5)")
        assertThrows(try JSON.parse(string: "{\"\n\"+12"), "Unexpected token at (2,2)")
        assertThrows(try JSON.parse(string: "{\"a\"\n+12"), "Unexpected token at (2,1)")
        assertThrows(try JSON.parse(string: "{\"a\"\n:+12"), "Unexpected token at (2,2)")
        assertThrows(try JSON.parse(string: "{\"a\":\n+12"), "Unexpected token at (2,1)")
        assertThrows(try JSON.parse(string: "{\"a\":true\n+12"), "Unexpected token at (2,1)")
    }
}
