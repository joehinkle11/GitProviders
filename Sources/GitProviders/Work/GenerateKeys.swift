//
//  GenerateKeys.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

// adapted from: https://stackoverflow.com/a/45916908/3902590

import Security

// tuple type for public/private key pair at class level
typealias KeyPair = (publicKey: SecKey, privateKey: SecKey)
func generateKeyPair(_ publicTag: String, privateTag: String, keySize: KeySize) -> KeyPair? {
    var sanityCheck: OSStatus = noErr
    var publicKey: SecKey?
    var privateKey: SecKey?
    
    // Container dictionaries
    var privateKeyAttr = [AnyHashable : Any]()
    var publicKeyAttr = [AnyHashable: Any]()
    var keyPairAttr = [AnyHashable : Any]()
    
    // Set top level dictionary for the keypair
    keyPairAttr[(kSecAttrKeyType ) as AnyHashable] = (kSecAttrKeyTypeRSA as Any)
    keyPairAttr[(kSecAttrKeySizeInBits as AnyHashable)] = keySize.rawValue
    
    // Set private key dictionary
    privateKeyAttr[(kSecAttrIsPermanent as AnyHashable)] = Int(truncating: true)
    privateKeyAttr[(kSecAttrApplicationTag as AnyHashable)] = privateTag
    
    // Set public key dictionary.
    publicKeyAttr[(kSecAttrIsPermanent as AnyHashable)] = Int(truncating: true)
    publicKeyAttr[(kSecAttrApplicationTag as AnyHashable)] = publicTag
    publicKeyAttr[(kSecAttrProtocol as AnyHashable)] = (kSecAttrProtocolSSH as Any)
    
    keyPairAttr[(kSecPrivateKeyAttrs as AnyHashable)] = privateKeyAttr
    keyPairAttr[(kSecPublicKeyAttrs as AnyHashable)] = publicKeyAttr
    
    sanityCheck = SecKeyGeneratePair((keyPairAttr as CFDictionary), &publicKey, &privateKey)
    if sanityCheck == noErr && publicKey != nil && privateKey != nil {
        return KeyPair(publicKey: publicKey!, privateKey: privateKey!)
    }
    return nil
}
