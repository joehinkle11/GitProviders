//
//  GitProvider.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation
import KeychainAccess
import GitAPI

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
    //
    //
    func getRepos(callback: @escaping (_ repos: [RepoModel]?, _ noAPISupport: Bool) -> Void) {
        if let api = preset.api, let userInfo = accessTokenOrPasswordDataStore.read() {
            api.userInfo = .init(username: userInfo.username, authToken: userInfo.accessTokenOrPassword)
            api.fetchUserRepos { repos, _ in
                callback(repos, false)
            }
        } else {
            callback(nil, true)
        }
    }
    
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
        } else if accessTokenOrPasswordDataStore.exists() {
            return true
        }
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
        accessTokenOrPasswordDataStore.read()?.isPassword == false
    }
    /// This provider can actually clone and change repos
    var hasRepoContents: Bool {
        supportsSSH || supportsAccessTokenOrPassword
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
                let info = accessTokenOrPasswordDataStore.read()
                let username = info?.username ?? ""
                let isPassword = info?.isPassword ?? false
                return [
                    AccessMethodDetailCell(
                        gitProviderStore: gitProviderStore,
                        accessMethodData: AccessTokenAccessMethodData(
                            username: username,
                            isPassword: isPassword,
                            providerName: gitProvider.userDescription,
                            getData: {
                                accessTokenOrPasswordDataStore.read()
                            }
                        ),
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
                    accessMethodData: SSHAccessMethodData(
                        publicKeyData: publicKeyData,
                        getData: {
                            return nil
                        }
                    ),
                    accessMethod: accessMethod,
                    gitProvider: gitProvider
                )
            }
        case .Password: return []
        case .OAuth: return []
        }
    }
    
    /// stores actual access tokens and passwords
    func save(accessTokenOrPassword: AccessTokenOrPassword, syncs: Bool) {
        accessTokenOrPasswordDataStore.set(to: accessTokenOrPassword, syncs: syncs)
    }
    func deleteAccessTokenOrPassword() {
        accessTokenOrPasswordDataStore.removeAll()
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
        } else if let accessTokenAccessMethodData = accessMethodData as? AccessTokenAccessMethodData {
            if accessTokenOrPasswordDataStore.read() == accessTokenAccessMethodData.getData() {
                accessTokenOrPasswordDataStore.removeAll()
            } else {
                #if DEBUG
                fatalError("should never happen")
                #endif
            }
        }
    }
    func allSSHPublicKeys() -> Set<Data> {
        sshKeyDataStore.all()
    }
    
    
    
    
    var allAnyRepositoryAccessMethodDatas: [AnyRepositoryAccessMethodData] {
        var all: [AnyRepositoryAccessMethodData] = []
        if let data = accessTokenOrPasswordDataStore.read() {
            all.append(.init(AccessTokenAccessMethodData(
                username: data.username, isPassword: data.isPassword, providerName: userDescription, getData: {
                    accessTokenOrPasswordDataStore.read()
                }
            )))
        }
        if supportsSSH,
           let sshKey = currentSSHKeyOfUser,
           let publicKeyData = sshKey.publicKeyData {
            all.append(.init(SSHAccessMethodData(
                publicKeyData: publicKeyData,
                getData: {
                    sshKey
                }
            )))
        }
        return all
    }
}
