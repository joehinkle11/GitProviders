//
//  GitProviderStore.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import Combine
import KeychainAccess

public final class GitProviderStore: ObservableObject {
    let keychain: Keychain
    
    @Published var gitProviders: [GitProvider] = []
    
    public init(with keychain: Keychain) {
        self.keychain = keychain
    }
}
