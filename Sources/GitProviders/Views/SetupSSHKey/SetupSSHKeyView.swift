//
//  SetupSSHKeyView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct SetupSSHKeyView: View {
    let appName: String
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var mainBody: some View {
        List {
            Section(header: HStack {
                Image(systemName: "info.circle")
                Text("Information")
                Spacer()
            }) {
                Link("How to generate an SSH key on a computer", destination: URL(string: "https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent")!)
            }
            Section(header: HStack {
                Image(systemName: "key.fill")
                Text("Create SSH Key")
                Spacer()
            }, footer: Text("").font(.footnote)) {
                Button("Create on SSH Key for \(appName)") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody.navigationTitle("Create SSH Key")
    }
}
