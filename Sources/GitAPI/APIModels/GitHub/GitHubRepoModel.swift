//
//  GitHubRepoModel.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

import Foundation

struct GitHubRepoModel: GitHubModel {
    let name: String
    let `private`: Bool
    let description: String?
    let ssh_url: String
    let clone_url: String
}
