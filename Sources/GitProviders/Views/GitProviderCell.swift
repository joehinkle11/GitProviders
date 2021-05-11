//
//  GitProviderCell.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct GitProviderCell: View {
    let gitProvider: GitProvider
    
    var body: some View {
        if let baseKeyName = gitProvider.baseKeyName {
            NavigationLink(destination: GitProviderDetailsView(gitProvider: gitProvider)) {
                HStack {
                    Text(baseKeyName)
                    Spacer()
                    AccessImageView(hasAccess: gitProvider.hasRepoListAccess, sfSymbolBase: "text.badge")
                    AccessImageView(hasAccess: gitProvider.hasRepoContents, sfSymbolBase: "externaldrive.badge")
                }
            }
        }
    }
}
