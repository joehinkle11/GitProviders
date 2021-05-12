//
//  AccessToken.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import KeychainAccess

struct AccessToken: Cred {
    let keychain: Keychain
    let accessTokenKeychainName: String
    
    /// do not retain in memory, this data is highly sensitive!
    var data: Data? {
        try? keychain.getData(accessTokenKeychainName)
    }
}

typealias PasswordCred = AccessToken
