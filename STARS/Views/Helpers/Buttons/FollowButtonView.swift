//
//  FollowButtonView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 24.03.2025.
//

import SwiftUI

struct FollowButtonView: View {
    /* 
    
    var userToFollowID: String
    
    @AppStorage("userID") var userID: String = ""
    
    @State var isFollowingTheUser: Bool = false*/
    
    var body: some View {
        /*Button {
            if !isFollowingTheUser {
                dataManager.followUser(currentUserID: userID, targetUserID: userToFollowID) { error in
                    if error == nil {
                        isFollowingTheUser.toggle()
                    }
                }
            }
            
            else {
                dataManager.unfollowUser(currentUserID: userID, targetUserID: userToFollowID) { error in
                    if error == nil {
                        isFollowingTheUser.toggle()
                    }
                }
            }
            
        } label: {
            if !isFollowingTheUser {
                Text("Follow")
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.white)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 30)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.accentColor)
                    }
            }
            
            else {
                Text("Following")
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.primary)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 1)
                    }
            }
        }
        .onAppear {
            dataManager.isFollowing(currentUserID: userID, targetUserID: userToFollowID) { isFollowing in
                isFollowingTheUser = isFollowing
            }
        }*/
    }
}

#Preview {
    /*FollowButtonView(userToFollowID: "PuAHWOG22FdfzyBqgxb69Xxmbat2")
         
        .onAppear {
            UserDefaults.standard.set("AX7ztju3UBWYsTXCXfFsYFCcJSl2", forKey: "userID")
        }*/
}
