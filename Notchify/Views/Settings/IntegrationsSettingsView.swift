//
//  IntegrationsSettingsView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI
import Cocoa

struct IntegrationsSettingsView: View {
    @AppStorage("appleMusic") private var appleMusic = false
    @AppStorage("spotify") private var spotify = false
    @State private var appleMusicIcon: NSImage?
    @State private var spotifyIcon: NSImage?
    
    var body: some View {
        VStack(spacing: 20) {
            GroupBox(label: Text("Music Services").font(.headline).padding(.bottom, 4)) {
                VStack(spacing: 16) {
                    HStack {
                        HStack(spacing: 12) {
                            if let icon = appleMusicIcon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                            VStack(alignment: .leading) {
                                Text("Apple Music")
                                Text("Show currently playing track")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Toggle("", isOn: $appleMusic)
                            .toggleStyle(.switch)
                            .onChange(of: appleMusic) { newValue in
                                if newValue {
                                    spotify = false
                                }
                            }
                    }
                    
                    Divider()
                    
                    HStack {
                        HStack(spacing: 12) {
                            if let icon = spotifyIcon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                            VStack(alignment: .leading) {
                                Text("Spotify")
                                Text("Show currently playing track")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Toggle("", isOn: $spotify)
                            .toggleStyle(.switch)
                            .onChange(of: spotify) { newValue in
                                if newValue {
                                    appleMusic = false
                                }
                            }
                    }
                }
                .padding(8)
            }
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            if let appleMusicURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") {
                appleMusicIcon = NSWorkspace.shared.icon(forFile: appleMusicURL.path)
            }
            if let spotifyURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client") {
                spotifyIcon = NSWorkspace.shared.icon(forFile: spotifyURL.path)
            }
        }
    }
}

#Preview {
    IntegrationsSettingsView()
        .frame(width: 520)
        .environment(\.colorScheme, .dark)
}