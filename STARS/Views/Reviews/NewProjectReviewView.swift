//
//  NewProjectReviewView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import SwiftUI
import STARSAPI

struct NewProjectReviewView: View {
    @Environment(\.dismiss) private var dismiss
    // 
    @AppStorage("userID") var userID: String = ""
    
    var projectID: String
    var projectTitle: String
    var projectArtistsIDs: [String]
  
    @Binding var showErrorPostingNewReviewAlert: Bool
    
    var onReviewAdded: (() -> Void)?
    
    @State private var title: String = ""
    @State private var starcount: Double = 0.0
    @State private var text: String = ""
    @State private var numberOfSubreviews: Int = 0
    @State private var subreviewsTopics: [String] = []
    @State private var subreviewsTexts: [String] = []
    @State private var subreviewsStars: [Double] = []
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    VStack(alignment: .leading) {
                        HStack(spacing: 5) {
                            Image(systemName: "opticaldisc.fill")
                            
                            Text(projectTitle)
                                .bold()
                        }
                        
                        HStack {
                            Image(systemName: projectArtistsIDs.count == 1 ? "person.fill" : "person.2.fill")
                            
                            ProjectArtistNameView(artistsIDs: projectArtistsIDs)
                        }
                    }
                    .listRowSeparator(.hidden)
 
                    VStack(alignment: .center) {
                        HStack {
                            StarPickerView(rating: $starcount)
                            Text(String(format: "%.1f", starcount))
                                .bold()
                        }
        
                        VStack(alignment: .center) {
                            Text("Write your review")
                                .bold()
                                .font(.headline)
                                .padding(.vertical)
                            
                            TextField("Title", text: $title)
                                .bold()
                            
                            TextEditor(text: $text)
                                .frame(height: 200)
                                .padding(10)
                                .background(Color(.white))
                                .cornerRadius(10)
                        }
                        
                        if numberOfSubreviews > 0 {
                            VStack(alignment: .center) {
                                Text("Subreviews")
                                    .font(.headline)
                                    .bold()
                                    .padding(.top)
                                
                                ForEach(0..<numberOfSubreviews, id: \.self) { index in
                                    VStack(alignment: .center) {
                                        Divider()
                                        
                                        HStack {
                                            Button {
                                                numberOfSubreviews -= 1
                                                subreviewsTopics.remove(at: index)
                                                subreviewsTexts.remove(at: index)
                                                subreviewsStars.remove(at: index)
                                            } label: {
                                                Image(systemName: "minus.square.fill")
                                                    .foregroundColor(.black)
                                            }
                                            .bold()
                                            .buttonStyle(BorderlessButtonStyle())
                                            
                                            TextField("Topic (max. 30 characters)", text: $subreviewsTopics[index])
                                                .onChange(of: subreviewsTopics[index]) { _, newValue in
                                                    if newValue.count > 30 {
                                                        subreviewsTopics[index] = String(newValue.prefix(30))
                                                    }
                                                }
                                                .padding(8)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(10)
                                        }
                                        
                                        HStack {
                                            StarPickerView(rating: $subreviewsStars[index])
                                            Text(String(format: "%.1f", subreviewsStars[index]))
                                                .bold()
                                        }
                                            
                                        TextEditor(text: $subreviewsTexts[index])
                                            .frame(height: 100)
                                            .background(Color(.white))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                        
                        Button {
                            withAnimation {
                                numberOfSubreviews += 1
                                subreviewsTopics.append("")
                                subreviewsTexts.append("")
                                subreviewsStars.append(0)
                            }
                        } label: {
                            Label("Add subreview", systemImage: "plus.app.fill")
                                .foregroundColor(.black)
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.accentColor)
                                }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .listRowSeparator(.hidden)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .shadow(radius: 5)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("New Project Review")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if title.isEmpty || starcount == 0 || text == "" || subreviewsStars.contains(where: { $0 == 0 }) || subreviewsTopics.contains(where: { $0 == "" }) {
                            showAlert.toggle()
                        }
                        
                        else {
                            DispatchQueue.main.async {
                                addReviewToProject()
                            }
                            dismiss()
                        }
                    }
                    .alert("Not enough information!", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Each starcount has to be at least 0.5 and the main review and the topics of the subreviews can't be empty.")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    func addReviewToProject() {
        DispatchQueue.main.async {
            var subreviews: [STARSAPI.SubReviewDataInput] = []
            
            for i in 0..<numberOfSubreviews {
                if subreviewsTexts[i] != "" {
                    subreviews.append(STARSAPI.SubReviewDataInput(topic: subreviewsTopics[i], stars: subreviewsStars[i], text: .some(subreviewsTexts[i])))
                }
                
                else {
                    subreviews[i] = STARSAPI.SubReviewDataInput(topic: subreviewsTopics[i], stars: subreviewsStars[i])
                }
            }
            
            let data: STARSAPI.ReviewDataInput
            
            if numberOfSubreviews != 0 {
                data = STARSAPI.ReviewDataInput(stars: starcount, title: title, text: .some(text), subreviews: .some(subreviews))
            }
            
            else {
                data = STARSAPI.ReviewDataInput(stars: starcount, title: title, text: .some(text))
            }
            
            Network.shared.apollo.perform(mutation: STARSAPI.AddReviewToProjectMutation(projectId: projectID, data: data)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors {
                        print("Error sending message: \(errors)")
                    }
                    else {
                        onReviewAdded?()
                    }
                    
                case .failure(let error):
                    print("Network error sending message: \(error)")
                }
            }
        }
    }
}

#Preview {
    //NewProjectReviewView(project: $dataManager.projects.first!, showErrorPostingNewReviewAlert: $b)
}
