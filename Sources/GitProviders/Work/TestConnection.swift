//
//  TestConnection.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import GitClient

func testConnection(with cred: Cred, domain: String, onSuccess success: @escaping () -> Void, onFail fail: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async {
        if let authItem = cred as? SSHKey,
           let privateKey = authItem.privateKeyAsPEMString {
            let result = testSSH(privateKey: privateKey, forDomain: domain)
            DispatchQueue.main.async {
                if result {
                    success()
                } else {
                    fail()
                }
            }
        } else {
            DispatchQueue.main.async {
                fail()
            }
        }
    }
}
