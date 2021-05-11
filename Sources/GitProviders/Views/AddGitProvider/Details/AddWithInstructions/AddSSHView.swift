//
//  AddSSHView.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import SwiftUI
import GitClient

struct AddSSHView: View, InstructionView {
    typealias T = SSHKey
    
    @ObservedObject var gitProviderStore: GitProviderStore
    let preset: GitProviderPresets
    let customDetails: CustomProviderDetails?
    
    @State var isTesting = false
    @State var testingResult: Bool? = nil
    
    func testConnection(using authItem: SSHKey) {
        if let privateKey = authItem.privateKeyAsPEMString, let domain = preset.domain ?? customDetails?.domain {
            isTesting = true
            DispatchQueue.global(qos: .background).async {
                let result = testSSH(privateKey: privateKey, forDomain: domain)
                if result {
                    // success, therefore mark this git provider as working with ssh
                    gitProvider?.add(sshKey: authItem)
                } else {
                    // failed, therefore mark this git provider as NOT working with ssh
                    gitProvider?.remove(sshKey: authItem)
                }
                DispatchQueue.main.async {
                    testingResult = result
                    isTesting = false
                }
            }
        }
    }
    
    func forceAdd(authItem: SSHKey) {
        gitProvider?.add(sshKey: authItem)
    }
    
    var setupSSHLink: String? {
        if let addSSHKeyLink = preset.addSSHKeyLink {
            return addSSHKeyLink
        } else if let domain = customDetails?.domain {
            return "https://\(domain)"
        }
        return nil
    }
    
    var body: some View {
        List {
            CreateSSHIfNeededView(gitProviderStore: gitProviderStore) { sshKey in
                instructionSection(footer: "Note: This will grant access read/write permissions to your repository contents") {
                    instruction(i: 1, text: "Copy your public key", copyableText: sshKey.publicKeyAsSSHFormat)
                    if let addSSHKeyLink = setupSSHLink, let url = URL(string: addSSHKeyLink) {
                        instruction(i: 2, text: "Goto \(hostName)", link: url)
                    } else {
                        instruction(i: 2, text: "Goto \(hostName)")
                    }
                    instruction(i: 3, text: "Login if needed")
                    if preset.addSSHKeyLink == nil {
                        // we should the user a link to the provider's homepage
                        instruction(i: 4, text: "Find where you can add SSH keys on \(hostName)'s site. Follow their instructions and paste your public key and save", link: nil, copyableText: nil)
                    } else {
                        // we should the user the exact link to where they add their ssh key
                        instruction(i: 4, text: "Paste your public key on \(hostName)'s page and save", link: nil, copyableText: nil)
                    }
                    testingStep(i: 5, with: sshKey, successMessage: "SSH is successfully setup for \(hostName)!")
                }
            }
        }.listStyle(InsetGroupedListStyle())
        .navigationTitle("Add SSH for \(hostName)")
    }
}
