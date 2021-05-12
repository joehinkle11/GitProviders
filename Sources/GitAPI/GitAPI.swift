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
    func get(_ path: String) -> some Publisher {
        let url = baseUrl.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        do {
//            let parameters = makeClientVersionJSON()
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//        } catch {
//            return
//        }
        return URLSession.shared.dataTaskPublisher(for: request).map { output -> HTTPURLResponse? in
            if let response = output.response as? HTTPURLResponse {
                return response
            }
            return nil
        }.replaceError(with: nil).subscribe(on: gitAPIProcessingQueue)
    }
}


