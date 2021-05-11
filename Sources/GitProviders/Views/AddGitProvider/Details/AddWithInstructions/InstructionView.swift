//
//  InstructionView.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI

protocol InstructionView: View {
    associatedtype T
    func testConnection(using authItem: T)
    var isTesting: Bool { get }
}

extension InstructionView {
    func instructionBase(i: Int, text: String) -> some View {
        HStack {
            Image(systemName: "\(i).circle")
            Text(text)
        }
    }
    
    @ViewBuilder
    func instruction(i: Int, text: String, link url: URL? = nil, copyableText: String? = nil, onClick: (() -> Void)? = nil) -> some View {
        if let url = url {
            Link(destination: url) {
                HStack {
                    instructionBase(i: i, text: text)
                    Spacer()
                    Text(url.absoluteString).font(.footnote).foregroundColor(.gray)
                }
            }
        } else if let onClick = onClick {
            Button(action: onClick) {
                instructionBase(i: i, text: text)
            }

        } else {
            instructionBase(i: i, text: text)
        }
        if let copyableText = copyableText {
            HStack {
                CopiableCellView(copiableText: copyableText).font(.footnote)
            }
        }
    }
    
    func instructionSection<Content: View>(footer: String, @ViewBuilder content: () -> Content) -> some View {
        Section(header: HStack {
            Image(systemName: "list.number")
            Text("Setup Instructions")
            Spacer()
        }, footer: Text(footer), content: content)
    }
    
    @ViewBuilder
    func testingStep(i: Int, with authItem: T) -> some View {
        if isTesting {
            HStack {
                ProgressView().padding(.trailing, 2)
                Text("Testing...this can take up to 10 seconds or more")
            }
        } else {
            instruction(i: i, text: "Test connection") {
                testConnection(using: authItem)
            }
        }
    }
}
