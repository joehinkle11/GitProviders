//
//  AddAccessTokenView.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI
import GitAPI

struct AddAccessTokenView: View, InstructionView {
    typealias T = (username: String, passOrAccessToken: String, gitClient: GitAPI)
    
    @ObservedObject var gitProviderStore: GitProviderStore
    let preset: GitProviderPresets
    let customDetails: CustomProviderDetails?
    var isPassword: Bool = false // if we are actually setuping up a password, and not an access token
    
    @State var isTesting = false
    @State var testingResult: Bool? = nil
    
    @State private var username = ""
    @State private var passwordOrAccessToken = ""
    @State private var iCloudSync = true
    
    @State private var verifiedPerms: [PermScope] = []
    
    @State private var missingRepoList = false
    @State private var missingRepoContents = false
    
    func testConnection(
        using authItem: (username: String, passOrAccessToken: String, gitClient: GitAPI)
    ) {
        isTesting = true
        DispatchQueue.global(qos: .background).async {
            authItem.gitClient.userInfo = .init(username: authItem.username, authToken: authItem.passOrAccessToken)
            authItem.gitClient.fetchGrantedScopes { perms, _ in
                DispatchQueue.main.async {
                    if let perms = perms {
                        verifiedPerms = perms
                        let hasRepoContents = verifiedPerms.contains(where: {
                            if case .repoContents = $0 {
                                return true
                            } else {
                                return false
                            }
                        })
                        let hasRepoList = verifiedPerms.contains(where: {
                            if case .repoList = $0 {
                                return true
                            } else {
                                return false
                            }
                        })
                        missingRepoContents = !hasRepoContents
                        missingRepoList = !hasRepoList
                        testingResult = hasRepoContents && hasRepoList
                    } else {
                        testingResult = false
                    }
                    isTesting = false
                }
            }
        }
    }
    
    func forceAdd(authItem: (username: String, passOrAccessToken: String, gitClient: GitAPI)) {
        forceAdd(username: authItem.username, passOrAccessToken: authItem.passOrAccessToken)
    }
    func forceAdd(username: String, passOrAccessToken: String) {
        gitProvider?.save(
            accessTokenOrPassword: AccessTokenOrPassword(
                username: username,
                accessTokenOrPassword: passOrAccessToken,
                isPassword: isPassword
            ),
            syncs: iCloudSync
        )
    }
    
    var setupAccessTokenLink: String? {
        if let addSSHKeyLink = preset.addAccessTokenLink {
            return addSSHKeyLink
        } else if let domain = customDetails?.domain {
            return "https://\(domain)"
        }
        return nil
    }
    
    var badPracticeMessage: String {
        var name = ""
        var evenText = ""
        switch preset {
        case .Custom:
            evenText = ", even for custom hosting providers"
        default:
            name = preset.rawValue + " "
        }
        return "It is bad practice to use your real \(name)password\(evenText). Furthermore, many hosting providers are no longer allowing users to clone repositories using their real passwords, so it may not be possible to setup password authentication for this provider. Consider setting up with another authentication method like SSH or with personal access tokens."
    }
    
    var passwordIsNotReady: Bool {
        username == "" || passwordOrAccessToken == ""
    }
    
    func forceAddWithoutTestingStep(i: Int) -> some View {
        instruction(i: i, text: isPassword ? "Add Password" : "Add Access Token") {
            forceAdd(username: username, passOrAccessToken: passwordOrAccessToken)
            gitProviderStore.moveBackToFirstPage()
        }.disabled(passwordIsNotReady).opacity(passwordIsNotReady ? 0.5 : 1)
    }
    
