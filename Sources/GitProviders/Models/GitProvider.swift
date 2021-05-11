//
//  GitProvider.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation
import KeychainAccess

struct GitProvider: Identifiable {
    let id = UUID()
    
    let preset: GitProviderPresets
    let keychain: Keychain
    
    /// i.e. GitHub, Bitbucket
    var providerName: String {
        preset.rawValue
    }
    /// This provider can see what repos the user has
    let hasRepoListAccess: Bool
    /// This provider can actually clone and change repos
    let hasRepoContents: Bool
    
    /// remove from keychain
    func remove() {
        let ok = GitProviderModel()
//        keychain.set
    }
    
    /// public key needs to be in openssh public key format
    func update(publicKey: String) {
        keychain.synchronizable(<#T##synchronizable: Bool##Bool#>)
        try? keychain.getString("\(preset.rawValue)\(Self.PUBLIC_SSH_KEY)")
    }
    
    // keychain keys
    static func publicKey(for preset: GitProviderPresets, in keychain: Keychain) -> String? {
        switch preset {
        case .Custom:
            fatalError("todos")
        default:
            return try? keychain.getString("\(preset.rawValue)\(PUBLIC_SSH_KEY)")
        }
    }
    
    // constants
    static let PUBLIC_SSH_KEY = "_public_ssh_key"
}

struct GitProviderModel {
    
}
