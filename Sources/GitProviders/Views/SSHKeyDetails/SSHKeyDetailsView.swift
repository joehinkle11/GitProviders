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
    @AppStorage("ssh_key_icloud_sync") private var iCloudSync = true
    @State var keyType: KeyType = .RSA
    @State var keySize: KeySize = ._2048
    
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
                        CopiableCellView(copiableText: publicKey)
                    }
                    ForEach(GitProviderPresets.allCases) { preset in
                        if let addSSHKeyLink = preset.addSSHKeyLink, let url = URL(string: addSSHKeyLink) {
                            Link("Add to \(preset.rawValue)", destination: url)
                        }
                    }
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
                                CopiableCellView(copiableText: privateKey)
                            }
                        } else {
                            Button("Show Private Key (not recommended)") {
                                modal = .ShowPrivateConform
                            }
                        }
                    }
                }
            }
            if showAdvanced {
                Section(header: HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Regenerate Keys")
                    Spacer()
                }) {
                    Toggle(isOn: $iCloudSync, label: {
                        Text("iCloud Sync")
                    })
                    Picker("Key Type", selection: $keyType) {
                        ForEach(KeyType.allCases) { keyTypeOption in
                            Text("\(keyTypeOption.rawValue)").tag(keyTypeOption)
                        }
                    }
                    Picker("Key Size", selection: $keySize) {
                        ForEach(KeySize.allCases) { keySizeOption in
                            Text("\(keySizeOption.rawValue) bits").tag(keySizeOption)
                        }
                    }
                    Button("Regenerate") {
                        modal = .RegenKeyConfirm
                    }
                }
            } else {
                Section(header: HStack {
                    Image(systemName: "gear")
                    Text("Advanced")
                    Spacer()
                }) {
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
                    if let newSSHKey: SSHKey = .generateNew(for: keychain, withICloudSync: iCloudSync, keySize: keySize, keyType: keyType) {
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
