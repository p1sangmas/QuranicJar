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

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Quranic Jar!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()

            Text("Please enter your name to get started:")
                .font(.body)
                .multilineTextAlignment(.center)

            TextField("Enter your name", text: $nameInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                userName = nameInput
            }) {
                Text("Continue")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(nameInput.isEmpty)
        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
