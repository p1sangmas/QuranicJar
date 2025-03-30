//
//  ContentView.swift
//  QuranJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI
import Network

struct ContentView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("bookmarks") private var bookmarksData: String = "[]" // Store bookmarks as a JSON string
    @State private var userInput: String = ""
    @State private var predictedEmotion: String = ""
    @State private var quranicVerse: String = ""
    @State private var isLoading: Bool = false
    @State private var bookmarks: [QuranVerse] = []
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var selectedTab: Int = 0
    
    // Computed property to calculate word count
    private var wordCount: Int {
        userInput.split { $0.isWhitespace }.count
    }

    // Computed property to check if the button should be enabled
    private var isPredictButtonEnabled: Bool {
        wordCount >= 3 && !isLoading && networkMonitor.status == "Connected"
    }

    var body: some View {
        ZStack {
            // Main Content
            TabView(selection: $selectedTab) {
                NavigationView {
                    VStack(spacing: 20) {
                        Spacer()

                        // Greeting Section
                        VStack(spacing: 10) {
                            TypewriterText(text: "Assalamualaikum, \(userName)!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)

                            Text("How are you feeling today?")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()

                        // Input Section
                        Spacer()
                        inputSection()
                            .padding(.horizontal)

                        // Loading Indicator
                        if isLoading {
                            ProgressView("Finding suitable verse...")
                                .padding()
                        }

                        // Results Section
                        if !predictedEmotion.isEmpty || !quranicVerse.isEmpty {
                            VStack(spacing: 15) {
                                if !predictedEmotion.isEmpty {
                                    VStack {
                                        Text("Predicted Emotion")
                                            .font(.headline)
                                            .foregroundColor(.secondary)

                                        Text(predictedEmotion)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                    }
                                }

                                if !quranicVerse.isEmpty {
                                    VStack {
                                        Text("Quranic Verse")
                                            .font(.headline)
                                            .foregroundColor(.secondary)

                                        ScrollView {
                                            VStack(spacing: 10) {
                                                // Display Arabic text
                                                if let verse = parseQuranicVerse(quranicVerse, emotion: predictedEmotion) {
                                                    Text(verse.ayahArabic)
                                                        .font(.title)
                                                        .multilineTextAlignment(.center)
                                                        .foregroundColor(.primary)
                                                }

                                                // Display English translation
                                                Text(quranicVerse)
                                                    .font(.body)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .frame(maxHeight: 100)

                                        // Bookmark Button
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                if let verse = parseQuranicVerse(quranicVerse, emotion: predictedEmotion) {
                                                    bookmarkVerse(verse: verse)
                                                    let generator = UINotificationFeedbackGenerator()
                                                    generator.notificationOccurred(.success)
                                                    print("Verse successfully bookmarked!")
                                                } else {
                                                    print("Failed to parse quranicVerse")
                                                }
                                            }) {
                                                Image(systemName: "bookmark")
                                                    .font(.title2)
                                                    .padding(5)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }

                    }
                    .padding()
                    .navigationTitle("Quranic Jar")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0) // Tag for the "Home" tab

                // Bookmarks Tab
                BookmarkView(bookmarks: $bookmarks)
                    .tabItem {
                        Label("Bookmarks", systemImage: "bookmark")
                    }
                    .tag(1) // Tag for the "Bookmarks" tab

                // Search Tab
                NavigationView {
                    SearchView(bookmarks: $bookmarks)
                }
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2) // Tag for the "Search" tab

                // Settings Tab
                NavigationView {
                    SettingsView(bookmarks: $bookmarks)
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3) // Tag for the "Settings" tab
            }
            .onAppear(perform: loadBookmarks)

            // Fixed Network Status (Only for Home Tab)
            if selectedTab == 0 {
                VStack {
                    HStack {
                        Image(systemName: networkMonitor.status == "Connected" ? "network" : "network.slash")
                            .foregroundColor(networkMonitor.status == "Connected" ? .green : .red)
                            .scaleEffect(networkMonitor.status == "Connected" ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: networkMonitor.status)

                        Text(networkMonitor.status)
                            .font(.footnote)
                            .foregroundColor(networkMonitor.status == "Connected" ? .green : .red)
                            .scaleEffect(networkMonitor.status == "Connected" ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: networkMonitor.status)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(networkMonitor.status == "Connected" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.top, 50)
                    .animation(.easeInOut(duration: 1), value: networkMonitor.status)

                    Spacer()
                }
            }
        }
    }
    
    private func loadBookmarks() {
        // Decode bookmarks from JSON string
        if let data = bookmarksData.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let decodedBookmarks = try? decoder.decode([QuranVerse].self, from: data) {
                bookmarks = decodedBookmarks
                print("Loaded bookmarks: \(bookmarks)")
            } else {
                print("Failed to decode bookmarks")
            }
        } else {
            print("No bookmarks data found")
        }
    }

    private func saveBookmarks() {
        // Encode bookmarks to JSON string
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(bookmarks) {
            bookmarksData = String(data: encodedData, encoding: .utf8) ?? "[]"
        }
    }


    @ViewBuilder
    private func inputSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("3-5 words on your feeling...", text: $userInput)
                    .padding(.leading)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                    .multilineTextAlignment(.leading)

                Button(action: {
                    predictEmotion()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "stethoscope")
                        .font(.title2)
                        .padding()
                        .background(isPredictButtonEnabled ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(!isPredictButtonEnabled) // Disable button if word count < 4
                .padding(.trailing, 5)
            }
            .background(Color(.systemGray6))
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }

    func predictEmotion() {
        guard !userInput.isEmpty else { return }

        isLoading = true
        let url = URL(string: "http://<backend-ip>:3000/predict")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["text": userInput]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else { return }
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let emotion = jsonResponse["predicted_emotion"] as? String,
                   let verse = jsonResponse["quranic_verse"] as? String {
                    self.predictedEmotion = emotion
                    self.quranicVerse = verse
                }
            }
        }.resume()
    }

    func bookmarkVerse(verse: QuranVerse) {
        if !bookmarks.contains(where: { $0.id == verse.id }) {
            bookmarks.append(verse)
            saveBookmarks()
        }
    }
    
}

func parseQuranicVerse(_ quranicVerse: String, emotion: String) -> QuranVerse? {
    // Split the verse into the main text and the metadata (inside parentheses)
    guard let metadataStart = quranicVerse.range(of: "("),
          let metadataEnd = quranicVerse.range(of: ")") else {
        return nil // Return nil if the format is invalid
    }

    let ayahEnglish = String(quranicVerse[..<metadataStart.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    let metadata = String(quranicVerse[metadataStart.upperBound..<metadataEnd.lowerBound])

    // Extract surah name, meaning, and verse number from the metadata
    // Example metadata: "Surah Al-Qasas: The Stories, Verse 88"
    let components = metadata.components(separatedBy: ",")
    guard components.count == 2 else { return nil }

    let surahPart = components[0].trimmingCharacters(in: .whitespacesAndNewlines) // "Surah Al-Qasas: The Stories"
    let versePart = components[1].trimmingCharacters(in: .whitespacesAndNewlines) // "Verse 88"

    // Extract surah name and meaning
    let surahComponents = surahPart.components(separatedBy: ":")
    guard surahComponents.count == 2 else { return nil }

    let surahEnglish = surahComponents[0].replacingOccurrences(of: "Surah ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    let surahMeaning = surahComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)

    // Extract verse number
    guard let ayahNo = Int(versePart.replacingOccurrences(of: "Verse ", with: "")) else { return nil }

    // Return a QuranVerse object with the emotion included
    return QuranVerse(
        surahNo: 0,
        ayahNo: ayahNo,
        surahName: "",
        ayahArabic: "",
        emotion: emotion, // Include the emotion type
        ayahEnglish: ayahEnglish,
        surahMeaning: surahMeaning,
        surahEnglish: surahEnglish
    )
}

struct TypewriterText: View {
    let text: String
    @State private var displayedText: String = ""
    @State private var charIndex: Int = 0

    var body: some View {
        Text(displayedText)
            .onAppear {
                displayedText = ""
                charIndex = 0
                typeText()
            }
    }

    private func typeText() {
        guard charIndex < text.count else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            displayedText.append(text[text.index(text.startIndex, offsetBy: charIndex)])
            charIndex += 1
            typeText()
        }
    }
}

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published var status: String = "Searching for network"

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.status = "Connected"
                } else {
                    self.status = "No internet connection"
                }
            }
        }
        monitor.start(queue: queue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
