# Git Providers

This package allows for the management of git hosting provider access tokens, credentials and ssh keys stored securely in Keychain with simple SwiftUI views.

## Example Usage

```swift
import SwiftUI
import GitProviders
import KeychainAccess

let gitProviderStore = GitProviderStore(with: Keychain())

struct ContentView: View {
    var body: some View {
        GitProvidersView(gitProviderStore: gitProviderStore, appName: "GitProvidersExample")
    }
}
```

## Running Tests

Extract `FakeCreds.zip` and dump it at `Tests/GitAPITests/FakeCreds` and fill out your credentials you'd like to test.  


## API

We can interact with the GitHub, Bitbucket and GitLab API through their shared base class `GitAPI`. This allows clients to not worry about which API the user is using. So for example, a client could decide to provide it's users a list of their repositories. For user A who logged in with GitHub, they will automatically interact with the GitHub API, but user B who logged in with GitLab will automatically interact with the GitLab API. Meanwhile the client doesn't know the difference between the types `GitHubAPI` and `GitLabAPI`, and is just consuming and interacting with the base `GitAPI`.

To pull this off, there are a set of shared models under the folder `Sources/GitAPI/APIModels/Internal`. These are where fictional models will be put.

For example:

Internal/RepoModel.swift        contains `struct RepoModel`
GitHub/RepoModel.swift         contains `struct BitBucketRepoModel`
BitBucket/RepoModel.swift     contains `struct GitLablRepoModel`
GitLabl/RepoModel.swift         contains `struct GitHubRepoModel`

`BitBucketRepoModel`, `GitLablRepoModel`, and `GitHubRepoModel` will all be internal to the Swift Package, but `RepoModel` will be public for the client to use. This way the client is never directly dealing with an API detail specific to GitHub and unrelated to BitBucket, and instead just focuses on the desired general function.

