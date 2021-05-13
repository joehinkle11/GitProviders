//
//  AccessToken.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import KeychainAccess

struct AccessTokenOrPassword: Cred {
    let username: String
    let accessTokenOrPassword: String
    let isPassword: Bool // if false, means it's an access token
}

// make it so that we can store the UserInfo type (which holds username and access token) in the keychain
extension AccessTokenOrPassword: Storeable {
    func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode(username, forKey: "username")
        archiver.encode(accessTokenOrPassword, forKey: "accessTokenOrPassword")
        archiver.encode(isPassword, forKey: "isPassword")
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
        guard let accessTokenOrPassword = unarchiver.decodeObject(forKey: "accessTokenOrPassword") as? String else { return nil }
        guard let isPassword = unarchiver.decodeObject(forKey: "isPassword") as? Bool else { return nil }
        self.init(username: username, accessTokenOrPassword: accessTokenOrPassword, isPassword: isPassword)
    }
}
