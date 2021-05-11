//
//  SSHPublicKeyCell.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI

struct SSHPublicKeyCell: View, Identifiable {
    var id: Int {
        cellPublicKeyData.hashValue
    }
    let userSSHKey: SSHKey?
    let cellPublicKeyData: Data
    
    @State private var tapped = false
    
    var publicKey: String {
        (try? cellPublicKeyData.publicPEMKeyToSSHFormat()) ?? ""
    }
    
    var preview: some View {
        VStack(alignment: .leading) {
            if tapped {
                CopiableCellView(copiableText: publicKey)
            } else {
                Text(publicKey).font(.footnote).foregroundColor(.gray).lineLimit(1)
            }
        }
    }
    
    var privateKeyIsOnDevice: Bool {
        if let userSSHKey = userSSHKey, userSSHKey.publicKeyData == cellPublicKeyData {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 8) {
            preview
            HStack {
                Spacer()
                Text("private key is \(privateKeyIsOnDevice ? "" : "not ")on this device")
                    .font(.footnote).foregroundColor(privateKeyIsOnDevice ? .green : .red).opacity(0.8)
            }
        }.onTapGesture {
            tapped.toggle()
        }.animation(.easeOut)
    }
}
