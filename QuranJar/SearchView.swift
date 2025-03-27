//
//  SearchView.swift
//  QuranicJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI
import Foundation

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var results: [QuranVerse] = []
    @State private var allVerses: [QuranVerse] = []

    var body: some View {
          NavigationView {
              VStack(spacing: 0){
                  SearchBar(text: $searchText, onSearch: {
                      performSearch()
                      UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                  })
                  List(results) { verse in
                      VStack(alignment: .leading, spacing: 5) {
                          Text("\(verse.surahName) (\(verse.surahNo):\(verse.ayahNo))")
                              .font(.headline)
                          Text(verse.ayahArabic)
                              .font(.body)
                              .foregroundColor(.primary)
                          Text(verse.ayahEnglish)
                              .font(.subheadline)
                              .foregroundColor(.secondary)
                      }
                  }
                  .listStyle(PlainListStyle())
              }
              .navigationTitle("Search")
              .onAppear {
                  allVerses = loadQuranVerses(from: "quran_emotions_cleaned")
              }
          }
          Spacer()
      }

    private func performSearch() {
        results = allVerses.filter { verse in
            verse.surahName.localizedCaseInsensitiveContains(searchText) ||
            verse.ayahArabic.localizedCaseInsensitiveContains(searchText) ||
            verse.ayahEnglish.localizedCaseInsensitiveContains(searchText) ||
            verse.emotion.localizedCaseInsensitiveContains(searchText)
        }
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

struct QuranVerse: Identifiable {
    let id = UUID()
    let surahNo: Int
    let ayahNo: Int
    let surahName: String
    let ayahArabic: String
    let emotion: String
    let ayahEnglish: String
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
            if columns.count == 6 {
                if let surahNo = Int(columns[0]), let ayahNo = Int(columns[1]) {
                    let verse = QuranVerse(
                        surahNo: surahNo,
                        ayahNo: ayahNo,
                        surahName: columns[2],
                        ayahArabic: columns[3],
                        emotion: columns[4],
                        ayahEnglish: columns[5]
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
