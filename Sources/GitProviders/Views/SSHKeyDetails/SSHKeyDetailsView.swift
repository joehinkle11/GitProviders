//
//  SSHKeyDetailsView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI
import KeychainAccess

struct SSHKeyDetailsView: View {
    @State var sshKey: SSHKey? = nil
    let keychain: Keychain
    let appName: String
    @Binding var iCloudSync: Bool
    
    @State private var showPublicKeyAsSSH = true
    @State private var showPrivate = false
    @State private var showAdvanced = false
    @State private var modal: Modal? = nil
    
    var mainBody: some View {
        List {
            if let sshKey = sshKey {
                Section(header: HStack {
                    Image(systemName: "key.fill")
                    Text("Your SSH Public Key (id_rsa.pub)")
                    Spacer()
                    Button("Show in \(showPublicKeyAsSSH ? "PEM Format" : "Open SSH Format")") {
                        showPublicKeyAsSSH.toggle()
                    }
                }) {
                    if let publicKey = showPublicKeyAsSSH ? sshKey.publicKeyAsSSHFormat : sshKey.publicKeyAsPEMFormat {
                        CopiableCellView(copiableTest: publicKey)
                    }
                    Link("Add to GitHub", destination: URL(string: "https://github.com/settings/ssh/new")!)
                    Link("Add to BitBucket", destination: URL(string: "https://bitbucket.org/account/settings/ssh-keys/")!)
                    Link("Add to GitLab", destination: URL(string: "https://gitlab.com/-/profile/keys")!)
                }
            }
            if showAdvanced {
                if let sshKey = sshKey {
                    Section(header: HStack {
                        Image(systemName: "key.fill")
                        Text("Your SSH Private Key (id_rsa)")
                        Spacer()
                    }) {
                        if showPrivate {
                            if let privateKey = sshKey.privateKeyAsPEMString {
                                CopiableCellView(copiableTest: privateKey)
                            }
                        } else {
                            Button("Show Private Key (not recommended)") {
                                modal = .ShowPrivateConform
                            }
                        }
                    }
                }
            }
            Section(header: HStack {
                Image(systemName: "gear")
                Text("Advanced")
                Spacer()
            }) {
                if showAdvanced {
                    Toggle(isOn: $iCloudSync, label: {
                        Text("iCloud Sync \(Text("(only applies on next key regeneration)").font(.footnote))")
                    })
                    Button("Regenerate Keys") {
                        modal = .RegenKeyConfirm
                    }
                } else {
                    Button("Show Advanced") {
                        showAdvanced = true
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .alert(item: $modal) { modal in
            switch modal {
            case .RegenKeyConfirm:
                return Alert(title: Text("Are you sure?"), message: Text("If you regenerating yours keys, you will lose your old keys."), primaryButton: .destructive(Text("Regenerate")) {
                    sshKey = nil
                    if let newSSHKey: SSHKey = .generateNew(for: keychain, withICloudSync: iCloudSync) {
                        sshKey = newSSHKey
                    }
                }, secondaryButton: .cancel())
            case .ShowPrivateConform:
                return Alert(title: Text("Are you sure?"), message: Text("You should \(Text("never").bold()) give you private key to anyone, nor should you even access it here. Only proceed if you are a developer who knows what he or she is doing.\n\n\(appName) retains your private key securely in the Keychain, syncs across the iCloud Keychain if enabled, and only loads your private key into memory when being consumed by the git client."), primaryButton: .destructive(Text("Show Private Key")) {
                    showPrivate = true
                }, secondaryButton: .cancel())
            }
        }
    }
    
    var body: some View {
        mainBody.navigationTitle("SSH Key")
    }
}


extension SSHKeyDetailsView {
    enum Modal: Int, Identifiable {
        var id: Int { self.rawValue }
        case RegenKeyConfirm
        case ShowPrivateConform
    }
}
