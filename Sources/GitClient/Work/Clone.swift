//
//  Clone.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import Foundation
import SwiftGit2

public func clone(
    with creds: Credentials,
    from remoteURL: URL,
    named nickName: String,
    _ callback: @escaping (
    _ success: Bool?,
    _ completedObjects: Int?,
    _ totalObjects: Int?,
    _ message: String?
) -> ()) {
    let localUrl = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        .appendingPathComponent("Documents")
        .appendingPathComponent(nickName)
    let result = Repository.clone(from: remoteURL, to: localUrl, credentials: creds, checkoutProgress: { str, n1, n2 in
        callback(nil, n1, n2, nil)
    })
    switch result {
    case .success:
        callback(true, nil, nil, nil)
    case .failure(let err):
        if err.localizedDescription.lowercased().contains("credentials") {
            // ask for credentials
        }
        callback(false, nil, nil, err.localizedDescription)
    }
}
