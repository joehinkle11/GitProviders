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
        NavigationLink(destination: GitProviderDetailsView(gitProvider: gitProvider)) {
            HStack {
                Text(gitProvider.providerName)
                Spacer()
                AccessImageView(hasAccess: gitProvider.hasRepoListAccess, sfSymbolBase: "text.badge")
                AccessImageView(hasAccess: gitProvider.hasRepoContents, sfSymbolBase: "externaldrive.badge")
            }
        }
    }
}
