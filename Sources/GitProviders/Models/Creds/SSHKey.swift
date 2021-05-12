//
//  SSHKey.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation
import Security
import KeychainAccess

struct SSHKey: Cred {
    let keychain: Keychain
    let publicKeyKeychainName: String
    let privateKeyKeychainName: String
    /// okay to retain in memory, it's a public key
    var publicKeyData: Data? {
        try? keychain.getData(publicKeyKeychainName)
    }
    /// okay to retain in memory, it's a public key
    var publicKeyAsPEMFormat: String? {
        publicKeyData?.printAsPEMPublicKey()
    }
    /// okay to retain in memory, it's a public key
    var publicKeyAsSSHFormat: String? {
        try? publicKeyData?.publicPEMKeyToSSHFormat()
    }
    /// do not retain in memory, this data is highly sensitive!
    var privateKeyData: Data? {
        try? keychain.getData(privateKeyKeychainName)
    }
    /// do not retain in memory, this data is highly sensitive!
    var privateKeyAsPEMString: String? {
        privateKeyData?.printAsPEMPrivateKey()
    }
    
    
    private static let defaultPublicKeyKeychainName = "id_rsa.pub"
    private static let defaultPrivateKeyKeychainName = "id_rsa"
    
    static func get(from keychain: Keychain) -> SSHKey? {
        let sshKey = SSHKey(
            keychain: keychain,
            publicKeyKeychainName: defaultPublicKeyKeychainName,
            privateKeyKeychainName: defaultPrivateKeyKeychainName
        )
        if sshKey.publicKeyData != nil {
            return sshKey
        }
        return nil
    }
    
    static func generateNew(for keychain: Keychain, withICloudSync: Bool, keySize: KeySize, keyType: KeyType) -> SSHKey? {
        guard keyType == .RSA else {
            // todo: support other key types
            return nil
        }
        if let bundleId = Bundle.main.bundleIdentifier {
            let publicKeyTag: String = "\(bundleId).publickey"
            let privateKeyTag: String = "\(bundleId).privatekey"
            
            for tag in [publicKeyTag, privateKeyTag] {
                let deleteQuery: [String: Any] = [kSecAttrApplicationTag as String: tag]
                SecItemDelete(deleteQuery as CFDictionary)
            }
            
            // todo: reset all git providers using this key
            
            let keyPair = generateKeyPair(publicKeyTag, privateTag: privateKeyTag, keySize: keySize)
            
            var pbError:Unmanaged<CFError>?
            var prError:Unmanaged<CFError>?
            
            guard let publicKey = keyPair?.publicKey,
                  let pbData = SecKeyCopyExternalRepresentation(publicKey, &pbError) as Data? else {
                return nil
            }
            guard let privateKey = keyPair?.privateKey, let prData = SecKeyCopyExternalRepresentation(privateKey, &prError) as Data? else {
                return nil
            }
            
            do {
                // store public key so that it's locked in the secure enclave until someone unlocks the device for the first time after a reboot
                try keychain
                    .synchronizable(withICloudSync)
                    .accessibility(.afterFirstUnlock)
                    .set(pbData, key: defaultPublicKeyKeychainName)
                // store private key so that it's locked in the secure enclave except when the device is in an unlocked state
                try keychain
                    .synchronizable(withICloudSync)
                    .accessibility(.whenUnlocked)
                    .set(prData, key: defaultPrivateKeyKeychainName)
                return .init(
                    keychain: keychain,
                    publicKeyKeychainName: defaultPublicKeyKeychainName,
                    privateKeyKeychainName: defaultPrivateKeyKeychainName
                )
            } catch {}
        }
        return nil
    }
}


