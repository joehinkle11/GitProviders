//
//  AccessImageView.swift
//  
//
//  Created by Joseph Hinkle on 5/5/21.
//

import SwiftUI

struct AccessImageView: View {
    let hasAccess: Bool
    let sfSymbolBase: String
    
    var body: some View {
        Image(systemName: sfSymbolBase + "." + (hasAccess ? "checkmark" : "xmark"))
            .foregroundColor(hasAccess ? .green : .gray)
    }
}
