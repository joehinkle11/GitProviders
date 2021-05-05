import XCTest
@testable import GitProviders

final class GitProvidersTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(GitProviders().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
