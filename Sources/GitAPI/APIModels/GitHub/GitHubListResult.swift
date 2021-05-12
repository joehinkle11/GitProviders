//
//  GitHubListResult.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

import Foundation

struct GitHubListResult<T: GitHubModel>: GitHubModel {
    let total_count: Int
    let items: [T]
}
