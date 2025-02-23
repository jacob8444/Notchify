//
//  AppsView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI
import Cocoa

struct AppIcon: View {
    let icon: NSImage
    let name: String
    @State private var isHovered = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .opacity(isHovered ? 1 : 0)
            )
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(.plain)
        .help(name)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}

struct AppsView: View {
    let appDelegate: AppDelegate?
    @State private var apps: [(icon: NSImage, name: String)] = []
    
    private func loadApps() {
        let workspace = NSWorkspace.shared
        let applications = workspace.runningApplications.filter {
            $0.activationPolicy == .regular
        }
        
        apps = applications.compactMap { app in
            guard let icon = app.icon,
                  let name = app.localizedName else {
                return nil
            }
            return (icon: icon, name: name)
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(apps.enumerated()), id: \.0) { _, app in
                    AppIcon(icon: app.icon, name: app.name) {
                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.name) {
                            NSWorkspace.shared.openApplication(
                                at: url,
                                configuration: NSWorkspace.OpenConfiguration()
                            )
                        }
                    }
                }
            }
        }
        .cornerRadius(10)
        .padding(.horizontal, 22)
        .onAppear {
            loadApps()
        }
    }
}

#Preview {
    NotchView()
        .environmentObject(AppDelegate())
}
