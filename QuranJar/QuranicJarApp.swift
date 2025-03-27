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

    var body: some Scene {
        WindowGroup {
            if userName.isEmpty {
                WelcomeView()
            } else {
                ContentView()
            }
        }
    }
}
