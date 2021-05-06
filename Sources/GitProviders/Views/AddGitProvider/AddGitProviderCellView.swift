//
//  AddGitProviderCellView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI


struct AddGitProviderCellView: View {
    let preset: GitProviderPresets
    
    var body: some View {
        NavigationLink(preset.rawValue, destination: AddGitProviderDetailsView(preset: preset))
    }
}
