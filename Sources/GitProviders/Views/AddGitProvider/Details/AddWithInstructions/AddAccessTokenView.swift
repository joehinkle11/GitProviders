//
//  AddAccessTokenView.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI
import GitClient

struct AddAccessTokenView: View, InstructionView {
    typealias T = (username: String, passOrAccessToken: String)
    
    @ObservedObject var gitProviderStore: GitProviderStore
    let preset: GitProviderPresets
    let customDetails: CustomProviderDetails?
    var isPassword: Bool = false // if we are actually setuping up a password, and not an access token
    
    @State var isTesting = false
    @State var testingResult: Bool? = nil
    
    @State private var username = ""
    @State private var passwordOrAccessToken = ""
    
    func testConnection(using authItem: (username: String, passOrAccessToken: String)) {
        if let domain = preset.domain ?? customDetails?.domain {
            let domain = "https://github.com/joehinkle11/LiveAppWebServer"
            isTesting = true
            DispatchQueue.global(qos: .background).async {
//                let result = testUsernamePassword(username: authItem.username, password: authItem.passOrAccessToken, forDomain: domain)
//                if result {
//                    // success, therefore mark this git provider as working with ssh
////                    gitProvider?.add(sshKey: authItem)
//                } else {
//                    // failed, therefore mark this git provider as NOT working with ssh
////                    gitProvider?.remove(sshKey: authItem)
//                }
//                DispatchQueue.main.async {
//                    testingResult = result
//                    isTesting = false
//                }
            }
        }
    }
    
    func forceAdd(authItem: (username: String, passOrAccessToken: String)) {
//        gitProvider?.add(sshKey: authItem)
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
        testingStep(i: startI + 3, with: (username: username, passOrAccessToken: passwordOrAccessToken), successMessage: "\(isPassword ? "Password authentication" : "Access token") is successfully setup for \(hostName)!")
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
                                HStack(spacing: 0) {
                                    Image(systemName: "circle.fill").scaleEffect(0.36)
                                    Text(contentPerm)
                                }.padding(.leading, 15).padding(.bottom, 5)
                            }
                        }
                        if extraPermsNeededForList.count > 0 {
                            VStack(alignment: .leading) {
                                instruction(i: 4, text: "To also grant access to which repositories exist so that we can automatically find your repositories to clone, add the following permission\(extraPermsNeededForList.count == 1 ? "" : "s"):")
                                    .padding(.bottom, 5)
                                ForEach(0..<extraPermsNeededForList.count) { i in
                                    let extraPermNeededForList = extraPermsNeededForList[i]
                                    HStack(spacing: 0) {
                                        Image(systemName: "circle.fill").scaleEffect(0.36)
                                        Text(extraPermNeededForList)
                                    }.padding(.leading, 15).padding(.bottom, 5)
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
