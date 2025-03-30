//
//  BookmarkView.swift
//  QuranJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI

struct BookmarkView: View {
    @Binding var bookmarks: [QuranVerse] // Pass bookmarks as a binding
    @State private var filteredBookmarks: [QuranVerse] = [] // Filtered list of bookmarks
    @State private var selectedEmotion: String? = nil // Track the selected emotion filter

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Emotion Filter Buttons
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
                        selectedEmotion = nil
                        filteredBookmarks = bookmarks // Reset filter
                    }) {
                        Image(systemName: "clear")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Bookmarked Verses List
                List {
                    if filteredBookmarks.isEmpty {
                        Text("No bookmarks yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(filteredBookmarks) { verse in
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Quranic Verse:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text(verse.ayahArabic)
                                    .font(.body)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.primary)
                                Text(verse.ayahEnglish)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("(\(verse.surahEnglish): \(verse.ayahNo))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Spacer()
                                    Text(verse.emotion.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 10)
                                        .background(colorForEmotion(verse.emotion))
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete(perform: deleteBookmark)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Bookmarks")
            .onAppear {
                filteredBookmarks = bookmarks // Initialize with all bookmarks
            }
        }
    }

    private func toggleFilter(for emotion: String) {
        if selectedEmotion == emotion {
            selectedEmotion = nil // Deselect if already selected
            filteredBookmarks = bookmarks // Reset to all bookmarks
        } else {
            selectedEmotion = emotion // Select the new emotion
            filteredBookmarks = bookmarks.filter { $0.emotion.lowercased() == emotion }
        }
    }

    private func deleteBookmark(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets) // Remove the bookmark from the array
        filteredBookmarks = bookmarks // Update the filtered list
        saveBookmarks() // Persist the updated bookmarks
    }
    
    private func saveBookmarks() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(bookmarks) {
            if let bookmarksData = String(data: encodedData, encoding: .utf8) {
                UserDefaults.standard.set(bookmarksData, forKey: "bookmarks") // Save to UserDefaults
            }
        }
    }
    
    private func colorForEmotion(_ emotion: String) -> Color {
        switch emotion.lowercased() {
        case "anger":
            return .red
        case "fear":
            return .purple
        case "joy":
            return .green
        case "sadness":
            return .blue
        default:
            return .gray
        }
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView(bookmarks: .constant([
            QuranVerse(
                surahNo: 114,
                ayahNo: 5,
                surahName: "سورة الناس",
                ayahArabic: "ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ",
                emotion: "anger",
                ayahEnglish: "who whispers into the hearts of humankind—",
                surahMeaning: "The Mankind",
                surahEnglish: "An-Nas"
            ),
            QuranVerse(
                surahNo: 1,
                ayahNo: 1,
                surahName: "سورة الفاتحة",
                ayahArabic: "بِسْمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
                emotion: "joy",
                ayahEnglish: "In the name of Allah, the Most Gracious, the Most Merciful.",
                surahMeaning: "The Opening",
                surahEnglish: "Al-Fatihah"
            )
        ]))
    }
}
