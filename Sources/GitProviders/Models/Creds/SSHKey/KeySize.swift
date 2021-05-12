//
//  KeySize.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

enum KeySize: Int, CaseIterable, Identifiable {
    var id: Int { self.rawValue }
    case _2048 = 2048
    case _4096 = 4096
}
