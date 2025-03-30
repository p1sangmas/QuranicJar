//
//  QuranJarApp.swift
//  QuranJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI

@main
struct QuranicJarApp: App {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"

    var body: some Scene {
        WindowGroup {
            if userName.isEmpty {
                WelcomeView()
            } else {
                ContentView()
                    .preferredColorScheme(colorSchemeForAppearanceMode()) // Apply global color scheme
            }
        }
    }

    private func colorSchemeForAppearanceMode() -> ColorScheme? {
        switch appearanceMode {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // Follow the system appearance
        }
    }
}
