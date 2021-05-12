//
//  AccessMethodDetailCell.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI
import GitClient

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
    
    func testConnection(cred: Cred) {
        isTesting = true
        GitProviders.testConnection(with: cred, domain: gitProvider.preset.domain ?? gitProvider.customDetails?.domain ?? "") {
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
        if let onDeviceCred = onDeviceCred {
            if isTesting {
                HStack {
                    ProgressView().padding(.trailing, 2)
                    Text("Testing...this can take up to 10 seconds or more")
                }.padding(.leading)
            } else {
                Divider()
                Button {
                    isTesting = true
                    testConnection(cred: onDeviceCred)
                } label: {
                    Label("Test", systemImage: "wifi")
                        .font(nil)
                        .frame(width: 100)
                }
                if let testingResult = testingResult {
                    if testingResult {
                        Text("Success").foregroundColor(.green)
                    } else {
                        Text("Failed").foregroundColor(.red)
                    }
                }
            }
            if hasFailedTest && onDeviceCred is SSHKey {
                Divider().padding(.trailing)
                Label("Fix", systemImage: "hammer")
                    .background(NavigationLink("", destination: AddSSHView(gitProviderStore: gitProviderStore, preset: gitProvider.preset, customDetails: gitProvider.customDetails)))
                    .foregroundColor(.blue)
            }
        }
    }
    
    var body: some View {
        Group {
            if let data = accessMethodData as? SSHAccessMethodData {
                let publicKey = (try? data.publicKeyData.publicPEMKeyToSSHFormat()) ?? ""
                if tapped {
                    CopiableCellView(copiableText: publicKey, addRightOfButton: AnyView(HStack {
                        testButton
                        Spacer()
                        message
                    })).buttonStyle(BorderlessButtonStyle())
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
            }
        }.animation(.easeOut)
    }
}
