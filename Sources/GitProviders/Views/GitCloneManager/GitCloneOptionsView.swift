//
//  GitCloneOptionsView.swift
//  
//
//  Created by Joseph Hinkle on 5/13/21.
//

import SwiftUI
import GitAPI

public struct GitCloneOptionsView: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    let appName: String
    
    @State private var source = 0
    @State private var repos: [Int : [RepoModel]] = [:]
    @State private var hasDownloaded: [Int : Bool] = [:]
    
    @State private var searchText = ""
    @State private var showSetup = false
    
    var selectedSource: CloneSource? {
        return sources.first {
            $0.id == source
        }
    }
    
    var sources: [CloneSource] {
        gitProviderStore.gitProviders.filter {
            $0.hasRepoListAccess
        }.map {
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
                .navigationBarItems(trailing: Button(action: {
                    showSetup = true
                }, label: {
                    Image(systemName: "gearshape.fill")
                }))
        }.navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSetup) {
            GitProvidersView(gitProviderStore: gitProviderStore, appName: appName)
        }
    }
}

extension GitCloneOptionsView {
    var picker: some View {
        Picker(selectedSource?.name ?? "Select a Source", selection: $source) {
            ForEach(sources) { source in
                Text(source.name)
            }
        }
    }
    var mainBody: some View {
        VStack(spacing: 0) {
            if sources.count > 1 {
                if sources.count <= 5 {
                    picker.pickerStyle(SegmentedPickerStyle())
                } else {
                    picker
                }
            }
            if repos.count > 0 {
                SearchBar(text: $searchText, placeholder: "search...")
                Divider()
            }
            List {
                if let selectedSource = selectedSource {
                    if let provider = selectedSource.provider {
                        providerSegment(provider: provider, selectedSource: selectedSource)
                    } else {
                        customSegment(selectedSource: selectedSource)
                    }
                } else {
                    Text("No source selected").onAppear {
                        if let first = sources.first {
                            source = first.id
                        }
                    }
                }
            }.listStyle(InsetGroupedListStyle())
        }
    }
}

extension GitCloneOptionsView {
    func customSegment(selectedSource: CloneSource) -> some View {
        Section(header: HStack {
            Text("Your Private Repos on \(selectedSource.name)")
        }) {
            Text("No private repos found on your ")
        }
    }
}


extension GitCloneOptionsView {
    @ViewBuilder
    func providerSegment(provider: GitProvider, selectedSource: CloneSource) -> some View {
        let repos = self.repos[source] ?? []
        let privateRepos = repos.filter {
            $0.isPrivate
        }.filter {
            $0.searchScore(against: searchText) > 0
        }.sorted {
            if searchText == "" {
                return $0.updatedAt > $1.updatedAt
            } else {
                let score0 = $0.searchScore(against: searchText)
                let score1 = $1.searchScore(against: searchText)
                if score0 > score1 {
                    return true
                } else if score0 < score1 {
                    return false
                } else {
                    return $0.updatedAt > $1.updatedAt
                }
            }
        }
        let publicRepos = repos.filter {
            !$0.isPrivate
        }.filter {
            $0.searchScore(against: searchText) > 0
        }.sorted {
            if searchText == "" {
                return $0.updatedAt > $1.updatedAt
            } else {
                let score0 = $0.searchScore(against: searchText)
                let score1 = $1.searchScore(against: searchText)
                if score0 > score1 {
                    return true
                } else if score0 < score1 {
                    return false
                } else {
                    return $0.updatedAt > $1.updatedAt
                }
            }
        }
        Group {
            if searchText == "" {
                Section(header: HStack {
                    Text("Your Private Repos on \(selectedSource.name)")
                }) {
                    if privateRepos.count == 0 {
                        Text("No private repos found on your \(provider.userDescription)")
                    }
                    ForEach(privateRepos) { repo in
                        RepoCellView(repo: repo)
                    }
                }
                Section(header: HStack {
                    Text("Your Public Repos on \(selectedSource.name)")
                }) {
                    if publicRepos.count == 0 {
                        Text("No public repos found on your \(provider.userDescription)")
                    }
                    ForEach(publicRepos) { repo in
                        RepoCellView(repo: repo)
                    }
                }
            } else {
                Section(header: HStack {
                    Text("\(selectedSource.name) Search Results")
                }) {
                    if privateRepos.count == 0 {
                        Text("No matches for \(searchText)")
                    }
                    ForEach(privateRepos + publicRepos) { repo in
                        RepoCellView(repo: repo)
                    }
                }
            }
        }.onAppear {
            if (hasDownloaded[source] ?? false) == false {
//                provider.getRepos { repos, noAPISupport in
//                    if let repos = repos {
//                        self.repos[source] = repos
//                        hasDownloaded[source] = true
//                    } else {
//                        if noAPISupport {
//                            hasDownloaded[source] = true
//                        }
//                    }
//                }
            }
        }
    }
}

extension RepoModel {
    func searchScore(against searchText: String) -> Int {
        if searchText == "" {
            return 1
        }
        var score = 0
        let name = self.name.lowercased()
        let searchText = searchText.lowercased()
        if searchText == name {
            score += 1000
        }
        if name.contains(searchText) {
            score += 500
        }
        if name.hasPrefix(searchText) {
            score += 100
        }
        return score
    }
}
