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
            return "your custom hosting provider"
        } else {
            return preset.rawValue
        }
    }
    
    func testConnection(sshKey: SSHKey) {
        if let privateKey = sshKey.privateKeyAsPEMString, let domain = preset.domain {
            isTesting = true
            DispatchQueue.global(qos: .background).async {
                let result = testSSH(privateKey: privateKey, forDomain: domain)
                if result {
                    // success, therefore mark this git provider as working with ssh
                } else {
                    // failed, therefore mark this git provider as NOT working with ssh
                }
                DispatchQueue.main.async {
                    testingResult = result
                    isTesting = false
                }
            }
        }
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
                    if let addSSHKeyLink = preset.addSSHKeyLink, let url = URL(string: addSSHKeyLink) {
                        instruction(i: 2, text: "Goto \(hostName)", link: url)
                    } else {
                        instruction(i: 2, text: "Goto \(hostName)")
                    }
                    instruction(i: 3, text: "Login if needed")
                    instruction(i: 4, text: "Paste your public key on \(hostName)'s page and save", link: nil, copyableText: nil)
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
                            Text("Failed").foregroundColor(.red)
                        } else {
                            Text("Success").foregroundColor(.green)
//                            Button("Back ")
                        }
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
