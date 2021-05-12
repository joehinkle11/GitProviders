//
//  PermScope.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

enum PermScope: InternalModel {
    case repoContents(raw: String) // can see contents of a repos
    case repoList(raw: String) // can see existence of repos user has access to
    case unknown(raw: String)
    
    var raw: String {
        switch self {
        case .repoContents(let raw):
            return raw
        case .repoList(let raw):
            return raw
        case .unknown(let raw):
            return raw
        }
    }
}
