//
//  Protocols.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

// clean internal model
protocol InternalModel {}

// providers
protocol GitHubModel: Decodable {}
protocol BitBucketModel: Decodable {}
protocol GitLabModel: Decodable {}
