//
//  Cred.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

/// A protocol representing some git provider credential. All implementations of this protocol should be safe in that using and passing around the object does not put any sensitive info into memory. Any sensitive info should be exposed through explicit use of a method.
protocol Cred {}
