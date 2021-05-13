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
private let _access_token_or_password = "_access_token_or_password"

struct GitProvider: Identifiable {
    let id = UUID()
    
    let preset: GitProviderPresets
    let customDetails: CustomProviderDetails?
    let keychain: Keychain
    
    let currentSSHKeyOfUser: SSHKey?
    
    //
    // data stores
    //
    /// We only store public keys, this way we can default to using icloud syncing without security concerns (some users may not want to use iCloud syncing with private info).
    let sshKeyDataStore: SecureSetDataStore<Data>
    
    /// We store acess tokens (senstive info!), so if icloud isn't enable for a key, another devices simply won't see the key We only allow the user to set ONE access token or password.
    let accessTokenOrPasswordDataStore: SecureDataStore<AccessTokenOrPassword>
    
    
    //
    //
    //
    
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
        #if DEBUG
        guard preset != .Custom else {
            fatalError() // shouldn't happen
        }
        #endif
        self.customDetails = nil
        self.keychain = keychain
        self.currentSSHKeyOfUser = currentSSHKeyOfUser
        self.sshKeyDataStore = .init(key: preset.rawValue + _public_ssh_keys, syncs: true, keychain: keychain)
        // todo: fix syncing flag
        self.accessTokenOrPasswordDataStore = .init(key: preset.rawValue + _access_token_or_password, keychain: keychain)
    }
    init(customDetails: CustomProviderDetails, keychain: Keychain, currentSSHKeyOfUser: SSHKey?) {
        self.preset = .Custom
        self.customDetails = customDetails
        self.keychain = keychain
        self.currentSSHKeyOfUser = currentSSHKeyOfUser
        self.sshKeyDataStore = .init(key: "custom_" + customDetails.customName + _public_ssh_keys, syncs: true, keychain: keychain)
        // todo: fix syncing flag
        self.accessTokenOrPasswordDataStore = .init(key: "custom_" + customDetails.customName + _access_token_or_password, keychain: keychain)
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
    var supportsAccessTokenOrPassword: Bool {
        return accessTokenOrPasswordDataStore.exists()
    }
    
    func delete() {
        sshKeyDataStore.removeAll()
        accessTokenOrPasswordDataStore.removeAll()
    }
    
    func createAccessMethodDetailCells(
        for accessMethod: RepositoryAccessMethods,
        gitProvider: GitProvider,
        in gitProviderStore: GitProviderStore
    ) -> [AccessMethodDetailCell] {
        switch accessMethod {
        case .AccessToken:
            if accessTokenOrPasswordDataStore.exists() {
                return [
                    AccessMethodDetailCell(
                        gitProviderStore: gitProviderStore,
                        accessMethodData: AccessTokenAccessMethodData(getUserInfo: {
                            accessTokenOrPasswordDataStore.read()
                        }),
                        accessMethod: accessMethod,
                        gitProvider: gitProvider
                    )
                ]
            } else {
                return []
            }
        case .SSH:
            return self.allSSHPublicKeys().map { publicKeyData in
                AccessMethodDetailCell(
                    gitProviderStore: gitProviderStore,
                    accessMethodData: SSHAccessMethodData(publicKeyData: publicKeyData),
                    accessMethod: accessMethod,
                    gitProvider: gitProvider
                )
            }
        case .Password: return []
        case .OAuth: return []
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
