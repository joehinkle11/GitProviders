//
//  AccessMethodDetailCell.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI
import GitAPI

struct AccessMethodDetailCell: View, Identifiable {
    var id: Int { accessMethodData.hash }
    let gitProviderStore: GitProviderStore
    let accessMethodData: RepositoryAccessMethodData
    let accessMethod: RepositoryAccessMethods
    let gitProvider: GitProvider
    
    @State private var tapped = false
    @State private var isTesting = false
    @State var testingResult: Bool? = nil
    @State var hasFailedTest = false
    
    var onDeviceCred: Cred? {
        accessMethod.getOnDeviceCred(gitProviderStore: gitProviderStore, accessMethodData: accessMethodData)
    }
    
    var validOnThisDevice: Bool {
        onDeviceCred != nil
    }
    
    func testConnection(sshCred: SSHKey) {
        isTesting = true
        GitProviders.testConnection(with: sshCred, domain: gitProvider.preset.domain ?? gitProvider.customDetails?.domain ?? "") {
            testingResult = true
            isTesting = false
            hasFailedTest = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                testingResult = nil
            }
        } onFail: {
            testingResult = false
            isTesting = false
            hasFailedTest = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                testingResult = nil
            }
        }
    }
    
    func testConnection(tokenCred: AccessTokenOrPassword, gitClient: GitAPI) {
        isTesting = true
        DispatchQueue.global(qos: .background).async {
            gitClient.userInfo = .init(username: tokenCred.username, authToken: tokenCred.accessTokenOrPassword)
            gitClient.fetchGrantedScopes { perms, _ in
                DispatchQueue.main.async {
                    if perms?.count ?? 0 > 0 {
                        testingResult = true
                        isTesting = false
                        hasFailedTest = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            testingResult = nil
                        }
                    } else {
                        testingResult = false
                        isTesting = false
                        hasFailedTest = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            testingResult = nil
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var message: some View {
        if let message = accessMethod.isValidMessage(isValid: validOnThisDevice) {
            HStack {
                Spacer()
                Text(message)
                    .font(.footnote).foregroundColor(validOnThisDevice ? .green : .red).opacity(0.8)
            }
        }
    }
    
    @ViewBuilder
    var testButton: some View {
        HStack {
            if isTesting {
                HStack {
                    ProgressView().padding(.trailing, 2)
                    Text("Testing...this can take up to 10 seconds or more")
                }.padding(.leading)
            } else {
                if let onDeviceCred = onDeviceCred {
                    if let sshCred = onDeviceCred as? SSHKey {
                        Divider()
                        Button {
                            isTesting = true
                            testConnection(sshCred: sshCred)
                        } label: {
                            Label("Test", systemImage: "wifi")
                                .font(nil)
                                .frame(width: 100)
                        }
                    } else if let tokenCred = onDeviceCred as? AccessTokenOrPassword, let gitAPI = gitProvider.preset.api {
                        Divider()
                        Button {
                            isTesting = true
                            testConnection(tokenCred: tokenCred, gitClient: gitAPI)
                        } label: {
                            Label("Test", systemImage: "wifi")
                                .font(nil)
                                .frame(width: 100)
                        }
                    }
                    if let testingResult = testingResult {
                        if testingResult {
                            Text("Success").foregroundColor(.green)
                        } else {
                            Text("Failed").foregroundColor(.red)
                        }
                    }
                    if hasFailedTest && onDeviceCred is SSHKey {
                        Divider().padding(.trailing)
                        Label("Fix", systemImage: "hammer")
                            .background(NavigationLink("", destination: AddSSHView(gitProviderStore: gitProviderStore, preset: gitProvider.preset, customDetails: gitProvider.customDetails)))
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
                message
            }
        }
    }
    
    var body: some View {
        Group {
            if let data = accessMethodData as? SSHAccessMethodData {
                let publicKey = (try? data.publicKeyData.publicPEMKeyToSSHFormat()) ?? ""
                if tapped {
                    CopiableCellView(copiableText: publicKey, addRightOfButton: AnyView(testButton)).buttonStyle(BorderlessButtonStyle())
                } else {
                    Button(action: {
                        tapped = true
                    }, label: {
                        VStack(spacing: 8) {
                            Text(publicKey).font(.footnote).foregroundColor(.gray).lineLimit(1)
                            message
                        }
                    }).buttonStyle(PlainButtonStyle())
                }
            } else if let data = accessMethodData as? AccessTokenAccessMethodData {
                Button(action: {
                    tapped = true
                }, label: {
                    if tapped {
                    } else {
                        VStack(spacing: 8) {
                            if data.isPassword {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                                    Text("Warning")
                                    Spacer()
                                    Text("You've stored your actual account password. This is bad practice and you should consider deleting this and changing to using a real access token.")
                                }
                            }
                            Text("○○○○○○○○○").font(.footnote).foregroundColor(.gray)
                            message
                        }
                    }
                }).buttonStyle(PlainButtonStyle())
            }
        }.animation(.easeOut)
    }
}
