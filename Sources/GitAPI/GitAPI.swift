//
//  GitAPI.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import Foundation
import Combine


fileprivate let gitAPIProcessingQueue = DispatchQueue(label: "git-api-pq")
fileprivate var anyCancellables: [AnyCancellable] = []

protocol GitAPI {
    var baseUrl: URL { get }
    static var shared: Self { get }
    
    func fetchGrantedScopes(callback: @escaping (_ grantedScopes: [String]?, _ error: Error?) -> Void)
}

extension GitAPI {
    func get(_ path: String, callback: @escaping (NetworkResponse?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        do {
//            let parameters = makeClientVersionJSON()
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//        } catch {
//            return
//        }
        URLSession.shared.dataTaskPublisher(for: request).map { output -> HTTPURLResponse? in
            return output.response as? HTTPURLResponse
        }.replaceError(with: nil).subscribe(on: gitAPIProcessingQueue).sink { output in
//            if let output = output {
//                callback(NetworkResponse(headers: output.allHeaderFields, body: output.body), nil)
//            } else {
//                callback(nil, NSError())
//            }
        }
    }
}


