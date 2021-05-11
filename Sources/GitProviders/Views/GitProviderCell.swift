//
//  GitProviderCell.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct GitProviderCell: View {
    let gitProvider: GitProvider
    @ObservedObject var gitProviderStore: GitProviderStore
    let appName: String
    
    var body: some View {
        if let baseKeyName = gitProvider.baseKeyName {
            NavigationLink(destination: GitProviderDetailsView(gitProviderStore: gitProviderStore, gitProvider: gitProvider, appName: appName)) {
                HStack {
                    if gitProvider.preset == .Custom {
                        Text("Custom - \(baseKeyName)")
                    } else {
                        Text(baseKeyName)
                    }
                    Spacer()
                    if let link = gitProvider.preset.domain ?? gitProvider.customDetails?.domain {
                        Text(link).font(.footnote).foregroundColor(.gray)
                    }
                    AccessImageView(hasAccess: gitProvider.hasRepoListAccess, sfSymbolBase: "text.badge")
                    AccessImageView(hasAccess: gitProvider.hasRepoContents, sfSymbolBase: "externaldrive.badge")
                }
            }
        }
    }
}
