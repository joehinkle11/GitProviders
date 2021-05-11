//
//  CustomProviderDetails.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation

struct CustomProviderDetails {
    let customName: String
    let domain: String
}

extension CustomProviderDetails: Storeable {
    func encode() -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode(customName, forKey: "customName")
        archiver.encode(domain, forKey: "domain")
        archiver.finishEncoding()
        return archiver.encodedData
    }

    init?(data: Data) {
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            return nil
        }
        defer {
            unarchiver.finishDecoding()
        }
        guard let customName = unarchiver.decodeObject(forKey: "customName") as? String else { return nil }
        guard let domain = unarchiver.decodeObject(forKey: "domain") as? String else { return nil }
        self.customName = customName
        self.domain = domain
    }
}
