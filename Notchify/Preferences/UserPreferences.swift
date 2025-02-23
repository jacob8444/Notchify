//
//  UserPreferences.swift
//  Notchify
//
//  Created by Jacob Büchler on 10.02.25.
//

import Foundation
import SwiftUI
import AppKit

@MainActor
class UserPreferences: ObservableObject {
    private let defaults = UserDefaults.standard
    
    @Published var windowWidth: Double {
        didSet { defaults.set(windowWidth, forKey: "windowWidth") }
    }
    
    init() {
        self.windowWidth = defaults.double(forKey: "windowWidth") != 0 ? defaults.double(forKey: "windowWidth") : 350
    }
}
