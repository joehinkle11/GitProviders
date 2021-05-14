//
//  GitCloneModalView.swift
//  
//
//  Created by Joseph Hinkle on 5/14/21.
//

import SwiftUI

struct GitCloneModalView: View {
    
    let closeModal: () -> Void
    
    @State var name: String = ""
    @State var repoURL: String = ""
    @State var useSSH: Bool = false
    
    @Binding var cloningStatus: CloningStatus?
    var isCloning: Bool {
        cloningStatus != nil
    }
    
    var cleanedNickname: String {
        name
    }
    
    var dataIsInvalid: Bool {
        cleanedNickname == "" || repoURL == ""
    }
    
    var repoIsHTTP: Bool {
        true
    }
    
    var body: some View {
        NavigationView {
            mainBody
                .blur(radius: isCloning ? 2.0 : 0)
                .overlay(Group {
                    if isCloning {
                        ProgressView("Cloning...")
                    }
                })
                .navigationBarTitle("Git Clone", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel", action: closeModal),
                    trailing: Button("Clone") {
//                        isCloning = true
                    }.disabled(dataIsInvalid).opacity(dataIsInvalid ? 0.5 : 1)
                ).disabled(isCloning)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    var mainBody: some View {
        List {
            Section {
                HStack {
                    Text("Nickname:")
                    TextField("My Project", text: $name)
                    Spacer()
                    Text(cleanedNickname).font(.footnote).foregroundColor(.gray)
                }
                VStack {
                    HStack {
                        Text("URL:")
                        TextField(useSSH ? "git@example.com:user/example.git" : "https://example.com/user/example.git", text: $repoURL)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        PasteButton(into: $repoURL).buttonStyle(BorderlessButtonStyle())
                    }
                }
                Toggle(isOn: $useSSH, label: {
                    Text("Use SSH? ")
                    Text(useSSH ? "(yes)" : "(no)").font(.footnote).foregroundColor(.gray)
                })
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
