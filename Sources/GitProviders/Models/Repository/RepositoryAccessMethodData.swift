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
    var hash: Int {
        return publicKeyData.hashValue
    }
    
    let publicKeyData: Data
}
