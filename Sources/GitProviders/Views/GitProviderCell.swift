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
        Text(gitProvider.providerName)
    }
}
