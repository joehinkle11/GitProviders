//
//  GitProviderPresets.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

enum GitProviderPresets: String {
    case GitHub
    case BitBucket
    case GitLab
    case Custom
    
    var supportedContentAccessMethods: [RepositoryAccessMethods] {
        switch self {
        case .GitHub:
            return [.AccessToken, .SSH]
        case .BitBucket:
            return [.SSH]
        case .GitLab:
            return [.SSH]
        case .Custom:
            return [.SSH]
        }
    }
    var supportedRepoListAccessMethods: [RepositoryListAccessMethods] {
        switch self {
        case .GitHub:
            return [.OAuth]
        case .BitBucket:
            return []
        case .GitLab:
            return []
        case .Custom:
            return []
        }
    }
}
