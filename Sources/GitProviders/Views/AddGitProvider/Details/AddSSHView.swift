//
//  AddSSHView.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import SwiftUI
import GitClient

struct AddSSHView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let preset: GitProviderPresets
    let customDetails: CustomProviderDetails?
    
    var gitProvider: GitProvider? {
        gitProviderStore.gitProviders.first { provider in
            switch preset {
            case .Custom:
                return provider.customDetails?.customName == customDetails?.customName
            default:
                return provider.baseKeyName == preset.rawValue
            }
        }
    }
    
    @State private var isTesting = false
    @State private var testingResult: Bool? = nil
    
    func instructionBase(i: Int, text: String) -> some View {
        HStack {
            Image(systemName: "\(i).circle")
            Text(text)
        }
    }
    
    @ViewBuilder
    func instruction(i: Int, text: String, link url: URL? = nil, copyableText: String? = nil, onClick: (() -> Void)? = nil) -> some View {
        if let url = url {
            Link(destination: url) {
                HStack {
                    instructionBase(i: i, text: text)
                    Spacer()
                    Text(url.absoluteString).font(.footnote).foregroundColor(.gray)
                }
            }
        } else if let onClick = onClick {
            Button(action: onClick) {
                instructionBase(i: i, text: text)
            }

        } else {
            instructionBase(i: i, text: text)
        }
        if let copyableText = copyableText {
            HStack {
                CopiableCellView(copiableText: copyableText).font(.footnote)
            }
        }
    }
    
    var hostName: String {
        if preset == .Custom {
            return customDetails?.customName ?? "Custom"
        } else {
            return preset.rawValue
        }
    }
    
    func testConnection(sshKey: SSHKey) {
        if let privateKey = sshKey.privateKeyAsPEMString, let domain = preset.domain ?? customDetails?.domain {
            isTesting = true
            DispatchQueue.global(qos: .background).async {
                let result = testSSH(privateKey: privateKey, forDomain: domain)
                if result {
                    // success, therefore mark this git provider as working with ssh
                    gitProvider?.add(sshKey: sshKey)
                } else {
                    // failed, therefore mark this git provider as NOT working with ssh
                    gitProvider?.remove(sshKey: sshKey)
                }
                DispatchQueue.main.async {
                    testingResult = result
                    isTesting = false
                }
            }
        }
    }
    
    var link: String? {
        if let addSSHKeyLink = preset.addSSHKeyLink {
            return addSSHKeyLink
        } else if let domain = customDetails?.domain {
            return "https://\(domain)"
        }
        return nil
    }
    
    var body: some View {
        List {
            CreateSSHIfNeededView(gitProviderStore: gitProviderStore) { sshKey in
                Section(header: HStack {
                    Image(systemName: "list.number")
                    Text("Setup Instructions")
                    Spacer()
                }, footer: Text("Note: This will grant access read/write permissions to your repository contents")) {
                    instruction(i: 1, text: "Copy your public key", copyableText: sshKey.publicKeyAsSSHFormat)
                    if let addSSHKeyLink = link, let url = URL(string: addSSHKeyLink) {
                        instruction(i: 2, text: "Goto \(hostName)", link: url)
                    } else {
                        instruction(i: 2, text: "Goto \(hostName)")
                    }
                    instruction(i: 3, text: "Login if needed")
                    if preset.addSSHKeyLink == nil {
                        // we should the user a link to the provider's homepage
                        instruction(i: 4, text: "Find where you can add SSH keys on \(hostName)'s site. Follow their instructions and paste your public key and save", link: nil, copyableText: nil)
                    } else {
                        // we should the user the exact link to where they add their ssh key
                        instruction(i: 4, text: "Paste your public key on \(hostName)'s page and save", link: nil, copyableText: nil)
                    }
                    if isTesting {
                        HStack {
                            ProgressView().padding(.trailing, 2)
                            Text("Testing...this can take up to 10 seconds or more")
                        }
                    } else {
                        instruction(i: 5, text: "Test connection") {
                            testConnection(sshKey: sshKey)
                        }
                    }
                    if let testingResult = testingResult {
                        if testingResult {
                            Text("Success").foregroundColor(.green).alert(isPresented: .constant(true), content: {
                                Alert(title: Text("Success"), message: Text("SSH is successfully setup for \(hostName)!"), dismissButton: .default(Text("Okay"), action: {
                                    gitProviderStore.moveBackToFirstPage()
                                }))
                            })
                        } else {
                            Text("Failed").foregroundColor(.red)
                        }
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Add SSH for \(preset.rawValue)")
    }
}
