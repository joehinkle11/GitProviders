//
//  GitProvider.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation

struct GitProvider: Identifiable {
    let id = UUID()
    
    /// i.e. GitHub, Bitbucket
    let providerName: String
    /// This provider can see what repos the user has
    let hasRepoListAccess: Bool
    /// This provider can actually clone and change repos
    let hasRepoContents: Bool
    
    /// remove from keychain
    func remove() {
        
    }
}


