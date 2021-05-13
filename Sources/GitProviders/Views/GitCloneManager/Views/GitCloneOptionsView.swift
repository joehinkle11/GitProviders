//
//  GitCloneOptionsView.swift
//  
//
//  Created by Joseph Hinkle on 5/13/21.
//

import SwiftUI

public struct GitCloneOptionsView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let appName: String
    
    @State private var source = 0
    
    var selectedSource: CloneSource {
        sources[source]
    }
    
    var sources: [CloneSource] {
        gitProviderStore.gitProviders.map {
            .init(name: $0.userDescription, provider: $0)
        } + [.init(name: "Other", provider: nil)]
    }
    
    public init(
        gitProviderStore: GitProviderStore,
        appName: String
    ) {
        self.gitProviderStore = gitProviderStore
        self.appName = appName
    }
    
    public var body: some View {
        NavigationView {
            mainBody
                .navigationTitle("Git Clone")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

extension GitCloneOptionsView {
    var picker: some View {
        Picker(selectedSource.name, selection: $source) {
            ForEach(0..<sources.count) {
                Text(sources[$0].name)
            }
        }
    }
    var mainBody: some View {
        List {
            if sources.count <= 5 {
                picker.pickerStyle(SegmentedPickerStyle())
            } else {
                picker
            }
            Section(header: HStack {
                Text(selectedSource.name)
            }) {
                if let provider = selectedSource.provider {
                    providerSegment(provider: provider)
                } else {
                    customSegment
                }
            }
        }.listStyle(InsetGroupedListStyle())
    }
}

extension GitCloneOptionsView {
    var customSegment: some View {
        Text("Custom")
    }
}


extension GitCloneOptionsView {
    func providerSegment(provider: GitProvider) -> some View {
        Text(provider.userDescription)
    }
}
