//
//  RepositoryAccessMethods.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

enum RepositoryAccessMethods: Identifiable {
    var id: String { name }
    
    case AccessToken
    case SSH
    
    func addView(for gitProviderStore: GitProviderStore, preset: GitProviderPresets) -> AnyView {
        switch self {
        case .AccessToken:
            return AnyView(EmptyView()) // todo
        case .SSH:
            return AnyView(AddSSHView(gitProviderStore: gitProviderStore, preset: preset))
        }
    }
    
    var name: String {
        switch self {
        case .AccessToken:
            return "Access Token"
        case .SSH:
            return "SSH"
        }
    }
}
