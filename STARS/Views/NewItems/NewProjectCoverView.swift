//
//  NewProjectCoverView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 12.11.2024.
//

import SwiftUI

struct NewProjectCoverView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    @State private var image = ""
    
    @State private var showProjectCoverAlert = false*/
    
    var body: some View {
        /*Section("New Project Cover"){
            TextField("Image", text: $image)
        }
        
        Section() {
            HStack {
                Spacer()
                    
                Button {
                    if image == "" {
                        showProjectCoverAlert.toggle()
                    }
                    
                    else {
                        dataManager.addProjectCover(image: image, projects: [], outfits: [])
                    }
                    
                    image = ""
                    
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showProjectCoverAlert) {
                    Button("I'm sorry, it won't happen again...", role: .cancel) { }
                } message: {
                    Text("You forgot to fill in some precious information")
                }
                    
                Spacer()
            }
        }*/
    }
}

#Preview {
    /*NewProjectCoverView()
        .environmentObject(DataManager())*/
}
