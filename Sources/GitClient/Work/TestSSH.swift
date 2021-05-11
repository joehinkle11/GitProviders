//
//  TestSSH.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import Foundation
import SwiftGit2

// returns: success
public func testSSH(privateKey: String, forDomain domain: String) -> Bool {
    let urlToTest = URL(string: "git@\(domain):/.git")! // todo: change to dedicated url
    let cred = Credentials.sshMemory(username: "git", privateKey: privateKey, passphrase: "")
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("testsshclone")
    try? FileManager.default.removeItem(at: temporaryDirectoryURL)
    let result = Repository.clone(from: urlToTest, to: temporaryDirectoryURL, credentials: cred)
    switch result {
    case .success(let repo):
        try? FileManager.default.removeItem(at: temporaryDirectoryURL)
        return true
    case .failure(let error):
        try? FileManager.default.removeItem(at: temporaryDirectoryURL)
        if error.localizedDescription.lowercased().contains("failed to authenticate ssh session") {
            return false
        } else {
            return true
        }
    }
}
