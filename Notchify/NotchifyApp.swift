//

//  NotchifyApp.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import SwiftUI
import Cocoa
import Combine

@main
struct NotchifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let defaultWindowWidth: CGFloat = 300
    static let notchAreaWidth: CGFloat = 200
    static let notchAreaHeight: CGFloat = 24
    static let menuPadding: CGFloat = 10
    static let animationDuration: TimeInterval = 0.3
    static let hideAnimationDuration: TimeInterval = 0.2
    static let minVisibilityDuration: TimeInterval = 0.5
    static let mouseMoveThreshold: CGFloat = 10
}

// MARK: - AppTheme
enum AppTheme {
    case light, dark, system
}

// MARK: - AppDelegate
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem?
    private var overlayWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var lastMouseMoveTime: Date?
    private var lastMouseLocation: NSPoint?
    
    @Published var preferences: UserPreferences
    @Published var isDraggingFiles: Bool
    @Published private(set) var isMenuVisible = false
    
    override init() {
        self.preferences = UserPreferences()
        self.isDraggingFiles = false
        super.init()
        setupPreferencesObserver()
    }
    
    // MARK: - Setup Methods
    private func setupPreferencesObserver() {
        preferences.objectWillChange
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateOverlayWindow()
            }
            .store(in: &cancellables)
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "menubar.dock.rectangle", accessibilityDescription: "Notchify")
            button.target = self
            button.action = #selector(toggleSettings)
        }
    }
    
    // MARK: - Window Management
    private func updateOverlayWindow() {
        guard let window = overlayWindow,
              let screen = NSScreen.main else { return }
        
        let menuView = NotchView()
            .environmentObject(self)
        let hostingView = NSHostingView(rootView: menuView)
        
        window.contentView = hostingView
        
        let contentSize = hostingView.intrinsicContentSize
        let centerX = screen.frame.width / 2
        let finalFrame = NSRect(
            x: centerX - (preferences.windowWidth / 2),
            y: screen.frame.height - (contentSize.height - Constants.menuPadding),
            width: preferences.windowWidth,
            height: contentSize.height
        )
        
        window.setFrame(finalFrame, display: true)
    }
    
    // MARK: - Mouse Tracking
    private func setupNotchDetection() {
        let eventMask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged]
        
        NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] event in
            self?.checkMouseLocation(event: event)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: eventMask) { [weak self] event in
            self?.checkMouseLocation(event: event)
            return event
        }
    }
    
    private func checkMouseLocation(event: NSEvent) {
        guard let screen = NSScreen.main else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        let window: NSWindow = overlayWindow ?? NSWindow()
        if event.type == .leftMouseDragged {
            if !window.frame.contains(mouseLocation) {
                isDraggingFiles = true
            }
        } else if event.type == .mouseMoved {
            isDraggingFiles = false
        }
        let notchArea = calculateNotchArea(for: screen)
        let currentTime = Date()
        
        // Prevent rapid toggling
        if let lastTime = lastMouseMoveTime,
           currentTime.timeIntervalSince(lastTime) < Constants.minVisibilityDuration {
            return
        }
        
        // Check distance moved to prevent jittery behavior
        if let lastLocation = lastMouseLocation,
           distance(from: lastLocation, to: mouseLocation) < Constants.mouseMoveThreshold {
            return
        }
        
        if notchArea.contains(mouseLocation) {
            openOverlay(at: mouseLocation)
        } else if let window: NSWindow = overlayWindow {
            let expandedFrame = window.frame.insetBy(dx: -Constants.menuPadding, dy: -Constants.menuPadding)
            if !expandedFrame.contains(mouseLocation) {
                closeOverlay()
            }
        }
        
        lastMouseMoveTime = currentTime
        lastMouseLocation = mouseLocation
    }
    
    private func distance(from point1: NSPoint, to point2: NSPoint) -> CGFloat {
        return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
    }
    
    private func calculateNotchArea(for screen: NSScreen) -> NSRect {
        NSRect(
            x: screen.frame.width / 2 - Constants.notchAreaWidth / 2,
            y: screen.frame.height,
            width: Constants.notchAreaWidth,
            height: Constants.notchAreaHeight
        )
    }
    
    // MARK: - Menu Actions
    private func openOverlay(at location: NSPoint? = nil) {
        guard let screen = NSScreen.main else { return }
        if overlayWindow == nil {
            let menuView = NotchView()
                .environmentObject(self)
            let hostingView = NSHostingView(rootView: menuView)
            let contentSize = hostingView.fittingSize
            overlayWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: preferences.windowWidth, height: contentSize.height),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            overlayWindow?.backgroundColor = .clear
            overlayWindow?.isOpaque = false
            overlayWindow?.hasShadow = true
            overlayWindow?.level = .statusBar
            overlayWindow?.ignoresMouseEvents = false
            overlayWindow?.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
            overlayWindow?.acceptsMouseMovedEvents = true
            overlayWindow?.alphaValue = 1
            
            overlayWindow?.contentView = hostingView
        }
        
        guard let window = overlayWindow else { return }
        
        let centerX = screen.frame.width / 2
        let contentHeight = window.contentView?.fittingSize.height ?? 400
        
        let startFrame = NSRect(
            x: centerX - preferences.windowWidth / 2,
            y: screen.frame.height,
            width: preferences.windowWidth,
            height: contentHeight
        )
        
        let finalFrame = NSRect(
            x: centerX - preferences.windowWidth / 2,
            y: screen.frame.height - (contentHeight - Constants.menuPadding),
            width: preferences.windowWidth,
            height: contentHeight
        )
        
        window.setFrame(startFrame, display: true)
        window.orderFront(nil)
        window.alphaValue = 0
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(finalFrame, display: true)
            window.animator().alphaValue = 1
        }
        
        isMenuVisible = true
    }
    
    private func closeOverlay() {
        guard let window = overlayWindow,
              let screen = NSScreen.main,
              settingsWindow?.isVisible != true else { return }
        
        let finalFrame = NSRect(
            x: window.frame.origin.x,
            y: screen.frame.height,
            width: window.frame.width,
            height: window.frame.height
        )
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.hideAnimationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().setFrame(finalFrame, display: true)
            window.animator().alphaValue = 0
        } completionHandler: {
            window.orderOut(nil)
            self.isMenuVisible = false
        }
    }
    
    // MARK: - Public Methods
    @objc public func toggleSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            settingsWindow?.title = "Notchify Settings"
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
            settingsWindow?.center()
            settingsWindow?.isReleasedWhenClosed = false
            settingsWindow?.backgroundColor = .windowBackgroundColor
        }
        
        if settingsWindow?.isVisible == true {
            settingsWindow?.close()
        } else {
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    // MARK: - NSApplicationDelegate
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure single instance
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let runningApps = NSWorkspace.shared.runningApplications
        let instances = runningApps.filter { $0.bundleIdentifier == bundleID }
        
        if instances.count > 1 {
            // Find and terminate other instances
            for app in instances {
                if app.processIdentifier != NSRunningApplication.current.processIdentifier {
                    app.terminate()
                }
            }
        }
        
        setupStatusItem()
        setupNotchDetection()
    }
}
