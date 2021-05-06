//
//  SSHKeyDetailsView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct SSHKeyDetailsView: View {
    let sshKey: SSHKey
    
    @State private var showPrivate = false
    
    var mainBody: some View {
        List {
            Section(header: HStack {
                Image(systemName: "key.fill")
                Text("Your SSH Public Key (id_rsa.pub)")
                Spacer()
            }) {
                if let publicKey = sshKey.publicKey?.base64EncodedString() {
                    CopiableCellView(copiableTest: publicKey)
                }
                
            }
            Section(header: HStack {
                Image(systemName: "key.fill")
                Text("Your SSH Private Key (id_rsa)")
                Spacer()
            }) {
                if showPrivate {
                    if let publicKey = sshKey.publicKey?.base64EncodedString() {
                        CopiableCellView(copiableTest: publicKey)
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody.navigationTitle("SSH Key")
    }
}
