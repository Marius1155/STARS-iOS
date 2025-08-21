//
//  AddMusicVideoTestView.swift
//  STARS
//
//  Created by Marius Gabriel Budai on 16.08.2025.
//

import SwiftUI
import Apollo
import STARSAPI

struct AddMusicVideoTestView: View {
    @State private var youtubeURL: String = ""
    @State private var songID: String = ""
    @State private var isSending = false
    @State private var message: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("YouTube URL", text: $youtubeURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            TextField("Song ID", text: $songID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: addMusicVideo) {
                if isSending {
                    ProgressView()
                } else {
                    Text("Add Music Video")
                        .bold()
                }
            }
            .disabled(isSending || youtubeURL.isEmpty || songID.isEmpty)
            
            Text(message)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .padding(.top)
        }
        .padding()
    }
    
    func addMusicVideo() {
        guard !youtubeURL.isEmpty, !songID.isEmpty else { return }
        isSending = true
        message = ""
        
        let input = STARSAPI.MusicVideoInput(youtubeUrl: youtubeURL, songIds: [songID])
        
        Network.shared.apollo.perform(mutation: STARSAPI.AddMusicVideoMutation(data: input)) { result in
            DispatchQueue.main.async {
                isSending = false
                switch result {
                case .success(let graphQLResult):
                    if let mv = graphQLResult.data?.addMusicVideo {
                        message = "Added music video: \(mv.title)"
                    } else if let errors = graphQLResult.errors {
                        message = errors.map { $0.localizedDescription }.joined(separator: "\n")
                    }
                case .failure(let error):
                    message = "Network error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    AddMusicVideoTestView()
}
