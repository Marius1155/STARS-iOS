//
//  ProfilePreview.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 22.03.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfilePreview: View {
    /* 
    
    var profileID: String
    @State private var profile: Profile = Profile.empty()
    
    @AppStorage("userID") var userID: String = ""*/
    
    var body: some View {
        /*NavigationLink {
            ProfileView(id: profileID)
                .accentColor(Color(hex: profile.customSecondaryColor) ?? .accentColor)
        } label : {
            HStack {
                ProfilePictureView(pictureURL: profile.profilePicture, diameter: 64)
                
                VStack {
                    HStack {
                        ProfileNameAndPronounsView(name: profile.name, pronouns: profile.pronouns)
                          
                        
                        Spacer()
                    }
                    HStack {
                        ProfileTagView(tag: profile.tag)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                FollowButtonView(userToFollowID: profileID)
            }
            .padding(.horizontal)
            .onAppear {
                dataManager.fetchProfileWithGivenUserID(userID: profileID) { fetchedProfile in
                    if let fetchedProfile = fetchedProfile {
                        profile = fetchedProfile
                    }
                }
            }
        }*/
    }
}

#Preview {
    /*ProfilePreview(profileID: "PuAHWOG22FdfzyBqgxb69Xxmbat2")
         
        .onAppear {
            UserDefaults.standard.set("AX7ztju3UBWYsTXCXfFsYFCcJSl2", forKey: "userID")
        }*/
}
