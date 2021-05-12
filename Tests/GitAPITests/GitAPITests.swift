import XCTest
@testable import GitAPI

final class GitAPITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FakeCreds.shared.get(.GitHubUsername), "joehinkle11@gmail.com")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
