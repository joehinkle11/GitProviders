//
//  TestSSH.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import Foundation
import SwiftGit2

/// returns: success
public func testSSH(privateKey: String, forDomain domain: String) -> Bool {
    let urlToTest = URL(string: "git@\(domain):/.git")! // todo: change to dedicated url
    let cred = Credentials.sshMemory(username: "git", privateKey: privateKey, passphrase: "")
    return test(urlToTest: urlToTest, cred: cred)
}

/// returns: success
public func testUsernamePassword(username: String, password: String, forDomain domain: String) -> Bool {
    let urlToTest = URL(string: "https://\(domain)/\(username)/.git")! // todo: change to dedicated url
    let cred = Credentials.plaintext(username: username, password: password)
    return test(urlToTest: urlToTest, cred: cred)
}

/// returns: success
func test(urlToTest: URL, cred: Credentials) -> Bool {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("_testclone")
    try? FileManager.default.removeItem(at: temporaryDirectoryURL)
    let result = Repository.clone(from: urlToTest, to: temporaryDirectoryURL, credentials: cred)
    switch result {
    case .success(_):
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
