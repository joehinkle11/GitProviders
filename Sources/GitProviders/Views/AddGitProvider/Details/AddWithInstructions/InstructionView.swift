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
    var testingResult: Bool? { get }
    var preset: GitProviderPresets { get }
    var customDetails: CustomProviderDetails? { get }
    var gitProviderStore: GitProviderStore { get }
    func forceAdd(authItem: T)
}

extension InstructionView {
    
    var gitProvider: GitProvider? {
        gitProviderStore.gitProviders.first { provider in
            switch preset {
            case .Custom:
                return provider.customDetails?.customName == customDetails?.customName
            default:
                return provider.baseKeyName == preset.rawValue
            }
        }
    }
    
    var hostName: String {
        if preset == .Custom {
            return customDetails?.customName ?? "Custom"
        } else {
            return preset.rawValue
        }
    }
    
    func instructionBase(i: Int, text: String) -> some View {
        HStack {
            Image(systemName: "\(i).circle")
            Text(text)
        }
    }
    
    @ViewBuilder
    func instruction(
        i: Int,
        text: String,
        link url: URL? = nil,
        copyableText: String? = nil,
        onClick: (() -> Void)? = nil,
        shouldPasteButton: Bool = false,
        input: (title: String, binding: Binding<String>)? = nil,
        secureInput: (title: String, binding: Binding<String>)? = nil
    ) -> some View {
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
        if let input = input {
            HStack {
                TextField(input.title, text: input.binding).keyboardType(.asciiCapable).disableAutocorrection(true)
                PasteButton(into: input.binding)
            }
        }
        if let secureInput = secureInput {
            HStack {
                SecureField(secureInput.title, text: secureInput.binding)
                PasteButton(into: secureInput.binding)
            }
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
    func testingStep(i: Int, with authItem: T, successMessage: String) -> some View {
        if isTesting {
            HStack {
                ProgressView().padding(.trailing, 2)
                Text("Testing...this can take up to 10 seconds or more")
            }
        } else {
            instruction(i: i, text: "Test connection") {
                DispatchQueue.global(qos: .background).async {
                    testConnection(using: authItem)
                }
            }
        }
        if let testingResult = testingResult {
            if testingResult {
                Text("Success").foregroundColor(.green).alert(isPresented: .constant(true), content: {
                    Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("Okay"), action: {
                        gitProviderStore.moveBackToFirstPage()
                    }))
                })
            } else {
                HStack {
                    Text("Failed").foregroundColor(.red)
                    Spacer()
                    Button("Force Add") {
                        forceAdd(authItem: authItem)
                        gitProviderStore.moveBackToFirstPage()
                    }.foregroundColor(.orange).font(.footnote).buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }
}
