//
//  AddGitProviderView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct AddGitProviderView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    
    @State private var showModal = true
    
    var presentsNotActive: [GitProviderPresets] {
        [.GitHub,.BitBucket,.GitLab].filter({ preset in
            let activeOneExists = gitProviderStore.gitProviders.contains(where: { provider in
                provider.isActive && provider.preset == preset
            })
            return !activeOneExists
        })
    }
    
    var listBody: some View {
        List {
            Section(header: Text("Common Providers")) {
                ForEach(presentsNotActive) { preset in
                    AddGitProviderCellView(gitProviderStore: gitProviderStore, preset: preset)
                }
            }
            Section(header: Text("Other")) {
                AddGitProviderCellView(gitProviderStore: gitProviderStore, preset: .Custom)
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    @ViewBuilder
    var mainBody: some View {
        if presentsNotActive.count > 0 {
            listBody
        } else {
            listBody.sheet(isPresented: $showModal, content: {
                AddCustomProvider(gitProviderStore: gitProviderStore, showThisModal: $showModal)
            })
        }
    }
    
    var body: some View {
        mainBody.navigationTitle("Add Git Provider")
    }
}
