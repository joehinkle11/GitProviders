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
