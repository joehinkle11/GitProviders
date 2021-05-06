//
//  RepositoryAccessMethods.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

enum RepositoryAccessMethods: Identifiable {
    var id: String { name }
    
    case AccessToken
    case SSH
    
    var name: String {
        switch self {
        case .AccessToken:
            return "Access Token"
        case .SSH:
            return "SSH"
        }
    }
}
