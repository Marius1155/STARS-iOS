//
//  NewProjectReviewView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.08.2024.
//

import SwiftUI

struct NewProjectReviewView: View {
    /*@Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("userID") var userID: String = ""
    
    @Binding var project: Project
    @Binding var showErrorPostingNewReviewAlert: Bool
    
    var onReviewAdded: (() -> Void)?
    
    @State private var starcount: Double = 0.0
    @State private var text: String = ""
    @State private var numberOfSubreviews: Int = 0
    @State private var subreviewsTopics: [String] = []
    @State private var subreviewsTexts: [String] = []
    @State private var subreviewsStars: [Double] = []
    @State private var showAlert: Bool = false*/

    var body: some View {
        /*NavigationView {
            VStack {
                List {
                    VStack(alignment: .leading) {
                        HStack(spacing: 5) {
                            Image(systemName: "opticaldisc.fill")
                            
                            Text(project.title)
                                .bold()
                        }
                        
                        HStack {
                            Image(systemName: project.artist.count == 1 ? "person.fill" : "person.2.fill")
                            
                            ProjectArtistNameView(project: project)
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
                                .padding(.top)
                            
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
                            //withAnimation {
                                numberOfSubreviews += 1
                                subreviewsTopics.append("")
                                subreviewsTexts.append("")
                                subreviewsStars.append(0)
                            //}
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
                        if starcount == 0 || text == "" || subreviewsStars.contains(where: { $0 == 0 }) || subreviewsTopics.contains(where: { $0 == "" }) {
                            showAlert.toggle()
                        }
                        
                        else {
                            DispatchQueue.main.async {
                                addReview()
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
        }*/
    }

    /*func addReview() {
        DispatchQueue.main.async {
            dataManager.addProjectReview(date: Date(), project: project.id!, stars: starcount, text: text, subreviewsStars: subreviewsStars, subreviewsTopics: subreviewsTopics, subreviewsTexts: subreviewsTexts, user: userID) { itWorked, reviewID in
                if !itWorked {
                    showErrorPostingNewReviewAlert = true
                }
                else {
                    if let reviewID = reviewID {
                        dataManager.makeReviewPartOfProject(review: reviewID, starcount: starcount, oldStarAverage: project.starAverage, oldReviewsCount: project.reviewsCount, project: project.id!) { itWorked in
                            if !itWorked {
                                showErrorPostingNewReviewAlert = true
                            }
                            
                            else {
                                onReviewAdded?()
                            }
                        }
                    }
                }
            }
        }
    }*/
}

#Preview {
    /*@Previewable @EnvironmentObject var dataManager: DataManager
    @Previewable @State var b: Bool = false
    NewProjectReviewView(project: $dataManager.projects.first!, showErrorPostingNewReviewAlert: $b)
        .environmentObject(DataManager())*/
}
