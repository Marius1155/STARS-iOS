//
//  SongReviewsView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 23.11.2024.
//

import SwiftUI

struct SongReviewsView: View {
    /*@Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    var song: Song
    @State private var reviews: [SongReview] = []
    @State private var showSubreviews: [Bool] = [false]
    @State private var showButton: [Bool] = [true]
    @State private var showNewReviewView: Bool = false*/
    
    var body: some View {        
        /*VStack {
            List {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                            .frame(width: 3)
                        
                        Image(systemName: "music.note")
                        
                        SongTitleView(song: song)
                    }
                    
                    HStack {
                        Image(systemName: song.artist.count == 1 ? "person.fill" : "person.2.fill")
                        
                        SongArtistNameView(song: song)
                    }
                    
                    HStack{
                        Spacer()
                        Text("•")
                            .bold()
                        Text("\(reviews.count) reviews")
                            .italic()
                        Text("•")
                            .bold()
                        Spacer()
                    }
                    .background{
                        RibbonShape()
                            .fill(Color.accentColor)
                            .frame(height: 30)
                        //.shadow(radius: 2)
                    }
                    .padding(.top, 5)
                }
                
                ForEach(Array(reviews.enumerated()), id: \.element.id) {index, review in
                    VStack(alignment: .leading) {
                        HStack {
                            StarView(stars: review.stars)
                                .bold()
                            
                            Text(String(format: "%.1f", review.stars))
                                .bold()
                            
                            Spacer()
                            
                            Text("by:")
                                .italic()
                            
                            Text(review.user)
                                .bold()
                        }
                        
                        Divider()
                        
                        Text(review.text)
                        
                        if showSubreviews[index] {
                            VStack(alignment: .leading) {
                                ForEach(0..<review.subreviewsTopics.count, id: \.self) { index in
                                    Divider()
                                    
                                    HStack {
                                        Text(review.subreviewsTopics[index])
                                            .bold()
                                        
                                        StarView(stars: review.subreviewsStars[index])
                                            .bold()
                                        
                                        Text(String(format: "%.1f", review.subreviewsStars[index]))
                                            .bold()
                                    }
                                    
                                    if review.subreviewsTexts[index] != "" {
                                        Text(review.subreviewsTexts[index])
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        
                        HStack{
                            if !review.subreviewsTopics.isEmpty{
                                Button {
                                    //withAnimation {
                                    showButton[index].toggle()
                                    showSubreviews[index].toggle()
                                    //}
                                } label: {
                                    Text(showButton[index] ? "Show subreviews" : "Hide subreviews")
                                }
                                .font(.footnote)
                                .buttonStyle(BorderlessButtonStyle())
                                
                            }
                            
                            Spacer()
                            
                            Text(review.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote)
                        }
                        .padding(.top, 3)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .shadow(radius: 5)
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            DispatchQueue.main.async {
                dataManager.fetchASongsReviews(withIDs: song.reviews) { fetchedReviews in
                    reviews = fetchedReviews
                    
                    showSubreviews = Array(repeating: false, count: reviews.count)
                    showButton = Array(repeating: true, count: reviews.count)
                }
            }
        }
        .navigationTitle("Song reviews")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button() {
                    showNewReviewView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .bold()
                }
            }
        }
        .sheet(isPresented: $showNewReviewView, content: {
            NewSongReviewView(song: song)
                .presentationDetents([.large])
                .interactiveDismissDisabled()
        })*/
    }
}

#Preview {
    /*@Previewable @EnvironmentObject var dataManager: DataManager
    SongReviewsView(song: dataManager.songs.first!)
        .environmentObject(DataManager())*/
}
