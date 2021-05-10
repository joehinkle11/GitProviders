//
//  FormatPEMKeys.swift
//  
//
//  Created by Joseph Hinkle on 5/10/21.
//

import Foundation

extension Data {
    func printAsPEMPublicKey() -> String {
        return appendPrefixSuffixTo(self.base64EncodedString(options: .lineLength64Characters), prefix: "-----BEGIN RSA PUBLIC KEY-----\n", suffix: "\n-----END RSA PUBLIC KEY-----")
    }
    func printAsPEMPrivateKey() -> String {
        return appendPrefixSuffixTo(self.base64EncodedString(options: .lineLength64Characters), prefix: "-----BEGIN RSA PRIVATE KEY-----\n", suffix: "\n-----END RSA PRIVATE KEY-----")
    }
}


// keyData is in DER format!!
func format(keyData: Data, withPemType pemType: String) -> String {
    
    func split(_ str: String, byChunksOfLength length: Int) -> [String] {
        return stride(from: 0, to: str.count, by: length).map { index -> String in
            let startIndex = str.index(str.startIndex, offsetBy: index)
            let endIndex = str.index(startIndex, offsetBy: length, limitedBy: str.endIndex) ?? str.endIndex
            return String(str[startIndex..<endIndex])
        }
    }
    
    // Line length is typically 64 characters, except the last line.
    // See https://tools.ietf.org/html/rfc7468#page-6 (64base64char)
    // See https://tools.ietf.org/html/rfc7468#page-11 (example)
    let chunks = split(keyData.base64EncodedString(), byChunksOfLength: 64)
    
    let pem = [
        "-----BEGIN \(pemType)-----",
        chunks.joined(separator: "\n"),
        "-----END \(pemType)-----"
    ]
    
    return pem.joined(separator: "\n")
}

func appendPrefixSuffixTo(_ string: String, prefix: String, suffix: String) -> String {
    return "\(prefix)\(string)\(suffix)"
}


