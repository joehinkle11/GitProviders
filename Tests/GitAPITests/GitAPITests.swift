import XCTest
@testable import GitAPI

final class GitAPITests: XCTestCase {
    func testEachAPI(testBlock: (GitAPI) -> Void) {
        testBlock(GitHubAPI.shared)
//        testBlock(BitBucketAPI.shared)
//        testBlock(GitLabAPI.shared)
    }
    
    
    func testScopes() {
        testEachAPI { gitAPI in
            let expectation = XCTestExpectation()
            gitAPI.fetchGrantedScopes { (scopes: [String]?, error: Error?) in
                XCTAssertEqual(FakeCreds.shared.get(.GitHubUsername), "joehinkle11")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    static var allTests: [(String, (GitAPITests) -> () -> ())] = []
}
