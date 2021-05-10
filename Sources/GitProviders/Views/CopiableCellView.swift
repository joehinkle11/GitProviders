//
//  CopiableCellView.swift
//  
//
//  Created by Joseph Hinkle on 5/6/21.
//

import SwiftUI

struct CopiableCellView: View {
    let copiableText: String
    
    @State private var copied = false
    
    var body: some View {
        Text(copiableText)
        Button {
            UIPasteboard.general.string = copiableText
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc.fill")
                .font(nil)
                .frame(width: 100)
        }
    }
}
