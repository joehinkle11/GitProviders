//
//  RepositoryListAccessMethods.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

enum RepositoryListAccessMethods: Identifiable {
    var id: String { name }
    
    case OAuth
    
    var name: String {
        switch self {
        case .OAuth:
            return "OAuth"
        }
    }
}

