//
//  AddSSHView.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import SwiftUI

struct AddSSHView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let preset: GitProviderPresets
    
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
    
    func testConnection() {
        gitProviderStore.moveBackToFirstPage()
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
                    instruction(i: 5, text: "Test connection", onClick: testConnection)
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
