//
//  GitHubAPI.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation

public final class GitHubAPI: GitAPI {
    public let baseUrl = URL(string: "https://api.github.com/")!
    public var userInfo: UserInfo?
    
    public static let shared: GitHubAPI = .init()
    init() {}
    
    public func fetchGrantedScopes(callback: @escaping (_ grantedScopes: [PermScope]?, _ error: Error?) -> Void) {
        self.get("user") { response, error in
            if let response = response {
                let scopeStrings = response.headers.readStringList(from: "x-oauth-scopes")
                var scopes: [PermScope] = []
                for scope in scopeStrings {
                    if scope == "repo" {
                        scopes.append(.repoList(raw: scope))
                    } else {
                        scopes.append(.unknown(raw: scope))
                    }
                }
                callback(scopes, nil)
            } else {
                callback(nil, error)
            }
        }
    }

    public func fetchUserRepos(callback: @escaping ([RepoModel]?, Error?) -> Void) {
        if let username = userInfo?.username {
            self.get("search/repositories", parameters: [
                "q": "user:\(username)",
                "per_page":"100"
            ]) { response, error in
                if let response = response,
                   let gitHubRepoList = response.body.parse(as: GitHubListResult<GitHubRepoModel>.self) {
                    var repos: [RepoModel] = []
                    for gitHubRepo in gitHubRepoList.items {
                        repos.append(.init(
                            name: gitHubRepo.name,
                            httpsURL: gitHubRepo.clone_url,
                            sshURL: gitHubRepo.ssh_url,
                            isPrivate: gitHubRepo.private
                        ))
                    }
                    callback(repos, nil)
                } else {
                    callback(nil, error)
                }
            }
        } else {
            callback(nil, NSError())
        }
    }
}
