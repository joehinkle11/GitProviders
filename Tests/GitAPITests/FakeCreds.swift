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
        fatalError()    
    }
    
    func get(_ item: DataItem) -> Data {
        fatalError()    
    }
    private init() {}
    static let shared = FakeCreds()
}

extension FakeCreds {
    enum StringItem: String {
        case gitHubUsername
        case bitBucketUsername
        case gitLabUsername
    }
    enum DataItem: String {
        case sshPublicKey
        case sshPrivateKey
    }
}
