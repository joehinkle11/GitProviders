//
//  RepoModel.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

import Foundation

public struct RepoModel: InternalModel, Identifiable, Hashable {
    public var id: Int { hashValue }
    public let name: String
    public let httpsURL: String
    public let sshURL: String
    public let isPrivate: Bool
    public let size: Int
    public let updatedAt: Date
}
