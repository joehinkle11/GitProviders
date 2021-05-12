import XCTest
@testable import GitAPI

final class GitAPITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("GitProviders().text", "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
