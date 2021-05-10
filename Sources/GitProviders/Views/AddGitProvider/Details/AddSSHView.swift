//
//  AddSSHView.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import SwiftUI

struct AddSSHView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    
    var body: some View {
        List {
            Section(header: HStack {
                Image(systemName: "externaldrive")
                Text("Grant Access to Repository Contents")
                Spacer()
            }) {
                
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
