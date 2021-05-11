//
//  GitProviderStore.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Foundation
import Combine
import KeychainAccess

public final class GitProviderStore: ObservableObject {
    let keychain: Keychain
    
    @Published var gitProviders: [GitProvider] = []
    @Published var sshKey: SSHKey? = nil
    
    /// just a set of all the custom provider names
    let customProviderDataStore: SecureSetDataStore<CustomProviderDetails>
    
    private func getAllCustomProviders(currentSSHKeyOfUser: SSHKey?) -> [GitProvider] {
        var providers: [GitProvider] = []
        for providerDetails in customProviderDataStore.all() {
            providers.append(GitProvider(
                customDetails: providerDetails,
                keychain: keychain,
                currentSSHKeyOfUser: sshKey
            ))
        }
        return providers
    }
    
    func refresh() {
        // load ssh key from keychain
        self.sshKey = SSHKey.get(from: keychain)
        
        // load gitproviders in the given keychain
        gitProviders = []
        for preset in GitProviderPresets.allCases {
            switch preset {
            case .Custom:
                let providers = getAllCustomProviders(currentSSHKeyOfUser: sshKey)
                for provider in providers {
                    gitProviders.append(provider)
                }
            default:
                let provider = GitProvider(
                    preset: preset,
                    keychain: keychain,
                    currentSSHKeyOfUser: sshKey
                )
                gitProviders.append(provider)
            }
        }
    }
    
    public init(with keychain: Keychain) {
        self.keychain = keychain
        self.customProviderDataStore = .init(key: "all_custom_git_providers", syncs: true, keychain: keychain)
        refresh()
    }
    
    func remove(_ gitProviderToRemove: GitProvider) {
        gitProviderToRemove.delete()
        if let customDetails = gitProviderToRemove.customDetails {
            customProviderDataStore.remove(value: customDetails)
        }
        refresh()
    }
    
    func addCustom(named name: String, withDomain domain: String) {
        customProviderDataStore.add(value: CustomProviderDetails(
            customName: name,
            domain: domain
        ))
    }
    
    
    //
    // ui related
    //
    @Published var isMovingBackToFirstPage = false
    
    func moveBackToFirstPage() {
        isMovingBackToFirstPage = true
    }
}
