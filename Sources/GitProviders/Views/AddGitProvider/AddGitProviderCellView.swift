//
//  AddGitProviderCellView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI


struct AddGitProviderCellView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let preset: GitProviderPresets
    
    @State var showModal = false
    
    var body: some View {
        switch preset {
        case .Custom:
            Button(preset.rawValue) {
                showModal = true
            }.sheet(isPresented: $showModal, content: {
                AddCustomProvider(gitProviderStore: gitProviderStore, showThisModal: $showModal)
            })
        default:
            NavigationLink(preset.rawValue, destination: AddGitProviderDetailsView(gitProviderStore: gitProviderStore, preset: preset, customDetails: nil))
        }
    }
}
