//
//  ContentView.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI
import Cocoa


enum ActiveView {
    case media, apps, files, performance, notes, search, calculator
}

struct NotchView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @State var activeView: ActiveView?
    private var height = 50
    
    private func updateActiveView() {
        if appDelegate.isDraggingFiles {
            activeView = .files
        }
    }
    
    private func isBuiltInDisplay(_ screen: NSScreen) -> Bool {
        // Check if the display is built-in by examining its localized name
        let localizedName = screen.localizedName.lowercased()
        return localizedName.contains("built-in") || localizedName.contains("retina")
    }
    
    private func getNotchHeight(_ screen: NSScreen) -> Int {
        let aditional = isBuiltInDisplay(screen) ? 20 : 0
        
        
        switch activeView {
        case .performance:
            return 66 + height + aditional
        case .apps:
            return 52 + height + aditional
        case .media:
            return 60 + height + aditional
        case .files:
            return 82 + height + aditional
        case .search:
            return height + aditional
        case .notes:
            return 200 + height + aditional
        case .calculator:
            return height + aditional
        case nil:
            return height + aditional
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                NotchPath(distanceTop: 10,
                          width: Int(appDelegate.preferences.windowWidth),
                          height: getNotchHeight(NSScreen.main ?? NSScreen()),
                          cornerRadius: 12, cornerRadiusBottom: 20)
                .fill(.black)
                .opacity(1)
                .shadow(color: .black.opacity(0.75), radius: 3, x: 0, y: 1)
                VStack(spacing: 0) {
                    
                    NotchHeader(appDelegate: appDelegate, isBuiltInDisplay: isBuiltInDisplay, activeView: $activeView)
                    
                    switch activeView {
                    case .media:
                        MediaView(appDelegate: appDelegate)
                    case .apps:
                        AppsView(appDelegate: appDelegate)
                    case .files:
                        FilesView(appDelegate: appDelegate)
                    case .performance:
                        PerformanceView(appDelegate: appDelegate)
                    case .notes:
                        NotesView(appDelegate: appDelegate)
                    case .search:
                        SearchView(appDelegate: appDelegate)
                    case .calculator:
                        CalculatorView(appDelegate: appDelegate)
                    case nil:
                        EmptyView()
                    }
                    Spacer()
                }
            }
        }
        .frame(width: appDelegate.preferences.windowWidth)
        .onChange(of: appDelegate.isDraggingFiles) { oldValue, newValue in
            if(newValue) {
                activeView = .files
            }
        }
        .onAppear(){
            if appDelegate.isDraggingFiles {
                activeView = .files
            }
        }
    }
}

struct NotchHeader: View {
    let appDelegate: AppDelegate?
    let isBuiltInDisplay: (NSScreen) -> Bool
    @Binding var activeView: ActiveView?
    
    @AppStorage("showMediaPlayer") private var showMediaPlayer = true
    @AppStorage("showAppShortcuts") private var showAppShortcuts = true
    @AppStorage("showFiles") private var showFiles = true
    @AppStorage("showPerformance") private var showPerformance = true
    @AppStorage("showQuickNotes") private var showQuickNotes = true
    @AppStorage("showSearch") private var showSearch = true
    
    var body: some View {
        HStack(spacing: 0) {
            if showMediaPlayer {
                SimpleButton(icon: (activeView == .media ? "play.circle.fill" : "play.circle"), title: "Media", isActive: activeView == .media) {
                    activeView = .media
                }
            }
            if showAppShortcuts {
                SimpleButton(icon: (activeView == .apps ? "circle.fill" : "circle"), title: "Apps", isActive: activeView == .apps) {
                    activeView = .apps
                }
            }
            if showFiles {
                SimpleButton(icon: (activeView == .files ? "circle.fill" : "circle"), title: "Files", isActive: activeView == .files) {
                    activeView = .files
                }
            }
            if showPerformance {
                SimpleButton(icon: (activeView == .performance ? "gauge.with.needle.fill" : "gauge.with.needle"), title: "Performance", isActive: activeView == .performance) {
                    activeView = .performance
                }
            }
            if showQuickNotes {
                SimpleButton(icon: (activeView == .notes ? "square.and.pencil.circle.fill" : "square.and.pencil.circle"), title: "Quick Notes", isActive: activeView == .notes) {
                    activeView = .notes
                }
            }
            if showSearch {
                SimpleButton(icon: (activeView == .search ? "magnifyingglass.circle.fill" : "magnifyingglass.circle"), title: "Search", isActive: activeView == .search) {
                    activeView = .search
                }
            }
            SimpleButton(icon: (activeView == .calculator ? "number.circle.fill" : "number.circle"), title: "Calculator", isActive: activeView == .calculator) {
                activeView = .calculator
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 5)
        .padding(.top, (isBuiltInDisplay(NSScreen.main ?? NSScreen()) ? 40 : 20))
    }
}


struct SimpleButton: View {
    let icon: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white.opacity(0.1))
                        .opacity(isHovered || isActive ? 1 : 0)
                )
                .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(SimpleButtonStyle())
        .frame(width: 32)
        .help(title)
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

struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .secondary : .primary)
    }
}

#Preview {
    NotchView()
        .environmentObject(AppDelegate())
}
