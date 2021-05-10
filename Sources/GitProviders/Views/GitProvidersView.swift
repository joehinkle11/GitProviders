//
//  GitProvidersView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

public struct GitProvidersView: View {
    
    @ObservedObject var gitProviderStore: GitProviderStore
    let appName: String
    
    @State private var showAlert: Alerts? = nil
    
    @State private var gitProviderToRemove: GitProvider? = nil
    @State private var createSSHKeyWasSuccess = false
    @AppStorage("ssh_key_icloud_sync") private var iCloudSync = true
    
    public init(
        gitProviderStore: GitProviderStore,
        appName: String
    ) {
        self.gitProviderStore = gitProviderStore
        self.appName = appName
    }
    
    public var body: some View {
        NavigationView {
            mainBody.navigationTitle("Git Providers")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

extension GitProvidersView {
    var dataNotice: Text {
        (Text("\(appName) does NOT store any git provider credentials on its servers. Rather, all access tokens, ssh keys, and other sensitve information are stored \(Text("securely").bold()) in your keychain and optionally synced through the iCloud keychain. Such keys are only brought into memory at point of consumption and are otherwise safely stored in the Secure Enclave. Furthermore, \(appName) does NOT sync any repository code keys onto its servers. See our privacy policy for more information.")).font(.footnote)
    }
    var connectedProvidersHeader: some View {
        HStack {
            Image(systemName: "wifi")
            Text("Connected Providers")
            Spacer()
        }
    }
    var sshHeader: some View {
        HStack {
            Image(systemName: "key.fill")
            Text("SSH Key")
            Spacer()
            Link(
                destination: URL(string: "https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent")!
            ) {
                Image(systemName: "questionmark.circle")
            }
        }
    }
}
extension GitProvidersView {
    func createSSH(withICloud: Bool) {
        iCloudSync = withICloud
        gitProviderStore.sshKey = SSHKey.generateNew(for: gitProviderStore.keychain, withICloudSync: withICloud, keySize: ._2048, keyType: .RSA)
        createSSHKeyWasSuccess = gitProviderStore.sshKey != nil
        showAlert = .CreateSSHKeyResult
    }
    var showBottomPart: Bool {
        gitProviderStore.gitProviders.count > 0 || gitProviderStore.sshKey != nil
    }
    var mainBody: some View {
        List {
            Section(header: connectedProvidersHeader, footer: showBottomPart ? nil : dataNotice) {
                ForEach(gitProviderStore.gitProviders) { gitProvider in
                    GitProviderCell(gitProvider: gitProvider)
                }.onDelete {
                    if let first = $0.first, gitProviderStore.gitProviders.count > first {
                        gitProviderToRemove = gitProviderStore.gitProviders[first]
                        showAlert = .ShowRemoveConfirmation
                    }
                }
                NavigationLink(destination: AddGitProviderView(gitProviderStore: gitProviderStore)) {
                    Text("Add New Provider").foregroundColor(.blue)
                }
            }
            if showBottomPart {
                Section(header: sshHeader, footer: dataNotice) {
                    if let sshKey = gitProviderStore.sshKey {
                        NavigationLink("View SSH Key", destination: SSHKeyDetailsView(
                            sshKey: sshKey,
                            keychain: gitProviderStore.keychain,
                            appName: appName,
                            iCloudSync: $iCloudSync
                        ))
                    } else {
                        Button("Create an SSH Key") {
                            showAlert = .CreateSSHKey
                        }
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .alert(item: $showAlert) { alert in
            switch alert {
            case .ShowRemoveConfirmation:
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text("Are you sure what want to delete \(gitProviderToRemove?.providerName ?? "")?"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        if let gitProviderToRemove = gitProviderToRemove {
                            gitProviderStore.remove(gitProviderToRemove)
                        }
                    }),
                    secondaryButton: .cancel()
                )
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

extension GitProvidersView {
    enum Alerts: Int, Identifiable {
        var id: Int { rawValue }
        case ShowRemoveConfirmation
        case CreateSSHKey
        case CreateSSHKeyResult
    }
}
