//
//  NotesView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI

struct NotesView: View {
    let appDelegate: AppDelegate?
    @State private var noteText: String = UserDefaults.standard.string(forKey: "quickNote") ?? ""
    
    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $noteText)
                .font(.system(size: 12))
                .frame(maxWidth: 350, maxHeight: 100)
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .onChange(of: noteText) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "quickNote")
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

