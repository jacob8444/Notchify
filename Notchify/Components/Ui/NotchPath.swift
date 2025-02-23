//
//  Path.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI

struct NotchPath: Shape {
    let distanceTop: Int
    let width: Int
    let height: Int
    let cornerRadius: Int
    let cornerRadiusBottom: Int
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            
            // Start from top-left with outward curve
            path.move(to: CGPoint(x: 0, y: distanceTop))
            
            // Top edge
            path.addLine(to: CGPoint(x: width , y: distanceTop))
            
            // Top-right outward curve
            path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: cornerRadius + distanceTop),
                             control: CGPoint(x: width - cornerRadius, y: distanceTop))
            
            // Right edge
            path.addLine(to: CGPoint(x: width - cornerRadius, y: height - cornerRadiusBottom + distanceTop))
            
            // Bottom-right rounded corner
            path.addQuadCurve(to: CGPoint(x: width - cornerRadius - cornerRadiusBottom, y: height + distanceTop),
                              control: CGPoint(x: width - cornerRadius, y: height + distanceTop))
            
            // Bottom edge
            path.addLine(to: CGPoint(x: cornerRadiusBottom + cornerRadius, y: height + distanceTop))
            
            // Bottom-left rounded corner
            path.addQuadCurve(to: CGPoint(x: cornerRadius, y: height - cornerRadiusBottom + distanceTop),
                             control: CGPoint(x: cornerRadius, y: height  + distanceTop))

            // Left edge
            path.addLine(to: CGPoint(x: cornerRadius, y: cornerRadius  + distanceTop))

            // Top-left rounded corner
            path.addQuadCurve(to: CGPoint(x: 0, y: distanceTop),
                             control: CGPoint(x: cornerRadius, y: distanceTop))
            // Close the path
            path.closeSubpath()
        }
    }
}

#Preview {
    NotchView()
        .environmentObject(AppDelegate())
}
