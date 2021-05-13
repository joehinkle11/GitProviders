//
//  RepositoryAccessMethodData.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation

protocol RepositoryAccessMethodData {
    var hash: Int { get }
}

struct SSHAccessMethodData: RepositoryAccessMethodData {
    var hash: Int { publicKeyData.hashValue }

    let publicKeyData: Data
}

struct AccessTokenAccessMethodData: RepositoryAccessMethodData {
    var hash: Int { 1 }
    
    let isPassword: Bool
    /// gets sensitive info!
    let getData: () -> AccessTokenOrPassword?
}
