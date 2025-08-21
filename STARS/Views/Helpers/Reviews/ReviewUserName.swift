//
//  ReviewUserName.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 28.12.2024.
//

import SwiftUI

struct ReviewUserName: View {
    var user: Profile
    
    var body: some View {
        HStack{
            Image(systemName: "at")
            Text(user.tag)
        }
    }
}

#Preview {
    ReviewUserName(user: Profile(id: "", tag: "", hasPremium: false, bannerPicture: "", profilePicture: "", email: "", firstName: "", lastName: "", birthdate: Date(), bio: "", pronouns: "", isAdmin: false, projectReviews: [], projectCoverReviews: [], songReviews: [], musicVideoReviews: [], podcastReviews: [], movieReviews: [], seriesReviews: [], outfitReviews: []))
}
