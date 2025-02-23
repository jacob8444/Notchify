//
//  GeneralSettingsView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    var body: some View {
        VStack(spacing: 20) {
            GroupBox(label: Text("Startup").font(.headline).padding(.bottom, 4)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Launch at login")
                        Text("Automatically start Notchify when you log in")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $launchAtLogin)
                        .toggleStyle(.switch)
                }
                .padding(8)
            }
            
            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    GeneralSettingsView()
        .frame(width: 520)
        .environment(\.colorScheme, .dark)
}