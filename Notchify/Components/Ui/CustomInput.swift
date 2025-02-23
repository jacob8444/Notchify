//
//  CustomInput.swift
//  Notchify
//
//  Created by Jacob Büchler on 14.02.25.
//

import SwiftUI

struct CustomInput: View {
    let placeholder: String
    @Binding var text: String
    var isDisabled: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain) // Remove default styling
            .focused($isFocused)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            // Override system font
            .font(.system(size: 14))
            // Remove default focus ring
            .focusable(true)
            // Override text colors
            .foregroundColor(isDisabled ? .gray.opacity(0.5) : .white)
            .opacity(isDisabled ? 0.5 : 1)
            // Disable system blue focus highlight
            .buttonStyle(PlainButtonStyle())
            // Remove system background
            .environment(\.colorScheme, .light)
            .disabled(isDisabled)
    }
}

// Preview provider for SwiftUI canvas
#Preview {
    VStack(spacing: 20) {
        CustomInput(
            placeholder: "Enter text",
            text: .constant("")
        )
        
        CustomInput(
            placeholder: "Disabled input",
            text: .constant(""),
            isDisabled: true
        )
    }
    .padding()
    .frame(width: 300)
}
