//
//  WelcomeView.swift
//  QuranJar
//
//  Created by Fakhrul Fauzi on 27/03/2025.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("userName") private var userName: String = ""
    @State private var nameInput: String = ""
    @State private var navigateToContentView: Bool = false

    var body: some View {
        ZStack {
            if !navigateToContentView {
                // Welcome Screen
                VStack(spacing: 20) {
                    Spacer()

                    Label {
                        Text("")
                    } icon: {
                        Image(systemName: "character.book.closed.fill.ar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    // Header Text
                    TypewriterText(text: "Welcome to Quranic Jar!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    // Subtitle
                    Text("Please enter your name to get started:")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // TextField for Name Input
                    TextField("Enter your name", text: $nameInput)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .frame(maxWidth: 300)

                    // Continue Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            navigateToContentView = true
                        }
                        userName = nameInput
                    }) {
                        Label("Continue", systemImage: "arrow.right.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(nameInput.isEmpty)
                    .padding(.horizontal)
                    .frame(maxWidth: 300)

                    Spacer()
                }
                .padding()
                .transition(.opacity) // Fade-out transition
            } else {
                // ContentView
                ContentView()
                    .transition(.opacity) // Fade-in transition
            }
        }
        .animation(.easeInOut(duration: 0.5), value: navigateToContentView)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
