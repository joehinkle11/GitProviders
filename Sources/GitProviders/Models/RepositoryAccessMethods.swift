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
    
    var icon: Image {
        switch self {
        case .AccessToken:
            return Image(systemName: "circle.dashed")
        case .SSH:
            return Image(systemName: "key.fill")
        }
    }
    
    var setupMessage: String {
        switch self {
        case .AccessToken:
            return "Add an access token"
        case .SSH:
            return "Setup SSH for this device"
        }
    }
    
    var listDescription: String {
        switch self {
        case .AccessToken:
            return "Access Tokens"
        case .SSH:
            return "SSH Keys"
        }
    }
    
    func isValidOnThisDevice(gitProviderStore: GitProviderStore, accessMethodData: RepositoryAccessMethodData) -> Bool {
        switch self {
        case .AccessToken:
            return true
        case .SSH:
            if let userSSHKey = gitProviderStore.sshKey,
               let cellPublicKeyData = (accessMethodData as? SSHAccessMethodData)?.publicKeyData {
                return userSSHKey.publicKeyData == cellPublicKeyData
            }
            return false
        }
    }
    
    func removeMessage(accessMethodData: RepositoryAccessMethodData, profileName: String) -> String {
        switch self {
        case .AccessToken:
            fatalError()
        case .SSH:
            return "Are you sure what want to disassociate the public key \((try? (accessMethodData as? SSHAccessMethodData)?.publicKeyData.publicPEMKeyToSSHFormat()) ?? "") with profile \(profileName)?"
        }
    }
    
    func isValidMessage(isValid: Bool) -> String? {
        switch self {
        case .AccessToken:
            return nil
        case .SSH:
            return "private key is \(isValid ? "" : "not ")on this device"
        }
    }
    
    func addView(
        for gitProviderStore: GitProviderStore,
        preset: GitProviderPresets,
        customDetails: CustomProviderDetails?
    ) -> AnyView {
        switch self {
        case .AccessToken:
            return AnyView(AddAccessTokenView(gitProviderStore: gitProviderStore, preset: preset, customDetails: customDetails))
        case .SSH:
            return AnyView(AddSSHView(gitProviderStore: gitProviderStore, preset: preset, customDetails: customDetails))
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
