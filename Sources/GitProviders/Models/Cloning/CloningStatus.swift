//
//  CloningStatus.swift
//  
//
//  Created by Joseph Hinkle on 5/14/21.
//

import Combine

final class CloningStatus: ObservableObject {
    @Published var status: (
        success: Bool?,
        completedObjects: Int?,
        totalObjects: Int?,
        message: String?
    )?
}