    @ViewBuilder
    func listPart2(startI: Int) -> some View {
        instruction(
            i: startI + 1,
            text: "Enter your \(hostName) username below:",
            input: ("username", $username)
        )
        instruction(
            i: startI + 2,
            text: "Enter your\(isPassword ? "" : " new") \(hostName) \(isPassword ? "password" : "access token") below:",
            secureInput: (isPassword ? "password" : "access token", $passwordOrAccessToken)
        )
        instruction(i: startI + 3, text: "Sync securely over iCloud Keychain? (recommended)", toggle: $iCloudSync)
        if isPassword {
            forceAddWithoutTestingStep(i: startI + 4)
        } else {
            if let gitAPI = preset.api {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        testingStep(i: startI + 4, with: (username: username, passOrAccessToken: passwordOrAccessToken, gitClient: gitAPI), successMessage: "Access token is successfully setup for \(hostName)!")
                    }
                    if testingResult == false {
                        if missingRepoContents {
                            Text("Missing permission(s) required for accessing repository contents").foregroundColor(.red).font(.footnote)
                        }
                        if missingRepoList {
                            Text("Missing permission(s) required for discovering your private repositories").foregroundColor(.red).font(.footnote)
                        }
                        if missingRepoContents || missingRepoList {
                            Text("You can fix this by going back to \(hostName) and creating a new access token with the permissions outlined above").font(.footnote)
                        }
                    }
                }
            } else {
                forceAddWithoutTestingStep(i: startI + 4)
            }
        }
    }
    
    @ViewBuilder
    func contentPermItem(_ item: String) -> some View {
        // nil = has not been validated, false = invalid, true = valid
        let isValidated: Bool? = testingResult == nil ? nil : verifiedPerms.contains(where: {$0.raw == item})
        HStack(spacing: 0) {
            Image(systemName: isValidated == nil ? "circle.fill" : (isValidated == true ? "checkmark.circle" : "x.circle"))
                .scaleEffect(isValidated == nil ? 0.36 : 0.8)
                .padding(.trailing, isValidated == nil ? 0 : 5)
            Text(item)
            if isValidated == false {
                Spacer()
                Text("access token missing permission \"\(item)\"").font(.footnote)
            }
        }.padding(.leading, 15)
        .padding(.bottom, 5)
        .foregroundColor(isValidated == nil ? nil : (isValidated == true ? .green : .red))
    }
    
    var body: some View {
        List {
            if isPassword {
                Section(header: HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                    Text("Warning")
                    Spacer()
                }) {
                    Text(badPracticeMessage)
                }
            }
            instructionSection(footer: "Note: This will grant access read\(isPassword ? "/write" : " or read/write") permissions to all\(isPassword ? "" : " or some") of your repository contents on \(hostName)") {
                if isPassword {
                    listPart2(startI: 0)
                } else {
                    if let setupAccessTokenLink = setupAccessTokenLink, let url = URL(string: setupAccessTokenLink) {
                        instruction(i: 1, text: "Goto \(hostName)", link: url)
                    } else {
                        instruction(i: 1, text: "Goto \(hostName) and navigate to the page where you can add an access token")
                    }
                    instruction(i: 2, text: "Login if needed")
                    if let contentPerms = preset.addAccessTokenPagePermissionForRepoContents,
                       let listPerms = preset.addAccessTokenPagePermissionForRepoList {
                        let extraPermsNeededForList = listPerms.filter({
                            !contentPerms.contains($0)
                        })
                        VStack(alignment: .leading) {
                            instruction(i: 3, text: "Create a new access token with the following permission\(contentPerms.count == 1 ? "" : "s"):")
                                .padding(.bottom, 5)
                            ForEach(0..<contentPerms.count) { i in
                                let contentPerm = contentPerms[i]
                                contentPermItem(contentPerm)
                            }
                        }
                        if extraPermsNeededForList.count > 0 {
                            VStack(alignment: .leading) {
                                instruction(i: 4, text: "To also grant access to which repositories exist so that we can automatically find your repositories to clone, add the following permission\(extraPermsNeededForList.count == 1 ? "" : "s"):")
                                    .padding(.bottom, 5)
                                ForEach(0..<extraPermsNeededForList.count) { i in
                                    let extraPermNeededForList = extraPermsNeededForList[i]
                                    contentPermItem(extraPermNeededForList)
                                }
                            }
                            listPart2(startI: 4)
                        } else {
                            listPart2(startI: 3)
                        }
                    } else {
                        instruction(i: 3, text: "Create a new access token with the required permissions")
                        listPart2(startI: 3)
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Add \(isPassword ? "Password Authentication" : "Access Token") for \(hostName)")
    }
}
