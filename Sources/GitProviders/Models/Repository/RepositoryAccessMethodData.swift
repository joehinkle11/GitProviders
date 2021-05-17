//
//  RepositoryAccessMethodData.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import SwiftGit2

protocol RepositoryAccessMethodData {
    var hash: Int { get }
    var userDescription: String { get }
    func toSwiftGit2Credentials() -> SwiftGit2.Credentials?
    
    /// gets sensitive info!
    func getCred() -> Cred?
}

struct AnyRepositoryAccessMethodData: Identifiable, RepositoryAccessMethodData {
    var id: Int { hash }
    let hash: Int
    let raw: Any
    private let _getCred: () -> Cred?
    func getCred() -> Cred? {
        _getCred()
    }
    private let _userDescription: () -> String
    var userDescription: String {
        _userDescription()
    }
    let _toSwiftGit2Credentials: () -> SwiftGit2.Credentials?
    func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
        _toSwiftGit2Credentials()
    }
    init<T: RepositoryAccessMethodData>(_ val: T) {
        self.raw = val
        self.hash = val.hash
        self._getCred = val.getCred
        self._userDescription = {val.userDescription}
        self._toSwiftGit2Credentials = val.toSwiftGit2Credentials
    }
}

struct UnauthenticatedAccessMethodData: RepositoryAccessMethodData {
    var hash: Int = 0
    
    var userDescription: String {
        "Unauthenticated"
    }
    
    func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
        SwiftGit2.Credentials.default
    }
    
    func getCred() -> Cred? {
        Unauthenticated()
    }
}

struct SSHAccessMethodData: RepositoryAccessMethodData {
    var hash: Int { publicKeyData.hashValue }

    let publicKeyData: Data
    var userDescription: String {
        (try? publicKeyData.publicPEMKeyToSSHFormat()) ?? "SSH Key"
    }
    func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
        if let creds = getData(), let privateKeyAsPEMString = creds.privateKeyAsPEMString {
            return SwiftGit2.Credentials.sshMemory(
                username: "git",
                privateKey: privateKeyAsPEMString,
                passphrase: ""
            )
        }
        return nil
    }
    
    /// gets sensitive info!
    let getData: () -> SSHKey?
    func getCred() -> Cred? { getData() }
}

struct AccessTokenAccessMethodData: RepositoryAccessMethodData {
    var hash: Int { 1 }
    
    let username: String
    let isPassword: Bool
    let providerName: String
    var userDescription: String {
        "\(providerName) \(isPassword ? "password" : "access token") for \(username)"
    }
    func toSwiftGit2Credentials() -> SwiftGit2.Credentials? {
        if let creds = getData() {
            return SwiftGit2.Credentials.plaintext(
                username: username,
                password: creds.accessTokenOrPassword
            )
        }
        return nil
        
    }
    /// gets sensitive info!
    let getData: () -> AccessTokenOrPassword?
    func getCred() -> Cred? { getData() }
}
