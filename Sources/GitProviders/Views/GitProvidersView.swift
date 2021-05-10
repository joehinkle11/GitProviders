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
    
    @State private var showDeleteConfirmationAlert = false
    
    @State private var gitProviderToRemove: GitProvider? = nil
    
    public init(
        gitProviderStore: GitProviderStore,
        appName: String
    ) {
        self.gitProviderStore = gitProviderStore
        self.appName = appName
    }
    
    public var body: some View {
        NavigationView {
            mainBody
                .navigationTitle("Git Providers")
                .navigationBarItems(trailing: gitProviderStore.gitProviders.count == 0 ? nil : EditButton())
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
                        showDeleteConfirmationAlert = true
                    }
                }
                NavigationLink(destination: AddGitProviderView(gitProviderStore: gitProviderStore)) {
                    Text("Add New Provider").foregroundColor(.blue)
                }
            }
            if showBottomPart {
                Section(header: sshHeader, footer: dataNotice) {
                    CreateSSHIfNeededView(gitProviderStore: gitProviderStore) { sshKey in
                        NavigationLink("View SSH Key", destination: SSHKeyDetailsView(
                            sshKey: sshKey,
                            keychain: gitProviderStore.keychain,
                            appName: appName
                        ))
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .alert(isPresented: $showDeleteConfirmationAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Are you sure what want to delete \(gitProviderToRemove?.providerName ?? "")?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    if let gitProviderToRemove = gitProviderToRemove {
                        gitProviderStore.remove(gitProviderToRemove)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}
