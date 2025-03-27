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

    var body: some View {
        VStack(spacing: 10) {
            Text("Assalamualaikum, \(userName)!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()

            Text("How are you feeling today?")
                .font(.body)
                .padding()
                .multilineTextAlignment(.center)

            TextField("Enter what is your feeling here", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                predictEmotion()
            }) {
                Text("Predict Emotion")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)

            if isLoading {
                ProgressView("Predicting...")
            }

            if !predictedEmotion.isEmpty {
                Text("Predicted Emotion: \(predictedEmotion)")
                    .font(.headline)
                    .padding()
            }

            if !quranicVerse.isEmpty {
                Text("Quranic Verse: \(quranicVerse)")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
