//
//  AddGitProviderView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct AddGitProviderView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    
    var mainBody: some View {
        List {
            Section(header: Text("Common Providers")) {
                AddGitProviderCellView(gitProviderStore: gitProviderStore, preset: .GitHub)
                AddGitProviderCellView(gitProviderStore: gitProviderStore, preset: .BitBucket)
                AddGitProviderCellView(gitProviderStore: gitProviderStore, preset: .GitLab)
            }
            Section(header: Text("Other")) {
                AddGitProviderCellView(gitProviderStore: gitProviderStore, preset: .Custom)
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody.navigationTitle("Add Git Provider")
    }
}
