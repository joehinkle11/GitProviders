//
//  PasteButton.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI

struct PasteButton: View {
    
    @Binding var into: String
    @State private var pasted = false
    
    var body: some View {
        Button(action: {
            if let value = UIPasteboard.general.string {
                into = value
            }
            pasted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                pasted = false
            }
        }, label: {
            Label("Paste\(pasted ? "d": "")", systemImage: pasted ? "checkmark" : "doc.on.clipboard.fill")
        })
    }
}
