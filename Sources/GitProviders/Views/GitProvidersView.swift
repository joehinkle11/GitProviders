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
    
    @State private var showRemoveConfirmation = false
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
            mainBody.navigationTitle("Git Providers")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

extension GitProvidersView {
    var dataNotice: Text {
        (Text("\(appName) does NOT store any git provider credentials on its servers. Rather, all access tokens are stored \(Text("securely").bold()) in your iCloud keychain. Neither does \(appName) sync any repository code onto its servers. See our privacy policy for more information.")).font(.footnote)
    }
    var connectedProvidersHeader: some View {
        HStack {
            Text("Connected Providers")
            Spacer()
            NavigationLink(destination: AddGitProviderView()) {
                HStack {
                    Text("Add")
                    Image(systemName: "plus.circle.fill").renderingMode(.original).scaleEffect(1.5)
                }
            }
        }
    }
    var mainBody: some View {
        List {
            Section(header: connectedProvidersHeader, footer: dataNotice) {
                if gitProviderStore.gitProviders.count == 0 {
                    Text("No providers.")
                }
                ForEach(gitProviderStore.gitProviders) { gitProvider in
                    GitProviderCell(gitProvider: gitProvider)
                }.onDelete {
                    if let first = $0.first, gitProviderStore.gitProviders.count > first {
                        gitProviderToRemove = gitProviderStore.gitProviders[first]
                        showRemoveConfirmation = true
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .alert(isPresented: $showRemoveConfirmation) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Are you sure what want to delete \("todo")?"),
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
