import SwiftUI

struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "system" // Store appearance preference
    @AppStorage("userName") private var userName: String = "" // Store user name
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @Binding var bookmarks: [QuranVerse] // Pass bookmarks as a binding

    @State private var showResetConfirmation = false // State to show confirmation dialog

    var body: some View {
        NavigationView {
            Form {
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Picker("Appearance", selection: $appearanceMode) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                        Text("System").tag("system")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Application Section
                Section(header: Text("Application")) {
                    NavigationLink(destination: AboutView()) {
                        Text("About App")
                    }
                    Link("Give Feedback", destination: URL(string: "https://forms.gle/HzD8wj7d5Zehyiw5A")!)
                                            .foregroundColor(.blue)
                }

                // Reset Section
                Section(header: Text("Reset")) {
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Text("Reset App")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showResetConfirmation) {
                        Alert(
                            title: Text("Reset App"),
                            message: Text("Are you sure you want to reset the app? This will clear all data."),
                            primaryButton: .destructive(Text("Reset")) {
                                resetApp()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .preferredColorScheme(colorSchemeForAppearanceMode())
        Spacer()
    }

    private func resetApp() {
        // Clear stored data
        userName = ""
        appearanceMode = "system"
        bookmarks = []
        
        // Persist the cleared bookmarks to @AppStorage
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(bookmarks) {
            let bookmarksData = String(data: encodedData, encoding: .utf8) ?? "[]"
            UserDefaults.standard.set(bookmarksData, forKey: "bookmarks") // Save to UserDefaults
        }

        // Navigate to WelcomeView
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: WelcomeView())
            window.makeKeyAndVisible()
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(bookmarks: .constant([]))
    }
}
