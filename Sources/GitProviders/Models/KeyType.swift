//
//  KeyType.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

enum KeyType: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case RSA = "RSA"
}
