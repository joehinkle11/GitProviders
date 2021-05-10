//
//  GitProviderPresets.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

enum GitProviderPresets: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case GitHub
    case BitBucket
    case GitLab
    case Custom
    
    var addSSHKeyLink: String? {
        switch self {
        case .GitHub:
            return "https://github.com/settings/ssh/new"
        case .BitBucket:
            return "https://bitbucket.org/account/settings/ssh-keys/"
        case .GitLab:
            return "https://gitlab.com/-/profile/keys"
        case .Custom:
            return nil
        }
    }
    
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
