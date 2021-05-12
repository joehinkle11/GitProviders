import XCTest

import GitAPITests

var tests = [XCTestCaseEntry]()
tests += GitAPITests.allTests()
XCTMain(tests)
