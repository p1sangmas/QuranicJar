//
//  BookmarkView.swift
//  QuranJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI

struct BookmarkView: View {
    @Binding var bookmarks: [String] // Pass bookmarks as a binding

    var body: some View {
        NavigationView {
            List {
                if bookmarks.isEmpty {
                    Text("No bookmarks yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(bookmarks, id: \.self) { verse in
                        Text(verse)
                            .font(.body)
                            .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteBookmark)
                }
            }
            .navigationTitle("Bookmarks")
            .toolbar {
                EditButton()
            }
        }
    }

    private func deleteBookmark(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView(bookmarks: .constant(["Sample Verse 1", "Sample Verse 2"]))
    }
}
