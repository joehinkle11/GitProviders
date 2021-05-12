//
//  GitHubAPI.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation

final class GitHubAPI: GitAPI {
    let baseUrl = URL(string: "https://api.github.com/")!
    
    static let shared: GitHubAPI = .init()
    private init() {}
    
    func fetchGrantedScopes(callback: @escaping (_ grantedScopes: [String]?, _ error: Error?) -> Void) {
        self.get("") { response, error in
            print("")
        }
    }
}
