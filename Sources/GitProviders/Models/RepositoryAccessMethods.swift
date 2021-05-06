//
//  RepositoryAccessMethods.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

enum RepositoryAccessMethods: Identifiable {
    var id: String { name }
    
    case AccessToken
    
    var name: String {
        switch self {
        case .AccessToken:
            return "Access Token"
        }
    }
}
