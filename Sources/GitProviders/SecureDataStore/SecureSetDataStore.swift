//
//  SecureSetDataStore.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import KeychainAccess

struct SecureSetDataStore<T: Storeable> {
    let key: String
    let syncs: Bool
    let keychain: Keychain
    
    private func _hardSet(to set: Set<T>?) {
        if let arr = set?.map({$0.encode()}) {
            let set = NSSet(array: arr)
            if let setAsPLISTData = try? NSKeyedArchiver.archivedData(withRootObject: set, requiringSecureCoding: true) {
                try? keychain.synchronizable(syncs).set(setAsPLISTData, key: key)
            }
        } else {
            try? keychain.synchronizable(syncs).remove(key)
        }
    }
    func exists() -> Bool {
        (try? keychain.synchronizable(syncs).contains(key)) ?? false
    }
    func all() -> Set<T> {
        if let data = try? keychain.synchronizable(syncs).getData(key) {
            if let allDatas = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSSet.self, from: data) as? Set<Data> {
                return Set(allDatas.compactMap {
                    T.init(data: $0)
                })
            }
        }
        return []
    }
    func add(value: T) {
        var all = all()
        all.insert(value)
        _hardSet(to: all)
    }
    func contains(value: T) -> Bool {
        return all().contains(value)
    }
    func remove(value: T) {
        var all = all()
        all.remove(value)
        _hardSet(to: all)
    }
    func removeAll() {
        _hardSet(to: nil)
    }
    var count: Int {
        all().count
    }
}

protocol Storeable: Hashable {
    func encode() -> Data
    init?(data: Data)
}
extension Data: Storeable {
    func encode() -> Data {
        self
    }
    init?(data: Data) {
        self = data
    }
}
