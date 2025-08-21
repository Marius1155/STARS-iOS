//
//  FollowersView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 24.03.2025.
//

import SwiftUI

struct FollowersView: View {
    var userID: String
    @State var view: Int
    
    var body: some View {
        Picker("", selection: $view) {
            Text("Followers").tag(1)
            Text("Following").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        
        ScrollView {
            
        }
        
    }
}

#Preview {
    FollowersView(userID: "AX7ztju3UBWYsTXCXfFsYFCcJSl2", view: 1)
}
