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
        if let error = error as? JSON.ParsingError {
             XCTAssertEqual(error.description, errorDescription, file: file, line: line)
             XCTAssertEqual(error.debugDescription, errorDescription, file: file, line: line)
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
        ("testDocument", testDocument),
        ("testNull", testNull),
        ("testBool", testBool),
        ("testNumber", testNumber),
        ("testString", testString),
        ("testArray", testArray),
        ("testDictionary", testDictionary)
    ]

    func testDocument() {
        assertThrows(try JSON.parse(string: ""), "Empty document")
        assertThrows(try JSON.parse(string: "  "), "Empty document")
        assertThrows(try JSON.parse(string: "+  "), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: " + "), "Unexpected token at (1,2)")
        assertThrows(try JSON.parse(string: " a "), "Unexpected token at (1,2)")
    }

    func testNull() {
        assertNoThrow(try JSON.parse(bytes: [UInt8]("null".utf8))) { json in
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
        assertThrows(try JSON.parse(string: "trueA"), "Unexpected token at (1,5)")
        assertThrows(try JSON.parse(string: "false A"), "Unexpected token at (1,7)")
    }

    func testNumber() {
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

        // [ minus ] int
        assertThrows(try JSON.parse(string: "+"), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: "-"), "Invalid number syntax at (1,1)")
        assertThrows(try JSON.parse(string: "+0"), "Unexpected token at (1,1)")
        assertNoThrow(try JSON.parse(string: "0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertThrows(try JSON.parse(string: "-0"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "00"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "01"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "+10"), "Unexpected token at (1,1)")
        assertNoThrow(try JSON.parse(string: "10")) { json in
            XCTAssertEqual(json.int, 10)
            XCTAssertEqual(json.double, 10.0)
        }
        assertNoThrow(try JSON.parse(string: " 10 ")) { json in
            XCTAssertEqual(json.int, 10)
            XCTAssertEqual(json.double, 10.0)
        }
        assertNoThrow(try JSON.parse(string: "-10")) { json in
            XCTAssertEqual(json.int, -10)
            XCTAssertEqual(json.double, -10.0)
        }
        assertNoThrow(try JSON.parse(string: " -10 ")) { json in
            XCTAssertEqual(json.int, -10)
            XCTAssertEqual(json.double, -10.0)
        }
        assertThrows(try JSON.parse(string: "10-"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10A"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10+"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10-2"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10+3"), "Invalid number syntax at (1,3)")

        assertThrows(try JSON.parse(string: "9999999999999999999999999999999999"), "Invalid number syntax at (1,1)")

        // [ minus ] int [ frac ]
        assertThrows(try JSON.parse(string: "0."), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "00."), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "01."), "Invalid number syntax at (1,2)")
        assertNoThrow(try JSON.parse(string: "0.00")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.10")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 0.1)
        }
        assertThrows(try JSON.parse(string: "12."), "Invalid number syntax at (1,3)")
        assertNoThrow(try JSON.parse(string: "12.00")) { json in
            XCTAssertEqual(json.int, 12)
            XCTAssertEqual(json.double, 12.0)
        }
        assertNoThrow(try JSON.parse(string: "12.1")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 12.1)
        }
        assertThrows(try JSON.parse(string: "12.1."), "Invalid number syntax at (1,5)")

        // [ minus ] int [ frac ] [ exp ]
        assertThrows(try JSON.parse(string: "-e"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "-E"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "1e"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "1E"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "1.e"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1.E"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1e+"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1E+"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1e-"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1E-"), "Invalid number syntax at (1,3)")
        assertNoThrow(try JSON.parse(string: "0e+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0E+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0e-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0E-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0e+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0E+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0e-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0E-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "1e+0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1e-0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1.0e+0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1.0e-0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1.1E-00")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 1.1)
        }
        assertNoThrow(try JSON.parse(string: "1.1E-01")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 0.11)
        }
        assertNoThrow(try JSON.parse(string: "1.1E+01")) { json in
            XCTAssertEqual(json.int, 11)
            XCTAssertEqual(json.double, 11.0)
        }
    }

    func testString() {
        assertNoThrow(try JSON.parse(string: "\"test\"")) { json in
            XCTAssertEqual(json.string, "test")
        }
        assertNoThrow(try JSON.parse(string: "\"test\" ")) { json in
            XCTAssertEqual(json.string, "test")
        }
        assertNoThrow(try JSON.parse(string: "\" \\\" \\/ \\b \\f \\n \\r \\t \"")) { json in
            XCTAssertEqual(json.string, " \" / \u{8} \u{C} \n \r \t ")
        }
        assertNoThrow(try JSON.parse(string: " \"\\u0065\"")) { json in
            XCTAssertEqual(json.string, "e")
        }
        assertNoThrow(try JSON.parse(string: " \"\\u0165\"")) { json in
            XCTAssertEqual(json.string, "\u{165}")
        }
        assertNoThrow(try JSON.parse(string: " \"a \\u0000 b\"")) { json in
            XCTAssertEqual(json.string, "a \u{0} b")
        }
        assertNoThrow(try JSON.parse(string: " \"\\u00657\"")) { json in
            XCTAssertEqual(json.string, "e7")
        }
        assertNoThrow(try JSON.parse(string: " \"\\uD834\\uDD1E\"")) { json in
            XCTAssertEqual(json.string, "\u{1D11E}")
        }
        assertNoThrow(try JSON.parse(string: " \"\\ud834\\udd1e\"")) { json in
            XCTAssertEqual(json.string, "\u{1D11E}")
        }
        assertThrows(try JSON.parse(string: "\"\\uD834\""), "Unpaired escaped surrogate at (1,4)")
        assertThrows(try JSON.parse(string: "\"\\uD834\\uD834\""), "Unpaired escaped surrogate at (1,4)")
        assertThrows(try JSON.parse(string: "\"\\uD834\\u0020\""), "Unpaired escaped surrogate at (1,4)")
        assertThrows(try JSON.parse(string: "\"\\uD834\\n\""), "Unpaired escaped surrogate at (1,4)")
        assertThrows(try JSON.parse(string: "\"\\uD834\\uDD1E\\uD834\""), "Unpaired escaped surrogate at (1,16)")
        assertThrows(try JSON.parse(string: "\"\\uD834\\uDD1E\\uDD1E\""), "Unpaired escaped surrogate at (1,16)")

        assertThrows(try JSON.parse(string: "\"test\"+"), "Unexpected token at (1,7)")
        assertThrows(try JSON.parse(string: "\"test\" +"), "Unexpected token at (1,8)")
        assertThrows(try JSON.parse(string: "\"test"), "Unclosed string")
        assertThrows(try JSON.parse(string: "\"test\\"), "Unclosed string")
        assertThrows(try JSON.parse(string: "\"test\n\""), "Invalid character at (1,6)")
        assertThrows(try JSON.parse(string: "\"test\\20"), "Invalid escape syntax at (1,7)")
        assertThrows(try JSON.parse(string: "\"test\\x20"), "Invalid escape syntax at (1,7)")
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

        // utf8
        assertThrows(try JSON.parse(bytes: [0x22, 0xC2]), "Unclosed string")
        assertNoThrow(try JSON.parse(bytes: [0x22, 0xC2, 0xA9, 0x22])) { json in
            XCTAssertEqual(json.string, "©")
        }
        assertThrows(try JSON.parse(bytes: [0x22, 0xC0, 0x00, 0x22]), "Invalid character at (1,2)")

        assertThrows(try JSON.parse(bytes: [0x22, 0xE2, 0x98]), "Unclosed string")
        assertNoThrow(try JSON.parse(bytes: [0x22, 0xE2, 0x98, 0x83, 0x22])) { json in
            XCTAssertEqual(json.string, "☃")
        }
         assertThrows(try JSON.parse(bytes: [0x22, 0xED, 0xA0, 0x81, 0x22]), "Invalid character at (1,2)")

        assertThrows(try JSON.parse(bytes: [0x22, 0xF0, 0x9D, 0x8C]), "Unclosed string")
        assertNoThrow(try JSON.parse(bytes: [0x22, 0xF0, 0x9D, 0x8C, 0x86, 0x22])) { json in
            XCTAssertEqual(json.string, "𝌆")
        }
         assertThrows(try JSON.parse(bytes: [0x22, 247, 191, 191, 191, 0x22]), "Invalid character at (1,2)")
    }

    func testArray() {
        assertNoThrow(try JSON.parse(string: "[12]")) { json in
            XCTAssertEqual(json.array?.map(to: Int.self) ?? [], [12])
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
            XCTAssertEqual(json.dictionary?.map(to: Int.self) ?? [:], ["1": 1, "2": 2])
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
        assertThrows(try JSON.parse(string: "{\"a\"+12"), "Unexpected token at (1,5)")
        assertThrows(try JSON.parse(string: "{\"a\"\n+12"), "Unexpected token at (2,1)")
        assertThrows(try JSON.parse(string: "{\"a\"\n:+12"), "Unexpected token at (2,2)")
        assertThrows(try JSON.parse(string: "{\"a\":\n+12"), "Unexpected token at (2,1)")
        assertThrows(try JSON.parse(string: "{\"a\":true\n+12"), "Unexpected token at (2,1)")
    }
}
