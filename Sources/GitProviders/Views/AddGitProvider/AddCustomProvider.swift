//
//  AddCustomProvider.swift
//  
//
//  Created by Joseph Hinkle on 5/11/21.
//

import SwiftUI

struct AddCustomProvider: View {
    @ObservedObject var gitProviderStore: GitProviderStore
    
    @Binding var showThisModal: Bool
    
    @State private var customName = ""
    @State private var customDomain = ""
    
    var missingDetails: Bool {
        cleanedCustomName == "" || cleanedCustomDomain == "" || !cleanedCustomDomain.contains(".")
    }
    
    var cleanedCustomName: String {
        customName.onlyAlphaNumeric
    }
    
    var cleanedCustomDomain: String {
        customDomain
            .replacingOccurrences(of: "http://www.", with: "")
            .replacingOccurrences(of: "https://www.", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .onlyWeb.lowercased()
    }
    
    var mainBody: some View {
        List {
            Section(header: Text("Common Providers")) {
                HStack {
                    Text("Name")
                    TextField("Example", text: $customName).keyboardType(/*@START_MENU_TOKEN@*/.default/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Text(cleanedCustomName).font(.footnote).foregroundColor(.gray)
                }
                HStack {
                    Text("Domain")
                    TextField("example.com", text: $customDomain)
                    Spacer()
                    Text(cleanedCustomDomain).font(.footnote).foregroundColor(.gray)
                }
                Button("Create") {
                    showThisModal = false
                    gitProviderStore.addCustom(named: cleanedCustomName, withDomain: cleanedCustomDomain)
                    gitProviderStore.refresh()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        gitProviderStore.moveBackToFirstPage()
                    }
                }.disabled(missingDetails).opacity(missingDetails ? 0.5 : 1)
            }
        }.listStyle(InsetGroupedListStyle())
    }
    
    var body: some View {
        mainBody.navigationTitle("Add Custom Git Provider")
    }
}
extension String {
    var onlyAlphaNumeric: String {
        let pattern = "[^A-Za-z0-9]+"
        return self.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
    }
    var onlyWeb: String {
        let pattern = "[^A-Za-z0-9:._-/]+"
        return self.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
    }
}
