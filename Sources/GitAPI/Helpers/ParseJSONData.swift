//
//  ParseJSONData.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

import Foundation

extension Data {
    func parse<T: Decodable>(as: T.Type) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
            return nil
        }
    }
}
