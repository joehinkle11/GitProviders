//
//  AccessMethodDetailCell.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI

struct AccessMethodDetailCell: View, Identifiable {
    var id: Int { accessMethodData.hash }
    let gitProviderStore: GitProviderStore
    let accessMethodData: RepositoryAccessMethodData
    let accessMethod: RepositoryAccessMethods
    
    @State private var tapped = false
    
    var validOnThisDevice: Bool {
        accessMethod.isValidOnThisDevice(gitProviderStore: gitProviderStore, accessMethodData: accessMethodData)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            AccessMethodDetailCellPreview(data: accessMethodData, tapped: tapped)
            if let message = accessMethod.isValidMessage(isValid: validOnThisDevice) {
                HStack {
                    Spacer()
                    Text(message)
                        .font(.footnote).foregroundColor(validOnThisDevice ? .green : .red).opacity(0.8)
                }
            }
        }.onTapGesture {
            tapped.toggle()
        }.animation(.easeOut)
    }
}


struct AccessMethodDetailCellPreview: View {
    
    let data: RepositoryAccessMethodData
    let tapped: Bool
    
    var body: some View {
        if let data = data as? SSHAccessMethodData {
            VStack(alignment: .leading) {
                let publicKey = (try? data.publicKeyData.publicPEMKeyToSSHFormat()) ?? ""
                if tapped {
                    CopiableCellView(copiableText: publicKey)
                } else {
                    Text(publicKey).font(.footnote).foregroundColor(.gray).lineLimit(1)
                }
            }
        }
    }
}
