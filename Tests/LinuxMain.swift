//
//  LinuxMain.swift
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSONTests
import XCTest

XCTMain([
    testCase(JSONTests.allTests),
    testCase(JSONParseTests.allTests),
    testCase(JSONSerializeTests.allTests)
])
