//
//  SecureDataStore.swift
//  
//
//  Created by Joseph Hinkle on 5/13/21.
//

import Foundation
import KeychainAccess

// always tries to get iCloud version first (but then local if there is not iCLoud version) when getting, and requires the caller specify if the value should be synced on iCloud on set/save

struct SecureDataStore<T: Storeable> {
    let key: String
    let keychain: Keychain
    
    private func _hardSet(to value: T?, syncs: Bool) {
        if let value = value {
            try? keychain.synchronizable(syncs).set(value.encode(), key: key)
        } else {
            try? keychain.synchronizable(syncs).remove(key)
        }
    }
    func set(to value: T, syncs: Bool) {
        _hardSet(to: value, syncs: syncs)
    }
    func exists() -> Bool {
        (try? keychain.synchronizable(true).contains(key)) ?? false
    }
    func read() -> T? {
        if let data = try? keychain.synchronizable(true).getData(key) {
            return T.init(data: data)
        }
        return nil
    }
    /// "all" because it deletes iCloud Keychain version too
    func removeAll() {
        _hardSet(to: nil, syncs: false)
        _hardSet(to: nil, syncs: true)
    }
}
