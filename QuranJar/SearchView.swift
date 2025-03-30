//
//  SearchView.swift
//  QuranicJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI
import Foundation

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var results: [QuranVerse] = []
    @State private var allVerses: [QuranVerse] = []
    @State private var selectedEmotion: String? = nil // Track the selected emotion filter
    @Binding var bookmarks: [QuranVerse] // Pass bookmarks as a binding
    @AppStorage("bookmarks") private var bookmarksData: String = "[]"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Filter Buttons
                HStack(spacing: 10) {
                    FilterButton(title: "Anger", color: .red, isSelected: selectedEmotion == "anger") {
                        toggleFilter(for: "anger")
                    }
                    FilterButton(title: "Fear", color: .purple, isSelected: selectedEmotion == "fear") {
                        toggleFilter(for: "fear")
                    }
                    FilterButton(title: "Joy", color: .green, isSelected: selectedEmotion == "joy") {
                        toggleFilter(for: "joy")
                    }
                    FilterButton(title: "Sadness", color: .blue, isSelected: selectedEmotion == "sadness") {
                        toggleFilter(for: "sadness")
                    }
                    Button(action: {
                        searchText = ""
                        selectedEmotion = nil
                        results = []
                    }) {
                        Image(systemName: "clear")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                // Search Bar
                SearchBar(text: $searchText, onSearch: {
                    performSearch()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                })

                // Results List
                List(results) { verse in
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Quranic Verse:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(verse.ayahArabic)
                                .font(.title3)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.primary)
                            Text(verse.ayahEnglish)
                                .font(.body)
                                .foregroundColor(.primary)
                            Text("(Surah \(verse.surahEnglish): \(verse.ayahNo))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        // Bookmark Button
                        Button(action: {
                            bookmarkVerse(verse)
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }) {
                            Image(systemName: "bookmark")
                                .font(.title2)
                                .padding(5)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Search")
            .onAppear {
                allVerses = loadQuranVerses(from: "quran_emotions_cleaned_2")
            }
        }
        Spacer()
    }

    private func performSearch() {
        results = allVerses.filter { verse in
            let matchesSearchText = searchText.isEmpty ||
                verse.surahName.localizedCaseInsensitiveContains(searchText) ||
                verse.surahEnglish.localizedCaseInsensitiveContains(searchText) ||
                verse.ayahArabic.localizedCaseInsensitiveContains(searchText) ||
                verse.ayahEnglish.localizedCaseInsensitiveContains(searchText)

            let matchesEmotion = selectedEmotion == nil || verse.emotion == selectedEmotion

            return matchesSearchText && matchesEmotion
        }
    }

    private func toggleFilter(for emotion: String) {
        if selectedEmotion == emotion {
            selectedEmotion = nil // Deselect if already selected
        } else {
            selectedEmotion = emotion // Select the new emotion
        }
        performSearch() // Update the results based on the filter
    }

    private func bookmarkVerse(_ verse: QuranVerse) {
        if !bookmarks.contains(where: { $0.id == verse.id }) {
            bookmarks.append(verse)
            saveBookmarks() // Save bookmarks after adding a new one
        }
    }

    private func saveBookmarks() {
        // Encode bookmarks to JSON string
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(bookmarks) {
            bookmarksData = String(data: encodedData, encoding: .utf8) ?? "[]"
            print("Saved bookmarks: \(bookmarksData)") // Debug print
        }
    }
}

struct FilterButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? color : Color.clear)
                .foregroundColor(isSelected ? .white : color)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 2)
                )
                .cornerRadius(20)
        }
        .animation(.easeInOut, value: isSelected)
    }
}

struct QuranVerse: Identifiable, Codable {
    let id = UUID()
    let surahNo: Int
    let ayahNo: Int
    let surahName: String
    let ayahArabic: String
    let emotion: String
    let ayahEnglish: String
    let surahMeaning: String
    let surahEnglish: String
}

func loadQuranVerses(from fileName: String) -> [QuranVerse] {
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("File not found")
        return []
    }

    do {
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let rows = content.components(separatedBy: "\n").dropFirst() // Skip header row
        var verses: [QuranVerse] = []

        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count == 8 {
                if let surahNo = Int(columns[0]), let ayahNo = Int(columns[1]) {
                    let verse = QuranVerse(
                        surahNo: surahNo,
                        ayahNo: ayahNo,
                        surahName: columns[2],
                        ayahArabic: columns[3],
                        emotion: columns[4],
                        ayahEnglish: columns[5],
                        surahMeaning: columns[6],
                        surahEnglish: columns[7]
                    )
                    verses.append(verse)
                }
            }
        }
        return verses
    } catch {
        print("Error reading file: \(error)")
        return []
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text, onCommit: onSearch)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(bookmarks: .constant([]))
    }
}
