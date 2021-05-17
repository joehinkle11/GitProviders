//
//  GitCloneModalView.swift
//  
//
//  Created by Joseph Hinkle on 5/14/21.
//

import SwiftUI
import GitClient

struct GitCloneModalView: View {
    
    let closeModal: () -> Void
    
    @State var name: String = ""
    @State var repoURL: String = ""
    @State var selectedCred: AnyRepositoryAccessMethodData? = nil
    @State var credOptions: [AnyRepositoryAccessMethodData] = [.init(UnauthenticatedAccessMethodData())]
    @State var showCredDetails = false
    
    @Binding var cloningStatus: CloningStatus
    var isCloning: Bool {
        cloningStatus.status != nil
    }
    
    var cleanedNickname: String {
        name
    }
    
    var dataIsInvalid: Bool {
        cleanedNickname == "" || repoURL == ""
    }
    
    var repoIsHTTP: Bool {
        true
    }
    
    var usingSSH: Bool {
        selectedCred?.raw is SSHAccessMethodData
    }
    
    var body: some View {
        NavigationView {
            mainBody
                .blur(radius: isCloning ? 2.0 : 0)
                .overlay(Group {
                    if let status = cloningStatus.status {
                        if let completedObjects = status.completedObjects, let totalObjects = status.totalObjects {
                            ProgressView("Cloning...(\(status.completedObjects)/\(status.totalObjects)) objects")
                        } else if status {
                            EmptyView
                        }
//                        ProgressView("Cloning...\(status.completedObjects)/\(status.totalObjects)) objects")
                    }
                })
                .navigationBarTitle("Clone Options", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel", action: closeModal),
                    trailing: Button("Clone with \(usingSSH ? "SSH" : "HTTPS")") {
                        if let credentials = selectedCred?.toSwiftGit2Credentials(),
                           let url = URL(string: repoURL) {
                            GitClient.clone(
                                with: credentials,
                                from: url,
                                named: name
                            ) { _, _ ,_ , _ in
                                self.cloningStatus = .init()
                            }
                        } else {
                            fatalError()
                        }
                    }.disabled(dataIsInvalid).opacity(dataIsInvalid ? 0.5 : 1)
                ).disabled(isCloning)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    var selectedCredCellText: some View {
        HStack {
            Text("Credentials")
            Spacer()
            Text(selectedCred?.userDescription ?? "Unauthenticated").font(.footnote).foregroundColor(.gray)
        }
    }
    
    var selectCredDetails: some View {
        List {
            ForEach(credOptions) { credOption in
                Button(credOption.userDescription) {
                    selectedCred = credOption
                    showCredDetails = false
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Credentials")
    }
    
    var mainBody: some View {
        List {
            Section {
                HStack {
                    Text("Nickname:")
                    TextField("My Project", text: $name)
                    Spacer()
                    Text(cleanedNickname).font(.footnote).foregroundColor(.gray)
                }
                VStack {
                    HStack {
                        Text("URL:")
                        TextField(usingSSH ? "git@example.com:user/example.git" : "https://example.com/user/example.git", text: $repoURL)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        PasteButton(into: $repoURL).buttonStyle(BorderlessButtonStyle())
                    }
                }
                NavigationLink(destination: selectCredDetails, isActive: $showCredDetails) {
                    selectedCredCellText
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
