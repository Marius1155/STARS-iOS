//
//  NewArtistView.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 15.09.2024.
//

import SwiftUI

struct NewArtistView: View {
    /*@EnvironmentObject var dataManager: DataManager
    
    @State private var name = ""
    @State private var picture = ""
    @State private var wikipedia = ""
    @State private var pronouns = ""
    @State private var birthdate = Date()
    @State private var showArtistAlert = false
    
    @State private var hasBirthdate = true*/
    
    var body: some View {
        /*Section("New Artist"){
            TextField("Name", text: $name)
            TextField("Picture", text: $picture)
            TextField("Wikipedia", text: $wikipedia)
            TextField("Pronouns", text: $pronouns)
            Toggle("Has known birthdate", isOn: $hasBirthdate)
            
            if hasBirthdate {
                DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
            }
        }
        
        Section() {
            HStack {
                Spacer()
                
                Button {
                    if name == "" || picture == "" || pronouns == "" || birthdate == Date() {
                        showArtistAlert.toggle()
                    }
                    
                    else {
                        if hasBirthdate == false {
                            dataManager.addArtist(name: name, picture: picture, wikipedia: wikipedia, pronouns: pronouns)
                        }
                        
                        else {
                            dataManager.addArtist(name: name, picture: picture, wikipedia: wikipedia, pronouns: pronouns, birthdate: birthdate)
                        }
                        name = ""
                        picture = ""
                        wikipedia = ""
                        pronouns = ""
                        birthdate = Date()
                        hasBirthdate = true
                    }
                } label: {
                    Text("Save")
                        .bold()
                }
                .alert("Dumb Bitch", isPresented: $showArtistAlert) {
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
    /*NewArtistView()
        .environmentObject(DataManager())*/
}
