//
//  OAuthToken.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import KeychainAccess

struct OAuthToken: Cred {
    let keychain: Keychain
    let oAuthTokenKeychainName: String
    
    /// do not retain in memory, this data is highly sensitive!
    var data: Data? {
        try? keychain.getData(oAuthTokenKeychainName)
    }
}
