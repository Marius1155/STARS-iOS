//
//  EditableProfileView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 24.03.2025.
//

import SwiftUI
import SDWebImageSwiftUI
import PhotosUI

struct EditableProfileView: View {
    /* 
    
    @Binding var profile: Profile
    
    @AppStorage("userID") var userID: String = ""
    
    @State private var editableBio: String = ""*/
    
    var body: some View {
        /*VStack {
            if profile.id != "" {
                if profile.hasPremium {
                    BannerPicturePickerView(profile: $profile)
                        .scaledToFill()
                        .frame(height: 100)
                }
                
                HStack {
                    ProfilePicturePickerView(profile: $profile)
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    Spacer()
                }
                
                TextField("Username", text: .constant(profile.tag))
                    .font(.headline)
                    .padding()
                
                TextField("Bio", text: $editableBio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            else {
                Text("Loading profile...")
            }
        }*/
    }
}

struct ProfilePicturePickerView: View {
    /* 
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    @AppStorage("userID") var userID: String = ""
    
    @Binding var profile: Profile*/
    
    var body: some View {
        /*VStack {
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                if profile.profilePicture != "" {
                    WebImage(url: URL(string: profile.profilePicture))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                Task {
                    if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                dataManager.updateProfileImage(userID: userID, image: uiImage, isBanner: false) { image in
                                    if let image = image {
                                        profile.profilePicture = image
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

struct BannerPicturePickerView: View {
    /* 
    
    @State private var image: String? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    
    @AppStorage("userID") var userID: String = ""
    
    @Binding var profile: Profile*/
    
    var body: some View {
        /*VStack {
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                if profile.bannerPicture != ""{
                    WebImage(url: URL(string: profile.bannerPicture))
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        )
                }
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                Task {
                    if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                dataManager.updateProfileImage(userID: userID, image: uiImage, isBanner: true) { image in
                                    if let image = image {
                                        profile.bannerPicture = image
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


/*#Preview {
    EditableProfileView(id: "AX7ztju3UBWYsTXCXfFsYFCcJSl2")
         
        .onAppear {
            UserDefaults.standard.set("AX7ztju3UBWYsTXCXfFsYFCcJSl2", forKey: "userID")
        }
}*/
