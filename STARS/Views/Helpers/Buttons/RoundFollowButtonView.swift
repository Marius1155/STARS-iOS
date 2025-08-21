//
//  RoundFollowButtonView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.03.2025.
//

import SwiftUI

struct RoundFollowButtonView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    var userToFollowID: String
    
    @AppStorage("userID") var userID: String = ""
    
    @State var isFollowingTheUser: Bool = false*/
    
    var body: some View {
        /*Button {
            if !isFollowingTheUser {
                dataManager.followUser(currentUserID: userID, targetUserID: userToFollowID) { error in
                    if error == nil {
                        withAnimation {
                            isFollowingTheUser.toggle()
                        }
                    }
                }
            }
            
            else {
                dataManager.unfollowUser(currentUserID: userID, targetUserID: userToFollowID) { error in
                    if error == nil {
                        withAnimation {
                            isFollowingTheUser.toggle()
                        }
                    }
                }
            }
            
        } label: {
            Image(systemName: isFollowingTheUser ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.plus")
                .foregroundStyle(Color.black)
                .font(.largeTitle)
                .padding(10)
                .background {
                    Circle()
                        .foregroundStyle(Color.white)
                        .frame(width: 60, height: 60)
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
    //RoundFollowButtonView(userToFollowID: "AX7ztju3UBWYsTXCXfFsYFCcJSl2")
}
