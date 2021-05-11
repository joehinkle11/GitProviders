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
    
    func refresh() {
        // load ssh key from keychain
        self.sshKey = SSHKey.get(from: keychain)
        let publicSSHKey = sshKey?.publicKeyAsSSHFormat
        
        // load gitproviders in the given keychain
        gitProviders = []
        for preset in GitProviderPresets.allCases {
            switch preset {
            case .Custom:
                break
            default:
                let presetName = preset.rawValue
                let presetPublicSSHKey = GitProvider.publicKey(for: presetName, in: keychain)
                var hasRepoListAccess = false // todo
                var hasRepoContents = false
                if publicSSHKey != nil && publicSSHKey == presetPublicSSHKey {
                    hasRepoContents = true
                }
                let provider = GitProvider(
                    preset: preset,
                    keychain: keychain,
                    hasRepoListAccess: hasRepoListAccess,
                    hasRepoContents: hasRepoContents
                )
                gitProviders.append(provider)
            }
        }
    }
    
    public init(with keychain: Keychain) {
        self.keychain = keychain
        refresh()
    }
    
    func remove(_ gitProviderToRemove: GitProvider) {
        gitProviderToRemove.remove()
        refresh()
    }
    
    
    //
    // ui related
    //
    @Published var isMovingBackToFirstPage = false
    
    func moveBackToFirstPage() {
        isMovingBackToFirstPage = true
    }
}
