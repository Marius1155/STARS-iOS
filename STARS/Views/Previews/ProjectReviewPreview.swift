//
//  ProjectReviewPreview.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.03.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProjectReviewPreview: View {
    /*@EnvironmentObject var dataManager: DataManager
    @State private var image: String = ""
    
    @State private var project: Project? = nil
    @State private var review: ProjectReview? = nil
    
    var reviewID: String*/
    
    var body: some View {
        /*VStack {
            if let review = review, let project = project {
                if image != "" , let url = URL(string: image) {
                    WebImage(url: url)
                        .resizable()
                        .frame(width: 148, height: 148)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 2)
                } else {
                    ProgressView()
                        .frame(width: 148, height: 148)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Text(project.title)
                    .bold()
                    .font(.caption)
                    .lineLimit(1)
                    .frame(width: 148)
                    .truncationMode(.tail)
                    .padding(.bottom, -1)
                
                ProjectArtistNameView(project: project)
                    .lineLimit(1)
                    .frame(width: 148)
                    .truncationMode(.tail)
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Group {
                    Text(String(format: "%.1f", review.stars))
                    + Text(Image(systemName: "star.fill"))
                        .foregroundColor(.yellow)
                }
                
                Text(review.text)
                    .lineLimit(4)
                    .truncationMode(.tail)
                    .frame(width: 148)
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                dataManager.fetchProjectReviewWithGivenID(withID: reviewID) { fetchedReview in
                    if let fetchedReview = fetchedReview {
                        review = fetchedReview
                        
                        dataManager.fetchProjectWithGivenID(projectID: review!.project) { fetchedProject in
                            if let fetchedProject = fetchedProject {
                                project = fetchedProject
                                
                                dataManager.fetchProjectCover(coverID: project!.cover[0]) { projectCover in
                                    if let projectCover = projectCover {
                                        print("Fetched project cover: \(projectCover)")
                                        image = projectCover.image
                                    } else {
                                        print("Failed to fetch project cover.")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }*/
    }
}

#Preview {
    //ProjectReviewPreview(reviewID: "4hT4zYwTrRVe61uB3nmx")
}
