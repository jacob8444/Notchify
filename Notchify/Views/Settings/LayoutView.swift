//
//  LayoutView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI

struct LayoutView: View {
    // Media Player Settings
    @AppStorage("showMediaPlayer") private var showMediaPlayer = true
    @AppStorage("mediaPlayerStyle") private var mediaPlayerStyle = "compact"
    
    // App Shortcuts Settings
    @AppStorage("showAppShortcuts") private var showAppShortcuts = true
    @AppStorage("maxAppShortcuts") private var maxAppShortcuts = 5
    
    // Files Settings
    @AppStorage("showFiles") private var showFiles = true
    @AppStorage("filesDisplayMode") private var filesDisplayMode = "icons"
    @AppStorage("fileIconSize") private var fileIconSize = 32.0
    
    // Performance Settings
    @AppStorage("showPerformance") private var showPerformance = true
    @AppStorage("showCPU") private var showCPU = true
    @AppStorage("showMemory") private var showMemory = true
    @AppStorage("showGPU") private var showGPU = true
    @AppStorage("showStorage") private var showStorage = true
    @AppStorage("usePercentageColors") private var usePercentageColors = true
    
    // Quick Notes Settings
    @AppStorage("showQuickNotes") private var showQuickNotes = true
    @AppStorage("quickNotesHeight") private var quickNotesHeight = 200.0
    
    // Search Settings
    @AppStorage("showSearch") private var showSearch = true
    @AppStorage("searchStyle") private var searchStyle = "compact"
    @AppStorage("useBetterPercentages") private var useBetterPercentages = true
    
    // Search Settings
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Media Player Section
                GroupBox(label: Text("Media Player").font(.headline).padding(.bottom, 4)) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Show Media Player")
                                Text("Display media controls in the notch area.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showMediaPlayer)
                                .toggleStyle(.switch)
                        }
                        
                        if showMediaPlayer {
                            Divider()
                            
                            HStack {
                                Text("Style")
                                Spacer()
                                Picker("", selection: $mediaPlayerStyle) {
                                    Text("Compact").tag("compact")
                                    Text("Expanded").tag("expanded")
                                    Text("Minimal").tag("minimal")
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                    .padding(8)
                }
                
                // App Shortcuts Section
                GroupBox(label: Text("App Shortcuts").font(.headline).padding(.bottom, 4)) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Show App Shortcuts")
                                Text("Quick access to your favorite applications.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showAppShortcuts)
                                .toggleStyle(.switch)
                        }
                        
                        if showAppShortcuts {
                            Divider()
                            
                            HStack {
                                Text("Maximum Apps")
                                Spacer()
                                Picker("", selection: $maxAppShortcuts) {
                                    ForEach([3, 5, 7, 10], id: \.self) { count in
                                        Text("\(count)").tag(count)
                                    }
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                    .padding(8)
                }
                
                // Files Section
                GroupBox(label: Text("Files").font(.headline).padding(.bottom, 4)) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Show Files")
                                Text("Drag and drop files for quick access.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showFiles)
                                .toggleStyle(.switch)
                        }
                        
                        if showFiles {
                            Divider()
                            
                            HStack {
                                Text("Display Mode")
                                Spacer()
                                Picker("", selection: $filesDisplayMode) {
                                    Text("Icons").tag("icons")
                                    Text("List").tag("list")
                                }
                                .frame(width: 120)
                            }
                            
                            HStack {
                                Text("Icon Size")
                                Slider(value: $fileIconSize, in: 24...48, step: 8)
                                    .frame(width: 120)
                                Text("\(Int(fileIconSize))")
                                    .foregroundColor(.secondary)
                                    .frame(width: 30)
                            }
                        }
                    }
                    .padding(8)
                }
                
                // Performance Section
                GroupBox(label: Text("Performance").font(.headline).padding(.bottom, 4)) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Show Performance")
                                Text("Monitor system performance metrics.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showPerformance)
                                .toggleStyle(.switch)
                        }
                        
                        if showPerformance {
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Performance Metrics")
                                    Text("Select which metrics to display")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Toggle("CPU Usage", isOn: $showCPU)
                                    Toggle("Memory Usage", isOn: $showMemory)
                                    Toggle("GPU Usage", isOn: $showGPU)
                                    Toggle("Storage Usage", isOn: $showStorage)
                                }
                            }
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Percentage-Based Colors")
                                    Text("Use colors to indicate percentage values")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $usePercentageColors)
                                .toggleStyle(.switch)
                            }
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Use Better Percentages")
                                    Text("Show actual resource usage instead of macOS default percentages that often display 100%")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: $useBetterPercentages)
                                .toggleStyle(.switch)
                            }
                        }
                    }
                    .padding(8)
                }
                
                // Quick Notes Section
                GroupBox(label: Text("Quick Notes").font(.headline).padding(.bottom, 4)) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Show Quick Notes")
                                Text("Take quick notes without leaving your workflow.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showQuickNotes)
                                .toggleStyle(.switch)
                        }
                        
                        if showQuickNotes {
                            Divider()
                            
                            HStack {
                                Text("Window Height")
                                Slider(value: $quickNotesHeight, in: 150...400, step: 50)
                                    .frame(width: 120)
                                Text("\(Int(quickNotesHeight))")
                                    .foregroundColor(.secondary)
                                    .frame(width: 40)
                            }
                        }
                    }
                    .padding(8)
                }
                
                // Search Section
                GroupBox(label: Text("Search").font(.headline).padding(.bottom, 4)) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Show Search")
                                Text("Quick access to search functionality.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showSearch)
                                .toggleStyle(.switch)
                        }
                        
                        if showSearch {
                            Divider()
                            
                            HStack {
                                Text("Style")
                                Spacer()
                                Picker("", selection: $searchStyle) {
                                    Text("Compact").tag("compact")
                                    Text("Expanded").tag("expanded")
                                }
                                .frame(width: 120)
                            }
                        }
                    }
                    .padding(8)
                }
                // Calculator Section
                GroupBox(label: Text("Calculator").font(.headline).padding(.bottom, 4)) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Show Calculator")
                                Text("Take quick notes without leaving your workflow.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $showQuickNotes)
                                .toggleStyle(.switch)
                        }
                        
                        if showQuickNotes {
                            Divider()
                            
                            HStack {
                                Text("Window Height")
                                Slider(value: $quickNotesHeight, in: 150...400, step: 50)
                                    .frame(width: 120)
                                Text("\(Int(quickNotesHeight))")
                                    .foregroundColor(.secondary)
                                    .frame(width: 40)
                            }
                        }
                    }
                    .padding(8)
                }
            }
            .padding(20)
        }
        
    }
}

#Preview {
    LayoutView()
        .frame(width: 520)
        .environment(\.colorScheme, .dark)
}