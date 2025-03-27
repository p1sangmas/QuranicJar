//
//  ContentView.swift
//  QuranJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var userInput: String = ""
    @State private var predictedEmotion: String = ""
    @State private var quranicVerse: String = ""
    @State private var isLoading: Bool = false
    @State private var bookmarks: [String] = [] // List of bookmarked verses

    var body: some View {
        TabView {
            // Main Content
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
                                        Text(quranicVerse)
                                            .font(.body)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxHeight: 100)

                                    // Bookmark Button
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            bookmarkVerse()
                                        }) {
                                            Image(systemName: "bookmark")
                                                .font(.title2)
                                                .padding(5)
                                                .background(Color.green)
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
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

                    //Spacer()
                }
                .padding()
                .navigationTitle("Quranic Jar")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            // Bookmarks Tab
            BookmarkView(bookmarks: $bookmarks)
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }

            // Search Tab
            NavigationView {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            // Settings Tab
            Text("Settings")
                .font(.title)
                .foregroundColor(.primary)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }


    @ViewBuilder
    private func inputSection() -> some View {
        HStack {
            TextField("I am feeling ...", text: $userInput)
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
                    .background(isLoading ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .disabled(isLoading)
            .padding(.trailing, 5)
        }
        .background(Color(.systemGray6))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    func predictEmotion() {
        guard !userInput.isEmpty else { return }

        isLoading = true
        let url = URL(string: "http://192.168.0.108:3000/predict")!
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

    func bookmarkVerse() {
        guard !quranicVerse.isEmpty else { return }
        if !bookmarks.contains(quranicVerse) {
            bookmarks.append(quranicVerse)
        }
    }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
