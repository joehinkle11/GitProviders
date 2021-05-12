import XCTest
@testable import GitAPI

final class GitAPITests: XCTestCase {
    func testEachAPIUnauthenticated(testBlock: (GitAPI) -> Void) {
        GitHubAPI.shared.userInfo = nil
        testBlock(GitHubAPI.shared)
//        BitBucketAPI.shared.authToken = nil
//        testBlock(BitBucketAPI.shared)
//        GitLabAPI.shared.authToken = nil
//        testBlock(GitLabAPI.shared)
    }
    
    func testEachAPIAuthenticatedWithoutPermissions(testBlock: (GitAPI) -> Void) {
        GitHubAPI.shared.userInfo = .init(username: FakeCreds.shared.get(.GitHubUsername), authToken: FakeCreds.shared.get(.GitHubAccessTokenWithoutRights))
        testBlock(GitHubAPI.shared)
//        BitBucketAPI.shared.authToken = FakeCreds.shared.get(.BitBucketAccessTokenWithoutRights)
//        testBlock(BitBucketAPI.shared)
//        GitLabAPI.shared.authToken = FakeCreds.shared.get(.GitLabAccessTokenWithoutRights)
//        testBlock(GitLabAPI.shared)
    }
    
    func testEachAPIUnauthenticatedAndAuthenticatedWithoutPermissions(testBlock: (GitAPI) -> Void) {
        testEachAPIUnauthenticated { gitAPI in
            testBlock(gitAPI)
        }
        testEachAPIAuthenticatedWithoutPermissions { gitAPI in
            testBlock(gitAPI)
        }
    }
    
    func testEachAPIAuthenticatedWithPermissions(testBlock: (GitAPI) -> Void) {
        GitHubAPI.shared.userInfo = .init(username: FakeCreds.shared.get(.GitHubUsername), authToken: FakeCreds.shared.get(.GitHubAccessTokenWithRights))
        testBlock(GitHubAPI.shared)
//        BitBucketAPI.shared.authToken = FakeCreds.shared.get(.BitBucketAccessTokenWithRights)
//        testBlock(BitBucketAPI.shared)
//        GitLabAPI.shared.authToken = FakeCreds.shared.get(.GitLabAccessTokenWithRights)
//        testBlock(GitLabAPI.shared)
    }
    
    
    //
    // tests
    //
    
    func testScopes() {
//        testEachAPIUnauthenticatedAndAuthenticatedWithoutPermissions { gitAPI in
//            let expectation = XCTestExpectation()
//            gitAPI.fetchGrantedScopes { (scopes: [PermScope]?, error: Error?) in
//                if let scopes = scopes {
//                    XCTAssertTrue(scopes.count == 0)
//                    expectation.fulfill()
//                } else {
//                    XCTFail()
//                }
//            }
//            wait(for: [expectation], timeout: 3)
//        }
        testEachAPIAuthenticatedWithPermissions { gitAPI in
            let expectation = XCTestExpectation()
            gitAPI.fetchGrantedScopes { (scopes: [PermScope]?, error: Error?) in
                if let scopes = scopes {
                    XCTAssertTrue(scopes.contains(where: { scope in
                        if case .repoList = scope {
                            return true
                        } else {
                            return false
                        }
                    }))
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
            wait(for: [expectation], timeout: 3)
        }
    }
    
    func testRepoList() {
//        testEachAPIUnauthenticatedAndAuthenticatedWithoutPermissions { gitAPI in
//            let expectation = XCTestExpectation()
//            gitAPI.fetchUserRepos { (repos: [RepoModel]?, error: Error?) in
//                if repos == nil {
//                    XCTAssertTrue(true)
//                    expectation.fulfill()
//                } else {
//                    XCTFail()
//                }
//            }
//            wait(for: [expectation], timeout: 10)
//        }
        testEachAPIAuthenticatedWithPermissions { gitAPI in
            let expectation = XCTestExpectation()
            gitAPI.fetchUserRepos { (repos: [RepoModel]?, error: Error?) in
                if let repos = repos {
                    XCTAssertTrue(repos.filter({
                        $0.isPrivate
                    }).count > 0)
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    static var allTests: [(String, (GitAPITests) -> () -> ())] = []
}
