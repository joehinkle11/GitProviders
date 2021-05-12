//
//  PermScope.swift
//  
//
//  Created by Joseph Hinkle on 5/12/21.
//

enum PermScope: InternalModel {
    case repoContents // can see contents of a repos
    case repoList // can see existence of repos user has access to
}
