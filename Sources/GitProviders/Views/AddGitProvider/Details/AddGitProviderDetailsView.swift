//
//  AddGitProviderDetailsView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct AddGitProviderDetailsView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let preset: GitProviderPresets
    let customDetails: CustomProviderDetails?
    
    var mainBody: some View {
        List {
            Section(header: HStack {
                Image(systemName: "externaldrive")
                Text("Grant Access to Repository Contents")
                Spacer()
            }) {
                let accessMethods = preset.supportedContentAccessMethods
                ForEach(accessMethods) { accessMethod in
                    NavigationLink(accessMethod.name, destination: accessMethod.addView(for: gitProviderStore, preset: preset, customDetails: customDetails).navigationTitle("Add \(accessMethod.name) for \(preset.rawValue)"))
                }
            }
            Section(header: HStack {
                Image(systemName: "text.justify")
                Text("Grant Access to List of Repositories")
                Spacer()
            }) {
                let accessMethods = preset.supportedRepoListAccessMethods
                if accessMethods.count == 0 {
                    Text("No repo list access methods supported for \(preset.rawValue) hosts.")
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
