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
    
    var supportedAccessMethods: [RepositoryAccessMethods] {
        switch self {
        case .GitHub:
            return [.AccessToken]
        case .BitBucket:
            return []
        case .GitLab:
            return []
        case .Custom:
            return []
        }
    }
}
