//
//  GitProviderDetailsView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct GitProviderDetailsView: View {
    @Environment(\.editMode) var editMode
    
    @ObservedObject var gitProviderStore: GitProviderStore
    let gitProvider: GitProvider
    
    @State private var deleteAlert = false
    
    var isEditable: Bool {
        editMode?.wrappedValue == .active || gitProvider.allSSHPublicKeys().count > 0
    }
    
    var mainBody: some View {
        List {
            if let domain = gitProvider.customDetails?.domain, let url = URL(string: "https://\(domain)") {
                Section(header: HStack {
                    Image(systemName: "link")
                    Text("Custom Provider Host Address")
                    Spacer()
                }) {
                    Link(url.absoluteString, destination: url)
                }
            }
            Section(header: HStack {
                Image(systemName: "info.circle")
                Text("Access Rights Information")
                Spacer()
            }) {
                HStack {
                    AccessImageView(hasAccess: gitProvider.hasRepoListAccess, sfSymbolBase: "text.badge")
                    Text("Repo List")
                    Spacer()
                    Text("\(gitProvider.baseKeyName ?? "") \(gitProvider.hasRepoListAccess ? "has" : "does not have") the ability to see which repositories exist on the server").font(.footnote).foregroundColor(.gray)
                }
                HStack {
                    AccessImageView(hasAccess: gitProvider.hasRepoContents, sfSymbolBase: "externaldrive.badge")
                    Text("Repo Contents")
                    Spacer()
                    Text("\(gitProvider.baseKeyName ?? "") \(gitProvider.hasRepoContents ? "has" : "does not have") the ability to see the contents of repositories").font(.footnote).foregroundColor(.gray)
                }
                NavigationLink("Grant New Access Right", destination: AddGitProviderDetailsView(gitProviderStore: gitProviderStore, preset: gitProvider.preset, customDetails: gitProvider.customDetails)).foregroundColor(.blue)
            }
            GitProviderDetailsSSHSectionView(gitProviderStore: gitProviderStore, gitProvider: gitProvider)
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody
            .navigationTitle("\(gitProvider.baseKeyName ?? "") Details")
            .navigationBarItems(trailing: isEditable ? EditButton().font(nil) : nil)
    }
}


struct GitProviderDetailsSSHSectionView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let gitProvider: GitProvider
    
    var publicKeyCells: [SSHPublicKeyCell] {
        gitProvider.allSSHPublicKeys().map({
            SSHPublicKeyCell(userSSHKey: gitProviderStore.sshKey, cellPublicKeyData: $0)
        })
    }
    
    @State private var showDeleteConfirmationAlert = false
    @State private var publicKeyToDisassociate: Data?
    
    var body: some View {
        Section(header: HStack {
            Image(systemName: "key.fill")
            Text("SSH Keys")
            Spacer()
        }) {
            ForEach(publicKeyCells) { publicKeyCell in
                publicKeyCell
            }.onDelete {
                if let first = $0.first, publicKeyCells.count > first {
                    publicKeyToDisassociate = publicKeyCells[first].cellPublicKeyData
                    showDeleteConfirmationAlert = true
                }
            }
            if publicKeyCells.filter({
                $0.privateKeyIsOnDevice
            }).count == 0 {
                NavigationLink("Setup SSH for this device", destination: AddSSHView(gitProviderStore: gitProviderStore, preset: gitProvider.preset, customDetails: gitProvider.customDetails))
            }
        }.alert(isPresented: $showDeleteConfirmationAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Are you sure what want to disassociate the public key \((try? publicKeyToDisassociate?.publicPEMKeyToSSHFormat()) ?? "") with profile \(gitProvider.baseKeyName ?? "")?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    if let publicKeyToDisassociate = publicKeyToDisassociate {
                        gitProvider.remove(sshPublicKey: publicKeyToDisassociate)
                        gitProviderStore.refresh()
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}
