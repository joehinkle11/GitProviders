//
//  RepositoryAccessMethods.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

enum RepositoryAccessMethods: String, Identifiable {
    var id: String { name }
    
    case AccessToken
    case SSH
    case Password // treated as an access token, but has a seperate case to create a distinction in the UI
    case OAuth
    
    var icon: Image {
        switch self {
        case .AccessToken:
            return Image(systemName: "circle.dashed")
        case .SSH:
            return Image(systemName: "key.fill")
        case .Password:
            return Image(systemName: "textformat.abc")
        case .OAuth:
            return Image(systemName: "lock.shield")
        }
    }
    
    var setupMessage: String? {
        switch self {
        case .AccessToken:
            return "Add an access token"
        case .SSH:
            return "Setup SSH for this device"
        case .Password:
            return nil
        case .OAuth:
            return "Setup OAuth for this device"
        }
    }
    
    var listDescription: String {
        switch self {
        case .AccessToken:
            return "Access Tokens"
        case .SSH:
            return "SSH Keys"
        case .Password:
            return name
        case .OAuth:
            return name
        }
    }
    
    func isValidOnThisDevice(gitProviderStore: GitProviderStore, accessMethodData: RepositoryAccessMethodData) -> Bool {
        switch self {
        case .AccessToken:
            fatalError("todo: check this device has this auth and that is isn't that we just know if it's existence")
        case .SSH:
            if let userSSHKey = gitProviderStore.sshKey,
               let cellPublicKeyData = (accessMethodData as? SSHAccessMethodData)?.publicKeyData {
                return userSSHKey.publicKeyData == cellPublicKeyData
            }
            return false
        case .Password:
            fatalError("todo: check this device has this auth and that is isn't that we just know if it's existence")
        case .OAuth:
            fatalError("todo: check this device has this auth and that is isn't that we just know if it's existence")
        }
    }
    
    func removeMessage(accessMethodData: RepositoryAccessMethodData, profileName: String) -> String {
        switch self {
        case .AccessToken:
            fatalError()
        case .SSH:
            return "Are you sure what want to disassociate the public key \((try? (accessMethodData as? SSHAccessMethodData)?.publicKeyData.publicPEMKeyToSSHFormat()) ?? "") with profile \(profileName)?"
        case .Password:
            fatalError()
        case .OAuth:
            fatalError()
        }
    }
    
    func isValidMessage(isValid: Bool) -> String? {
        switch self {
        case .AccessToken:
            fatalError()
        case .SSH:
            return "private key is \(isValid ? "" : "not ")on this device"
        case .Password:
            fatalError()
        case .OAuth:
            fatalError()
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
        case .Password:
            return AnyView(AddAccessTokenView(gitProviderStore: gitProviderStore, preset: preset, customDetails: customDetails, isPassword: true))
        case .OAuth:
            return AnyView(AddOAuthView(gitProviderStore: gitProviderStore, preset: preset, customDetails: customDetails))
        }
    }
    
    var name: String {
        switch self {
        case .AccessToken: return "Access Token"
        case .SSH: return rawValue
        case .Password: return rawValue
        case .OAuth: return rawValue
        }
    }
}
