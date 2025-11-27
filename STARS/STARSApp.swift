//
//  STARSApp.swift
//  STARS
//
//  Created by Marius Gabriel Budăi on 27.08.2024.
//

import SwiftUI
import SwiftData
import STARSAPI

@main
struct STARSApp: App {
    init() {
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var dataManager = DataManager.shared
    @AppStorage("userID") var userID: String = ""
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    @AppStorage("userCustomSecondaryColor") var userCustomSecondaryColor: String = ""
    
    var body: some View {
        Group {
            if !userIsLoggedIn {
                SignUpView()
            } else if userID.isEmpty {
                SplashView()
            } else {
                ContentView()
            }
        }
        .tint(dataManager.accentColor)
        .onChange(of: dataManager.accentColor) { oldValue, newValue in
            print("it changed !")
        }
    }
}

#Preview {
    RootView()
        .onAppear {
            DispatchQueue.main.async {
                let loginData = STARSAPI.LoginInput(username: "mariusss", password: "password")
                
                // 2. Perform the mutation
                Network.shared.apollo.perform(mutation: STARSAPI.LoginMutation(data: loginData)) { result in
                    switch result {
                    case .success(let graphQLResult):
                        if let user = graphQLResult.data?.loginUser {
                            print("Login successful for user: \(user.username)")
                            
                        } else if let errors = graphQLResult.errors {
                            print("GraphQL errors: \(errors)")
                        }
                        
                    case .failure(let error):
                        print("Network error: \(error)")
                    }
                }
                
                UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
                UserDefaults.standard.set("1", forKey: "userID")
                UserDefaults.standard.set("mariusss", forKey: "userUsername")
                UserDefaults.standard.set("Marius", forKey: "userDisplayName")
                UserDefaults.standard.set(true, forKey: "userHasPremium")
                UserDefaults.standard.set("he/him", forKey: "userPronouns")
                UserDefaults.standard.set("#0D98BA", forKey: "userCustomSecondaryColor")
                UserDefaults.standard.set(true, forKey: "userIsStaff")
                UserDefaults.standard.set(true, forKey: "userIsSuperuser")
            }
        }
}

struct SplashView: View {
    var body: some View {
        VStack {
            Text("Welcome to STARS!")
                .font(.largeTitle)
                .bold()
                .padding()
            
            HStack{
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
                Image(systemName: "star.fill")
            }
            .foregroundColor(.yellow)
            .font(.largeTitle)
            .bold()
            
            ProgressView()
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accentColor.ignoresSafeArea())
    }
}

/* 
 Messaging
import UserNotifications

class PushNotificationManager: NSObject, ObservableObject {
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request notifications: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}*/
