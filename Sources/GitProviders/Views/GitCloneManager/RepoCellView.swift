//
//  RepoCellView.swift
//  
//
//  Created by Joseph Hinkle on 5/13/21.
//

import SwiftUI
import GitAPI

struct RepoCellView: View {
    let repo: RepoModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(repo.name)
                Text(repo.sshURL)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(repo.isPrivate ? "private" : "public")
                Text("\(repo.size / 1000) KB")
            }
        }
    }
}
