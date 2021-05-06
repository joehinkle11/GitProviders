//
//  SSHKey.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation
import Security
import KeychainAccess

// adapted from: https://stackoverflow.com/a/45931021/3902590

struct SSHKey {
    let keychain: Keychain
    let publicKeyKeychainName: String
    let privateKeyKeychainName: String
    /// okay to retain in memory, it's a public key
    var publicKey: Data? {
        try? keychain.getData(publicKeyKeychainName)
    }
    /// do not retain in memory, this data is highly sensitive!
    var privateKey: Data? {
        try? keychain.getData(privateKeyKeychainName)
    }
    
    
    private static let defaultPublicKeyKeychainName = "id_rsa.pub"
    private static let defaultPrivateKeyKeychainName = "id_rsa"
    
    static func get(from keychain: Keychain) -> SSHKey? {
        let sshKey = SSHKey(
            keychain: keychain,
            publicKeyKeychainName: defaultPublicKeyKeychainName,
            privateKeyKeychainName: defaultPrivateKeyKeychainName
        )
        if sshKey.publicKey != nil && sshKey.privateKey != nil {
            return sshKey
        }
        return nil
    }
    
    static func generateNew(for keychain: Keychain) -> SSHKey? {
        if let bundleId = Bundle.main.bundleIdentifier {
            let publicKeyAttr: [NSObject: NSObject] = [
                kSecAttrIsPermanent: true as NSObject,
                kSecAttrApplicationTag: "\(bundleId).public".data(using: String.Encoding.utf8)! as NSObject,
                kSecClass: kSecClassKey, // added this value
                kSecReturnData: kCFBooleanTrue] // added this value
            let privateKeyAttr: [NSObject: NSObject] = [
                kSecAttrIsPermanent: true as NSObject,
                kSecAttrApplicationTag: "\(bundleId).private".data(using: String.Encoding.utf8)! as NSObject,
                kSecClass: kSecClassKey, // added this value
                kSecReturnData: kCFBooleanTrue] // added this value
            
            var keyPairAttr = [NSObject: NSObject]()
            keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
            keyPairAttr[kSecAttrKeySizeInBits] = 2048 as NSObject
            keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr as NSObject
            keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr as NSObject
            
            var publicKey : SecKey?
            var privateKey : SecKey?
            
            let statusCode = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)
            
            if statusCode == noErr && publicKey != nil && privateKey != nil {
                var resultPublicKey: AnyObject?
                var resultPrivateKey: AnyObject?
                let statusPublicKey = SecItemCopyMatching(publicKeyAttr as CFDictionary, &resultPublicKey)
                let statusPrivateKey = SecItemCopyMatching(privateKeyAttr as CFDictionary, &resultPrivateKey)
                
                if statusPublicKey == noErr {
                    if let publicKey = resultPublicKey as? Data {
                        if statusPrivateKey == noErr {
                            if let privateKey = resultPrivateKey as? Data {
                                // store public key so that it's locked in the secure enclave until someone unlocks the device for the first time after a reboot
                                do {
                                    try keychain
                                        .synchronizable(true)
                                        .accessibility(.afterFirstUnlock)
                                        .set(publicKey, key: defaultPublicKeyKeychainName)
                                    // store private key so that it's locked in the secure enclave except when the device is in an unlocked state
                                    try keychain
                                        .synchronizable(true)
                                        .accessibility(.whenUnlocked)
                                        .set(privateKey, key: defaultPrivateKeyKeychainName)
                                    return .init(
                                        keychain: keychain,
                                        publicKeyKeychainName: defaultPublicKeyKeychainName,
                                        privateKeyKeychainName: defaultPrivateKeyKeychainName
                                    )
                                } catch {}
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
}
