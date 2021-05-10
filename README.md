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



** Still under development, talk to Joe Hinkle if you have any questions or suggestions ** 

