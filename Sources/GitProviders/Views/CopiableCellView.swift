//
//  CopiableCellView.swift
//  
//
//  Created by Joseph Hinkle on 5/6/21.
//

import SwiftUI

struct CopiableCellView: View {
    let copiableTest: String
    
    @State private var copied = false
    
    var body: some View {
        Text(copiableTest)
        Button {
            UIPasteboard.general.string = copiableTest
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc.fill")
        }
    }
}
