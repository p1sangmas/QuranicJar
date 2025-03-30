//
//  AbaoutView.swift
//  QuranicJar
//
//  Created by Fakhrul Fauzi on 28/03/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Quranic Jar")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Quranic Jar is an app designed to provide Quranic verses based on your emotions using Natural Language Processing (NLP). It helps you connect with the Quran in a meaningful way by offering verses that resonate with your feelings.")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Features:")
                        .font(.headline)
                        .padding(.top)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("• Emotion-based verse recommendations")
                        Text("• Bookmark your favorite verses")
                        Text("• Search for verses by keywords or emotions")
                        Text("• Dark mode support")
                    }
                    .font(.body)
                    .foregroundColor(.primary)

                    Spacer()
                }
                .padding()
            }
            Spacer()
            Text("Developed with ❤️ by Fakhrul Fauzi")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
