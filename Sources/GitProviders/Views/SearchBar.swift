//
//  SearchBar.swift
//  appmaker
//
//  Created by Joseph Hinkle on 3/6/21.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    let placeholder: String
    var enablesReturnKeyAutomatically = true
    var becomeFirstResponder = false
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.accessibilityNavigationStyle = .separate
        searchBar.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        if becomeFirstResponder {
            searchBar.becomeFirstResponder()
        }
        searchBar.placeholder = placeholder
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
        uiView.placeholder = placeholder
        uiView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    }
}
