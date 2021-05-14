//
//  CloneSource.swift
//  
//
//  Created by Joseph Hinkle on 5/13/21.
//

struct CloneSource: Identifiable {
    var id: Int {
        provider?.id.uuidString.hash ?? name.hash
    }
    let name: String
    let provider: GitProvider?
}
