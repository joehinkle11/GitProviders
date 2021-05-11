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
    let appName: String
    
    @State private var deleteAlert = false
    
    var isEditable: Bool {
        editMode?.wrappedValue == .active || gitProvider.allSSHPublicKeys().count > 0
    }
    
    var mainBody: some View {
        List {
            if let domain = gitProvider.preset.domain ?? gitProvider.customDetails?.domain, let url = URL(string: "https://\(domain)") {
                Section(header: HStack {
                    Image(systemName: "link")
                    Text("Host Address")
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
                    Text("\(appName) \(gitProvider.hasRepoListAccess ? "can" : "cannot") see which repositories exist on your \(gitProvider.baseKeyName ?? "")").font(.footnote).foregroundColor(.gray)
                }
                HStack {
                    AccessImageView(hasAccess: gitProvider.hasRepoContents, sfSymbolBase: "externaldrive.badge")
                    Text("Repo Contents")
                    Spacer()
                    Text("\(appName) \(gitProvider.hasRepoContents ? "can" : "cannot") see the contents of repositories hosted on your \(gitProvider.baseKeyName ?? "")").font(.footnote).foregroundColor(.gray)
                }
                NavigationLink("Grant New Access Right", destination: AddGitProviderDetailsView(gitProviderStore: gitProviderStore, preset: gitProvider.preset, customDetails: gitProvider.customDetails)).foregroundColor(.blue)
            }
            ForEach(gitProvider.preset.supportedContentAccessMethods) { accessMethod in
                GitProviderDetailsAccessMethodSectionView(
                    gitProviderStore: gitProviderStore,
                    gitProvider: gitProvider,
                    accessMethod: accessMethod
                )
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody
            .navigationTitle("\(gitProvider.baseKeyName ?? "") Details")
            .navigationBarItems(trailing: isEditable ? EditButton().font(nil) : nil)
    }
}


struct GitProviderDetailsAccessMethodSectionView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let gitProvider: GitProvider
    let accessMethod: RepositoryAccessMethods
    
    var accessMethodDetailCells: [AccessMethodDetailCell] {
        gitProvider.createAccessMethodDetailCells(for: accessMethod, in: gitProviderStore)
    }
    
    @State private var showDeleteConfirmationAlert = false
    @State private var accessMethodDataToDisassociateI: Int?
    
    var body: some View {
        Section(header: HStack {
            accessMethod.icon.frame(maxWidth: 10)
            Text(accessMethod.listDescription)
            Spacer()
        }) {
            ForEach(accessMethodDetailCells) { publicKeyCell in
                publicKeyCell
            }.onDelete {
                if let first = $0.first, accessMethodDetailCells.count > first {
                    accessMethodDataToDisassociateI = first
                    showDeleteConfirmationAlert = true
                }
            }
            if accessMethodDetailCells.filter({
                $0.validOnThisDevice
            }).count == 0 {
                NavigationLink(accessMethod.setupMessage, destination: accessMethod.addView(for: gitProviderStore, preset: gitProvider.preset, customDetails: gitProvider.customDetails))
            }
        }.alert(isPresented: $showDeleteConfirmationAlert) {
            if let accessMethodDataToDisassociateI = accessMethodDataToDisassociateI, accessMethodDataToDisassociateI < accessMethodDetailCells.count {
                let accessMethodDataToDisassociate = accessMethodDetailCells[accessMethodDataToDisassociateI].accessMethodData
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text(accessMethod.removeMessage(accessMethodData: accessMethodDataToDisassociate, profileName: gitProvider.baseKeyName ?? "")),
                    primaryButton: .destructive(Text("Delete"), action: {
                        gitProvider.remove(accessMethodData: accessMethodDataToDisassociate)
                        gitProviderStore.refresh()
                    }),
                    secondaryButton: .cancel()
                )
            } else {
                return Alert(title: Text("Error"))
            }
        }
    }
}
