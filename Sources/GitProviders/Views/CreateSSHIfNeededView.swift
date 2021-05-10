//
//  CreateSSHIfNeededView.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import SwiftUI

struct CreateSSHIfNeededView<HasSSHKeyBody: View>: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let hasSSHKeyBody: (_ sshKey: SSHKey) -> HasSSHKeyBody
    
    @State private var showAlert: Alerts? = nil
    @AppStorage("ssh_key_icloud_sync") private var iCloudSync = true
    @State private var createSSHKeyWasSuccess = false
    
    func createSSH(withICloud: Bool) {
        iCloudSync = withICloud
        gitProviderStore.sshKey = SSHKey.generateNew(for: gitProviderStore.keychain, withICloudSync: withICloud, keySize: ._2048, keyType: .RSA)
        createSSHKeyWasSuccess = gitProviderStore.sshKey != nil
        showAlert = .CreateSSHKeyResult
    }
    
    var body: some View {
        if let sshKey = gitProviderStore.sshKey {
            hasSSHKeyBody(sshKey)
        } else {
            Button("Create an SSH Key") {
                showAlert = .CreateSSHKey
            }.alert(item: $showAlert) { alert in
                switch alert {
                case .CreateSSHKey:
                    return Alert(
                        title: Text("Create SSH Key"),
                        message: Text("Would you like to synchronize your key securely through the iCloud Keychain?"),
                        primaryButton: .default(Text("Create and Sync"), action: {
                            createSSH(withICloud: true)
                        }),
                        secondaryButton: .destructive(Text("Create without Sync"), action: {
                            createSSH(withICloud: false)
                        })
                    )
                case .CreateSSHKeyResult:
                    return Alert(title: Text(createSSHKeyWasSuccess ? "Success" : "Failed"), message: Text(createSSHKeyWasSuccess ? "SSH creation succeeded" : "SSH creation failed"), dismissButton: .default(Text("Okay")))
                }
            }
        }
    }
}

extension CreateSSHIfNeededView {
    enum Alerts: Int, Identifiable {
        var id: Int { rawValue }
        case CreateSSHKey
        case CreateSSHKeyResult
    }
}
