//
//  AddGitProviderDetailsView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct AddGitProviderDetailsView: View {
    let preset: GitProviderPresets
    
    var mainBody: some View {
        List {
            Section(header: Text("Supported Access Methods")) {
                let accessMethods = preset.supportedAccessMethods
                if accessMethods.count == 0 {
                    Text("No access methods supported.")
                } else {
                    ForEach(accessMethods) { accessMethod in
                        Text(accessMethod.name)
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody.navigationTitle("Add \(preset.rawValue)")
    }
}
