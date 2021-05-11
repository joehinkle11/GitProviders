//
//  GitProvider.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation
import KeychainAccess

// constants
private let _public_ssh_keys = "_public_ssh_keys"

struct GitProvider: Identifiable {
    let id = UUID()
    
    let preset: GitProviderPresets
    let customDetails: CustomProviderDetails?
    let keychain: Keychain
    
    let currentSSHKeyOfUser: SSHKey?
    
    // data stores
    /// we only store public keys, this way we can default to using icloud syncing without security concerns (some users may not want to use iCloud syncing with private info)
    let sshKeyDataStore: SecureSetDataStore<Data>
    
    /// determines if the user will see this on their home screen
    var isActive: Bool {
        if sshKeyDataStore.count > 0 {
            return true
        }
        // todo
//        } else if accessTokenDataStore.count > 0 {
//            return true
//        }
        return false
    }
    
    init(preset: GitProviderPresets, keychain: Keychain, currentSSHKeyOfUser: SSHKey?) {
        self.preset = preset
        guard preset != .Custom else {
            #if DEBUG
            fatalError() // shouldn't happen
            #endif
        }
        self.customDetails = nil
        self.keychain = keychain
        self.currentSSHKeyOfUser = currentSSHKeyOfUser
        self.sshKeyDataStore = .init(key: preset.rawValue + _public_ssh_keys, syncs: true, keychain: keychain)
    }
    init(customDetails: CustomProviderDetails, keychain: Keychain, currentSSHKeyOfUser: SSHKey?) {
        self.preset = .Custom
        self.customDetails = customDetails
        self.keychain = keychain
        self.currentSSHKeyOfUser = currentSSHKeyOfUser
        self.sshKeyDataStore = .init(key: "custom_" + customDetails.customName + _public_ssh_keys, syncs: true, keychain: keychain)
    }
    
    var baseKeyName: String? {
        switch preset {
        case .Custom:
            return customDetails?.customName
        default:
            return preset.rawValue
        }
    }
    
    var userDescription: String {
        switch preset {
        case .Custom:
            return "custom profile \(customDetails?.customName ?? "")"
        default:
            return preset.rawValue
        }
    }
    
    /// This provider can see what repos the user has
    var hasRepoListAccess: Bool {
        false
    }
    /// This provider can actually clone and change repos
    var hasRepoContents: Bool {
        supportsSSH
    }
    
    ///
    var supportsSSH: Bool {
        if let currentSSHKeyOfUser = currentSSHKeyOfUser,
           let publicKeyData = currentSSHKeyOfUser.publicKeyData {
            return sshKeyDataStore.contains(value: publicKeyData)
        }
        return false
    }
    
    func delete() {
        sshKeyDataStore.removeAll()
    }
    
    func createAccessMethodDetailCells(
        for accessMethod: RepositoryAccessMethods,
        in gitProviderStore: GitProviderStore
    ) -> [AccessMethodDetailCell] {
        switch accessMethod {
        case .AccessToken:
            return []
        case .SSH:
            return self.allSSHPublicKeys().map { publicKeyData in
                AccessMethodDetailCell(gitProviderStore: gitProviderStore, accessMethodData: SSHAccessMethodData(publicKeyData: publicKeyData), accessMethod: accessMethod)
            }
        }
    }
    
    /// only stores public key
    func add(sshKey: SSHKey) {
        if let publicKey = sshKey.publicKeyData {
            sshKeyDataStore.add(value: publicKey)
        }
    }
    func remove(sshKey: SSHKey) {
        if let publicKey = sshKey.publicKeyData {
            sshKeyDataStore.remove(value: publicKey)
        }
    }
    func remove(accessMethodData: RepositoryAccessMethodData) {
        if let sshAccessMethodData = accessMethodData as? SSHAccessMethodData {
            sshKeyDataStore.remove(value: sshAccessMethodData.publicKeyData)
        }
    }
    func allSSHPublicKeys() -> Set<Data> {
        sshKeyDataStore.all()
    }
}
