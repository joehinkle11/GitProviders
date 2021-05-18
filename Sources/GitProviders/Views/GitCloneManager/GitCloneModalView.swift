//
//  GitCloneModalView.swift
//  
//
//  Created by Joseph Hinkle on 5/14/21.
//

import SwiftUI
import GitClient
import GitAPI

struct GitCloneModalView: View {
    
    let closeModal: () -> Void
    @Binding var selectedRepo: RepoModel?
    @Binding var fromGitProvider: GitProvider?
    @State var credOptions: [AnyRepositoryAccessMethodData]
    
    @State private var name: String = ""
    @State private var repoURL: String = ""
    @State private var repoURL_https: String? = nil
    @State private var repoURL_ssh: String? = nil
    @State private var selectedCred: AnyRepositoryAccessMethodData = .init(UnauthenticatedAccessMethodData())
    @State private var showCredDetails = false
    
    @ObservedObject var cloningStatus: CloningStatus
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
        selectedCred.raw is SSHAccessMethodData
    }
    
    var body: some View {
        NavigationView {
            mainBody
                .blur(radius: isCloning ? 2.0 : 0)
                .overlay(cloningStatus.statusOverlay)
                .navigationBarTitle("Clone Options", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel", action: closeModal),
                    trailing: Button("Clone with \(usingSSH ? "SSH" : "HTTPS")") {
                        if let credentials = selectedCred.toSwiftGit2Credentials(),
                           let url = URL(string: repoURL) {
                            DispatchQueue.global().async {
                                GitClient.clone(
                                    with: credentials,
                                    from: url,
                                    named: name
                                ) { success, completedObjects, totalObjects, message in
                                    DispatchQueue.main.async {
                                        self.cloningStatus.status = (success, completedObjects, totalObjects, message)
                                    }
                                }
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
            Text(selectedCred.userDescription).font(.footnote).foregroundColor(.gray)
        }
    }
    
    var selectCredDetails: some View {
        List {
            ForEach(credOptions) { credOption in
                Button {
                    selectedCred = credOption
                    if credOption.raw is SSHAccessMethodData {
                        if repoURL == repoURL_https && repoURL_https != "" && repoURL_ssh != "" {
                            if let repoURL_ssh = repoURL_ssh {
                                repoURL = repoURL_ssh
                            }
                        }
                    } else if credOption.raw is AccessTokenAccessMethodData {
                        if repoURL == repoURL_ssh && repoURL_https != "" && repoURL_ssh != "" {
                            if let repoURL_https = repoURL_https {
                                repoURL = repoURL_https
                            }
                        }
                    }
                    showCredDetails = false
                } label: {
                    HStack {
                        if selectedCred.id == credOption.id {
                            Image(systemName: "checkmark")
                        }
                        Text(credOption.userDescription)
                        Spacer()
                    }
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
        .onAppear {
            if let repoModel = selectedRepo {
                name = repoModel.name
                repoURL = repoModel.httpsURL
                selectedRepo = nil
                repoURL_https = repoModel.httpsURL
                repoURL_ssh = repoModel.sshURL
            }
            if let gitProvider = fromGitProvider,
               let first = gitProvider.allAnyRepositoryAccessMethodDatas.first {
                selectedCred = first
                fromGitProvider = nil
            }
        }
    }
}
