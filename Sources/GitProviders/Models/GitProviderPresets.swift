//
//  GitProviderPresets.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

enum GitProviderPresets: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    // these keys should not change, as the keychain will use these key to lookup their saved state
    case GitHub
    case BitBucket
    case GitLab
    case Custom
    
    var domain: String? {
        switch self {
        case .GitHub:
            return rawValue.lowercased() + ".com"
        case .BitBucket:
            return rawValue.lowercased() + ".org"
        case .GitLab:
            return rawValue.lowercased() + ".com"
        case .Custom:
            return nil
        }
    }
    
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
    
    var addAccessTokenLink: String? {
        switch self {
        case .GitHub:
            return "https://github.com/settings/tokens/new"
        case .BitBucket:
            return "https://bitbucket.org/account/settings/app-passwords/new"
        case .GitLab:
            return "https://gitlab.com/-/profile/personal_access_tokens"
        case .Custom:
            return nil
        }
    }
    
    var addAccessTokenPagePermissionForRepoContents: [String]? {
        switch self {
        case .GitHub:
            return ["repo"]
        case .BitBucket:
            return ["Repositories Read", "Repositories Write"]
        case .GitLab:
            return ["read_repository","write_repository"]
        case .Custom:
            return nil
        }
    }
    
    var addAccessTokenPagePermissionForRepoList: [String]? {
        switch self {
        case .GitHub:
            return ["repo"]
        case .BitBucket:
            return ["Repositories Read"]
        case .GitLab:
            return ["read_api"]
        case .Custom:
            return nil
        }
    }
    
    var supportedContentAccessMethods: [RepositoryAccessMethods] {
        switch self {
        case .GitHub:
            return [.AccessToken, .SSH]
        case .BitBucket:
            return [.AccessToken, .SSH]
        case .GitLab:
            return [.AccessToken, .SSH]
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
