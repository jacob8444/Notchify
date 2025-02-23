//
//  CustomButton.swift
//  Notchify
//
//  Created by Jacob Büchler on 14.02.25.
//

import SwiftUI

// Button style configuration
struct ButtonStyleConfig {
    let background: Color
    let foreground: Color
    let border: Color?
    let shadow: Bool
    let hoverOpacity: Double
    
    static let primary = ButtonStyleConfig(
        background: .white,
        foreground: .black,
        border: nil,
        shadow: true,
        hoverOpacity: 0.9
    )
    
    static let destructive = ButtonStyleConfig(
        background: .red,
        foreground: .white,
        border: nil,
        shadow: true,
        hoverOpacity: 0.9
    )
    
    static let outline = ButtonStyleConfig(
        background: .clear,
        foreground: .primary,
        border: .gray,
        shadow: true,
        hoverOpacity: 0.1
    )
    
    static let secondary = ButtonStyleConfig(
        background: .gray.opacity(0.2),
        foreground: .primary,
        border: nil,
        shadow: true,
        hoverOpacity: 0.8
    )
    
    static let ghost = ButtonStyleConfig(
        background: .clear,
        foreground: .primary,
        border: nil,
        shadow: false,
        hoverOpacity: 0.1
    )
    
    static let link = ButtonStyleConfig(
        background: .clear,
        foreground: .blue,
        border: nil,
        shadow: false,
        hoverOpacity: 1
    )
}

// Button size configuration
enum ButtonSize {
    case small
    case `default`
    case large
    case icon
    
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .default: return 36
        case .large: return 40
        case .icon: return 36
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 12
        case .default: return 16
        case .large: return 32
        case .icon: return 0
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .default, .icon: return 14
        case .large: return 14
        }
    }
}

struct CustomButton<Content: View>: View {
    let variant: ButtonStyleConfig
    let size: ButtonSize
    let action: () -> Void
    let content: () -> Content
    @State private var isHovered = false
    let isDisabled: Bool
    
    init(
        variant: ButtonStyleConfig = .primary,
        size: ButtonSize = .default,
        isDisabled: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.variant = variant
        self.size = size
        self.action = action
        self.content = content
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                content()
            }
            .frame(height: size.height)
            .frame(width: size == .icon ? size.height : nil)
            .padding(.horizontal, size == .icon ? 0 : size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(variant.background.opacity(isHovered ? variant.hoverOpacity : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(variant.border ?? .clear, lineWidth: 1)
            )
            .foregroundColor(variant.foreground)
            .font(.system(size: size.fontSize, weight: .medium))
            .shadow(color: variant.shadow ? Color.black.opacity(0.1) : .clear, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .opacity(isDisabled ? 0.5 : 1)
        .disabled(isDisabled)
    }
}

// Link variant with underline
struct LinkButton: View {
    let action: () -> Void
    let label: String
    @State private var isHovered = false
    
    init(label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .foregroundColor(.blue)
                .underline(isHovered, color: .blue)
                .padding(.vertical, 2)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
}

// Preview
#Preview {
    VStack(spacing: 20) {
        Group {
            CustomButton(variant: .primary, action: {}) {
                Text("Primary Button")
            }
            
            CustomButton(variant: .destructive, action: {}) {
                Text("Destructive")
            }
            
            CustomButton(variant: .outline, action: {}) {
                Text("Outline")
            }
            
            CustomButton(variant: .secondary, action: {}) {
                Text("Secondary")
            }
            
            CustomButton(variant: .ghost, action: {}) {
                Text("Ghost")
            }
            
            CustomButton(variant: .primary, size: .icon, action: {}) {
                Image(systemName: "plus")
            }
            
            LinkButton(label: "Link Button", action: {})
            
            // Disabled state
            CustomButton(variant: .primary, isDisabled: true, action: {}) {
                Text("Disabled Button")
            }
        }
    }
    .padding()
}
