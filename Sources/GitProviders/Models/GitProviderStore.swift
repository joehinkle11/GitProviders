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
        gitProviders = []
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
