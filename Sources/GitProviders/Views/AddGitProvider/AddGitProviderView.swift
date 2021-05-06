//
//  AddGitProviderView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct AddGitProviderView: View {
    
    var mainBody: some View {
        List {
            Section(header: Text("Common Providers")) {
                AddGitProviderCellView(preset: .GitHub)
                AddGitProviderCellView(preset: .BitBucket)
                AddGitProviderCellView(preset: .GitLab)
            }
            Section(header: Text("Other")) {
                AddGitProviderCellView(preset: .Custom)
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody.navigationTitle("Add Git Provider")
    }
}
