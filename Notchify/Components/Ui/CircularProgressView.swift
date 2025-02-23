//
//  CircularProgressView.swift
//  Notchify
//
//  Created by Jacob Büchler on 14.02.25.
//

import SwiftUI

struct CircularProgressView: View {
    let percentage: Double
    let label: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: percentage / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: percentage)
            
            VStack(spacing: 2) {
                Text("\(Int(percentage))%")
                    .font(.system(size: 10, weight: .medium))
                Text(label)
                    .font(.system(size: 6))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 40, height: 40)
    }
}
