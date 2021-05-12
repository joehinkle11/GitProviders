//
//  Network.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation

final class GitHubAPI {
    let baseUrl = URL(string: "https://api.github.com/")!
    
    let shared: GitHubAPI = .init()
    private init() {}
}
