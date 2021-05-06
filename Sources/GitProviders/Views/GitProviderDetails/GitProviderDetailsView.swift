//
//  GitProviderDetailsView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct GitProviderDetailsView: View {
    
    let gitProvider: GitProvider
    
    var mainBody: some View {
        List {
            Section(header: Text("Access Rights")) {
                if gitProvider.hasRepoListAccess {
                    
                }
                if gitProvider.hasRepoContents {
                    
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody.navigationTitle("\(gitProvider.providerName) Details")
    }
}
