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

struct UserInfo {
    let username: String
    let authToken: String
}

protocol GitAPI: AnyObject {
    var baseUrl: URL { get }
    var userInfo: UserInfo? { get set }
    static var shared: Self { get }
    
    func fetchGrantedScopes(callback: @escaping (_ grantedScopes: [PermScope]?, _ error: Error?) -> Void)
    func fetchUserRepos(callback: @escaping (_ repos: [RepoModel]?, _ error: Error?) -> Void)
}

extension GitAPI {
    // adapted from https://stackoverflow.com/a/27724627/3902590 and https://github.com/App-Maker-Software/LiveApp/blob/main/Sources/liveapp/Network/Network.swift and other places
    func get(_ path: String, parameters: [String: String] = [:],callback: @escaping (NetworkResponse?, Error?) -> Void) {
        var components = URLComponents(string: baseUrl.appendingPathComponent(path).absoluteString)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        if let authToken = userInfo?.authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
//        do {
//            let parameters = makeClientVersionJSON()
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//        } catch {
//            return
//        }
        URLSession.shared.dataTaskPublisher(for: request).map { output -> (NetworkResponse?, Error?) in
            if let httpResponse = output.response as? HTTPURLResponse {
                let networkResponse = NetworkResponse(
                    headers: httpResponse.allHeaderFields as NSDictionary,
                    body: output.data
                )
                return (networkResponse, nil)
            }
            return (nil, NSError())
        }.replaceError(with: (nil, NSError()))
        .subscribe(on: gitAPIProcessingQueue)
        .sink(receiveValue: callback)
        .store(in: &anyCancellables)
    }
}


