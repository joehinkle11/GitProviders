//
//  ReadHeaderList.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

import Foundation

extension NSDictionary {
    func readStringList(from key: String) -> [String] {
        if let listString = self[key] as? String {
            return listString.components(separatedBy: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return []
    }
}
