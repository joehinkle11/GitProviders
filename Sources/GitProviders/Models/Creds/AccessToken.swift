//
//  AccessToken.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import KeychainAccess
import GitAPI

struct AccessToken: Cred {
    let keychain: Keychain
    let accessTokenKeychainName: String
    
    /// do not retain in memory, this data is highly sensitive!
    var userInfo: UserInfo? {
        if let data = try? keychain.getData(accessTokenKeychainName) {
            return UserInfo(data: data)
        }
        return nil
    }
}

// used as well for passwords because they function exactly the same
typealias PasswordCred = AccessToken

// make it so that we can store the UserInfo type (which holds username and access token) in the keychain
extension UserInfo: Storeable {
    func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode(username, forKey: "username")
        archiver.encode(authToken, forKey: "authToken")
        archiver.finishEncoding()
        return archiver.encodedData
    }
    
    init?(data: Data) {
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            return nil
        }
        defer {
            unarchiver.finishDecoding()
        }
        guard let username = unarchiver.decodeObject(forKey: "username") as? String else { return nil }
        guard let authToken = unarchiver.decodeObject(forKey: "authToken") as? String else { return nil }
        self.init(username: username, authToken: authToken)
    }
}
