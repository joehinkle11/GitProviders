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
    
    @Published var gitProviders: [GitProvider] = [.init(providerName: "GitHub", hasRepoListAccess: false, hasRepoContents: true)]
    @Published var sshKey: SSHKey? = nil
    
    func refresh() {
//        gitProviders = []
//        // todo: load gitproviders in the given keychain
    }
    
    public init(with keychain: Keychain) {
        self.keychain = keychain
        refresh()
    }
    
    func remove(_ gitProviderToRemove: GitProvider) {
        gitProviderToRemove.remove()
        refresh()
    }
}
