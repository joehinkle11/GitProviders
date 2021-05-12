//
//  FakeCreds.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

// reads a git ignored folder where you can put credentials for testing

import Foundation

final class FakeCreds {
    func get(_ item: StringItem) -> String {
        try! String(contentsOf: Bundle.module.resourceURL!.appendingPathComponent("FakeCreds").appendingPathComponent(item.rawValue + ".txt")).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func get(_ item: DataItem) -> Data {
        fatalError()    
    }
    private init() {}
    static let shared = FakeCreds()
}

extension FakeCreds {
    enum StringItem: String {
        case GitHubUsername
        case BitBucketUsername
        case GitLabUsername
    }
    enum DataItem: String {
        case SSHPublicKey
        case SSHPrivateKey
    }
}
