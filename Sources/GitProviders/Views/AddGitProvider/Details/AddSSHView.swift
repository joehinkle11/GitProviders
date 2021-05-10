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
    
    func instruction(i: Int, text: String, link url: URL?, copyableText: String?) -> some View {
        HStack {
            Image(systemName: "\(i).circle")
            if let url = url {
                Link(text, destination: url)
            } else {
                Text(text)
            }
            if let copyableText = copyableText {
                CopiableCellView(copiableText: copyableText)
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
                }, footer: HStack {
                    Image(systemName: "externaldrive")
                    Text("This will grant access read/write permissions to your repository contents")
                    Spacer()
                }) {
                    instruction(i: 1, text: "Copy your public key", link: nil, copyableText: sshKey.publicKeyAsSSHFormat)
                    if let addSSHKeyLink = preset.addSSHKeyLink, let url = URL(string: addSSHKeyLink) {
                        instruction(i: 2, text: "Goto ", link: url, copyableText: nil)
                    } else {
                        instruction(i: 2, text: "Goto ", link: nil, copyableText: nil)
                    }
                    instruction(i: 3, text: "Paste your public key", link: nil, copyableText: nil)
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
