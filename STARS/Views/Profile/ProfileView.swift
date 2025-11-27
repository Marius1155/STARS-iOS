//
//  ProfileView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI
import SDWebImageSwiftUI
import STARSAPI

struct ProfileView: View {
     
    @AppStorage("userID") var userID: String = ""
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    @AppStorage("userHasPremium") var userHasPremium: Bool = false
    @AppStorage("userIsStaff") var userIsStaff: Bool = false
    @AppStorage("userIsSuperuser") var userIsSuperuser: Bool = false
    @AppStorage("userUsername") var userUsername: String = ""
    @AppStorage("userDisplayName") var userDisplayName: String = ""
    @AppStorage("userPronouns") var userPronouns: String = ""
    @AppStorage("userCustomSecondaryColor") var userCustomSecondaryColor: String = ""
    
    var id: String
    
    /*
    @State private var profile: Profile = Profile.empty()
    
    @State private var showEditableProfileView: Bool = false
    
    @State private var navTitleColor: Color = .clear
    
    @State private var heightOfThingyBelowBanner: CGFloat = 100
    
    @State private var thingyBelowBannerIsExpanded: Bool = false
    
    @State private var showEditProfileSheet: Bool = false*/
    
    var body: some View {
        ScrollView {
            VStack {
                if userID == id {
                    Text("Hello, \(userDisplayName)! Your username is \(userUsername), your pronouns are \(userPronouns) and your accent color is \(userCustomSecondaryColor).")
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            if userID == id {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        signOut()
                    }
                }
            }
        }
        .onAppear {
            if userID != id {
                NotificationCenter.default.post(name: .hideTabBar, object: nil)
            }
            
            else {
                NotificationCenter.default.post(name: .showTabBar, object: nil)
                DataManager.shared.shouldShowTabBar = true
            }
        }
        /*ScrollView {
            VStack {
                if profile.id != "" {
                    if profile.hasPremium {
                        VStack(spacing: 0) {
                            ZStack {
                                if profile.bannerPicture != ""{
                                    WebImage(url: URL(string: profile.bannerPicture))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 300)
                                        .clipped()
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 300)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.gray)
                                        )
                                }
                                
                                HStack(spacing: 0) {
                                    Spacer()
                                    
                                    NavigationLink {
                                        FollowersView(userID: id, view: 1)
                                    } label: {
                                        VStack(spacing: 0) {
                                            Text(profile.formattedFollowersCount())
                                                .bold()
                                                .font(.subheadline)
                                                .padding(.trailing, 2)
                                            Text("Followers")
                                                .font(.caption)
                                                .fontWeight(.regular)
                                                .padding(.leading, 2)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background {
                                            RoundedRectangle(cornerRadius: 50)
                                                .foregroundStyle(Color.white)
                                                .shadow(radius: 5)
                                        }
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .foregroundStyle(Color.black)
                                    
                                    Spacer()
                                    
                                    Spacer()
                                        .frame(width: 130)
                                    
                                    Spacer()
                                    
                                    NavigationLink {
                                        FollowersView(userID: id, view: 2)
                                    } label: {
                                        VStack(spacing: 0) {
                                            Text(profile.formattedFollowingCount())
                                                .bold()
                                                .font(.subheadline)
                                                .padding(.trailing, 2)
                                            Text("Following")
                                                .font(.caption)
                                                .fontWeight(.regular)
                                                .padding(.leading, 2)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 7)
                                        .background {
                                            RoundedRectangle(cornerRadius: 50)
                                                .foregroundStyle(Color.white)
                                                .shadow(radius: 5)
                                        }
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .foregroundStyle(Color.black)
                                    
                                    Spacer()
                                }
                                .background {
                                    Rectangle()
                                        .frame(height: 65)
                                        .foregroundStyle(Color.accentColor)
                                        .shadow(radius: 5)
                                }
                                /*.background {
                                    Rectangle()
                                        .frame(height: 50)
                                        .foregroundStyle(Color.white)
                                        .shadow(radius: 5)
                                        
                                }*/
                                
                                
                                HStack {
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(Color.accentColor)
                                            .frame(height: 140)
                                            .shadow(radius: 5)
                                            
                                        Circle()
                                            .foregroundStyle(Color.white)
                                            .frame(height: 115)
                                            .shadow(radius: 5)
                                        
                                        ProfilePictureView(pictureURL: profile.profilePicture, diameter: 100)
                                            .shadow(radius: 5)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(height: heightOfThingyBelowBanner)
                                    .foregroundStyle(Color.accentColor)
                                    .offset(y: -30)
                                    .shadow(radius: 5)
                                
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        if !thingyBelowBannerIsExpanded {
                                            withAnimation {
                                                thingyBelowBannerIsExpanded = true
                                                heightOfThingyBelowBanner = 300
                                            }
                                        }
                                        
                                        else {
                                            withAnimation {
                                                thingyBelowBannerIsExpanded = false
                                                heightOfThingyBelowBanner = 100
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "chevron.down.circle.fill")
                                            //.symbolVariant(heightOfThingyBelowBanner == 100 ? .none : .fill)
                                            .foregroundStyle(Color.black)
                                            .font(.largeTitle)
                                            .padding(10)
                                            .background {
                                                Circle()
                                                    .foregroundStyle(Color.white)
                                                    .frame(width: 60, height: 60)
                                            }
                                            .rotationEffect(.degrees(thingyBelowBannerIsExpanded ? -180 : 0))
                                    }
                                    .offset(y: -30+(-heightOfThingyBelowBanner+100)/2)
                                    
                                    Spacer()
                                    
                                    VStack {
                                        ProfileNameAndPronounsView(name: profile.name, pronouns: profile.pronouns)
                                            .foregroundStyle(Color.black)
                                        
                                        ProfileTagView(tag: profile.tag)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.top, -50+(-heightOfThingyBelowBanner+100)/2)
                                    .background {
                                        RoundedRectangle(cornerRadius: 50)
                                            .frame(height: 75)
                                            .foregroundStyle(Color.white)
                                            .offset(y: -30+(-heightOfThingyBelowBanner+100)/2)
                                            .shadow(radius: 5)
                                    }
                                    
                                    Spacer()
                                    
                                    if id == userID {
                                        Button {
                                            showEditProfileSheet = true
                                        } label: {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundStyle(Color.black)
                                                .font(.largeTitle)
                                                .padding(10)
                                                .background {
                                                    Circle()
                                                        .foregroundStyle(Color.white)
                                                        .frame(width: 60, height: 60)
                                                }
                                        }
                                        .offset(y: -30+(-heightOfThingyBelowBanner+100)/2)
                                        
                                    }
                                    else {
                                        RoundFollowButtonView(userToFollowID: id)
                                            .offset(y: -30+(-heightOfThingyBelowBanner+100)/2)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                    }
                    
                    else {
                        ZStack {
                            HStack(spacing: 0) {
                                Spacer()
                                
                                NavigationLink {
                                    FollowersView(userID: id, view: 1)
                                } label: {
                                    HStack(spacing: 0) {
                                        Text("\(profile.followersCount)")
                                            .bold()
                                            .padding(.trailing, 2)
                                        Text("Followers")
                                            .fontWeight(.regular)
                                            .padding(.leading, 2)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.white)
                                            .shadow(radius: 5)
                                    }
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .foregroundStyle(Color.black)
                                
                                Spacer()
                                
                                Spacer()
                                    .frame(width: 125)
                                
                                Spacer()
                                
                                NavigationLink {
                                    FollowersView(userID: id, view: 2)
                                } label: {
                                    HStack(spacing: 0) {
                                        Text("\(profile.followingCount)")
                                            .bold()
                                            .padding(.trailing, 2)
                                        Text("Following")
                                            .fontWeight(.regular)
                                            .padding(.leading, 2)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.white)
                                            .shadow(radius: 5)
                                    }
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .foregroundStyle(Color.black)
                                
                                Spacer()
                            }
                            .font(.subheadline)
                            .background {
                                Rectangle()
                                    .frame(height: 50)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .padding(.top, 100)
                            
                            HStack {
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .foregroundStyle(Color.accentColor)
                                        .frame(height: 125)
                                        .shadow(radius: 5)
                                    
                                    ProfilePictureView(pictureURL: profile.profilePicture, diameter: 100)
                                        .shadow(radius: 5)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // un pic bataie de joc ngl
                    let projectReviewsIDs = ["xiB3cSVwPXQnA1R42PFc", "tGBbzdcuv2esS8GHdGYT", "ZaFTWV7yYKAp5BM5Ivfk"]
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(projectReviewsIDs, id: \.self) { reviewID in
                                ProjectReviewPreview(reviewID: reviewID)
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                else {
                    Text("Loading profile ...")
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    dataManager.fetchProfileWithGivenUserID(userID: id) { profile in
                        if let profile = profile {
                            self.profile = profile
                        }
                    }
                }
            }
        }
        //.ignoresSafeArea(edges: .top)
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(profile.name)
                    .font(.headline)
                    .foregroundColor(navTitleColor)  // Change to your desired color
            }
            
            if userID == id {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    userIsLoggedIn = false
                                    userID = ""
                                }
                            }
                        } catch let error {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showEditProfileSheet) {
            EditableProfileView(profile: $profile)
        }*/
    }
    
    func signOut() {
            // Call the new logout mutation
            Network.shared.apollo.perform(mutation: STARSAPI.LogoutMutation()) { result in
                // We handle the result, but the main goal is to clear local data regardless
                switch result {
                case .success(let graphQLResult):
                    if let message = graphQLResult.data?.logoutUser.message {
                        print("Server response: \(message)")
                    }
                    if let errors = graphQLResult.errors {
                        print("GraphQL Error: \(errors)")
                    }
                case .failure(let error):
                    print("Network Error: \(error)")
                }
                
                // This is the most important part for the app
                // Clear all user data and session cookies
                clearLocalUserData()
            }
        }
        
        func clearLocalUserData() {
            // Clear all your user-specific @AppStorage values
            userID = ""
            // ... clear userTag, userEmail, etc.
            
            // Remove the session cookie from the device's storage
            // This is crucial for a complete logout.
            if let cookies = HTTPCookieStorage.shared.cookies {
                for cookie in cookies {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                }
            }
            
            // This will trigger your app to navigate back to the login screen
            userIsLoggedIn = false
        }
}

#Preview {
    /*NavigationView{
        ProfileView(id: "AX7ztju3UBWYsTXCXfFsYFCcJSl2")
             
            .onAppear {
                DispatchQueue.main.async {
                    if let user = Auth.auth().currentUser {
                        print("User is logged in: \(user.uid)")
                    } else {
                        Task {
                            do {
                                let result = try await Auth.auth().signIn(withEmail: "mariusgabrielbudai@gmail.com", password: "password")
                                print("Signed in as: \(result.user.uid)")
                            } catch {
                                print("Error signing in: \(error.localizedDescription)")
                            }
                        }
                    }
                    UserDefaults.standard.set("AX7ztju3UBWYsTXCXfFsYFCcJSl2", forKey: "userID")
                    UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
                }
            }
    }
    .tint(Color(hex: "#bee5f4"))*/
}
