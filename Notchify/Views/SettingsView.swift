//
//  SettingsView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import Cocoa
import SwiftUI

struct SettingsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                GeneralSettingsView()
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
                    .tag(0)
                
                IntegrationsSettingsView()
                    .tabItem {
                        Label("Integrations", systemImage: "link")
                    }
                    .tag(1)
                
                LayoutView()
                    .tabItem {
                        Label("Layout", systemImage: "square.grid.2x2")
                    }
                    .tag(2)
            }
        }
        .frame(width: 520, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
    }

#Preview {
    SettingsView()
}
