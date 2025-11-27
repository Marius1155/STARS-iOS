import SwiftUI
import STARSAPI

struct SignUpView: View {
    @State @AppStorage("userID") var userID: String = ""
    @State @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    @AppStorage("userHasPremium") var userHasPremium: Bool = false
    @AppStorage("userIsStaff") var userIsStaff: Bool = false
    @AppStorage("userIsSuperuser") var userIsSuperuser: Bool = false
    @AppStorage("userUsername") var userUsername: String = ""
    @AppStorage("userDisplayName") var userDisplayName: String = ""
    @AppStorage("userPronouns") var userPronouns: String = ""
    @AppStorage("userCustomSecondaryColor") var userCustomSecondaryColor: String = ""
    
    enum UsernameStatus {
        case idle // Not checked yet
        case checking // A network request is in progress
        case available // It's available
        case taken // It's taken
        case bad // It contains forbidden characters
    }
    
    private var usernameStatusColor: Color {
        switch usernameStatus {
        case .available:
            return .green
        case .taken, .bad:
            return .red
        case .idle, .checking:
            return .clear
        }
    }
    @State private var usernameStatus: UsernameStatus = .idle
    @State private var usernameMessage: String = ""
    
    enum EmailStatus {
        case idle // Not checked yet
        case checking // A network request is in progress
        case available // It's available
        case taken // It's taken
        case bad // It contains forbidden characters
    }
    
    private var emailStatusColor: Color {
        switch emailStatus {
        case .available:
            return .green
        case .taken, .bad:
            return .red
        case .idle, .checking:
            return .clear
        }
    }
    
    @State private var emailStatus: EmailStatus = .idle
    @State private var emailMessage: String = ""
    
    @State private var pronounsChecked: Bool = true
    
    
    @State private var passwordMessage: String = ""
    @State private var passwordConfirmationMessage: String = ""
    
    // View state
    @State private var viewSelection: Int = 1
    
    // Form fields
    @State private var email = ""
    @State private var username = ""
    @State private var displayName = "" // stored in firstName filed in the DB
    @State private var pronouns = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    
    // Alert state
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Picker("", selection: $viewSelection) {
                Text("Log In").tag(1)
                Text("Sign Up").tag(2)
            }
            .pickerStyle(.segmented)
            
            if viewSelection == 1 {
                // MARK: - Login Form
                VStack {
                    HStack {
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    TextField("Username or Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    SecureField("Password", text: $password)
                        .autocapitalization(.none)
                        .textContentType(.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Log In", action: login)
                        .buttonStyle(BorderedButtonStyle())
                        .padding(.top)
                }
            } else {
                // MARK: - Signup Form
                VStack {
                    HStack {
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .onChange(of: email) { _, newValue in
                            self.email = email.lowercased()
                            Task {
                                // Reset status and wait for 500ms after user stops typing
                                self.emailStatus = .checking
                                try? await Task.sleep(for: .milliseconds(500))
                                
                                // If the text hasn't changed again, perform the check
                                if newValue == self.email {
                                    await checkEmail()
                                }
                            }
                        }
                    
                    
                    // --- AVAILABILITY MESSAGE ---
                    HStack {
                        Text(emailMessage)
                            .font(.caption)
                            .foregroundColor(emailStatusColor)
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    
                    // --- USERNAME FIELD WITH REAL-TIME CHECK ---
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.username)
                        .onChange(of: username) { _, newValue in
                            self.username = username.lowercased()
                            
                            if username.count > 25 {
                                username = String(username.prefix(25))
                            }
                        
                            Task {
                                // Reset status and wait for 500ms after user stops typing
                                self.usernameStatus = .checking
                                try? await Task.sleep(for: .milliseconds(500))
                                
                                // If the text hasn't changed again, perform the check
                                if newValue == self.username {
                                    await checkUsername()
                                }
                            }
                        }
                    
                    // --- AVAILABILITY MESSAGE ---
                    HStack {
                        Text(usernameMessage)
                            .font(.caption)
                            .foregroundColor(usernameStatusColor)
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    TextField("Display name", text: $displayName)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: displayName) {_, _ in
                            if displayName.count > 50 {
                                displayName = String(displayName.prefix(50))
                            }
                        }
                    
                    HStack {
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    TextField("Pronouns (e.g., they/them)", text: $pronouns)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: pronouns) { _, newValue in
                            pronounsChecked = false
                            pronouns = newValue.lowercased()
                            
                            pronouns = pronouns.filter { $0.isLetter || $0 == "/" }
                            
                            if pronouns.count > 32 {
                                pronouns = String(pronouns.prefix(32))
                            }
                            
                            pronounsChecked = true
                        }
                    
                    HStack {
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    SecureField("Password", text: $password)
                        .autocapitalization(.none)
                        .textContentType(.newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: password) { _, newValue in
                            
                            passwordMessage = ""
                            
                            Task {
                                
                                try await Task.sleep(for: .milliseconds(500))
                                
                                if newValue == password {
                                    if password.count < 15 {
                                        passwordMessage = "Password must be at least 16 characters long."
                                    }
                                }
                            }
                        }
                    
                    HStack {
                        Text(passwordMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    
                    SecureField("Confirm Password", text: $passwordConfirmation)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: passwordConfirmation) { _, newValue in
                            
                            passwordConfirmationMessage = ""
                            
                            Task {
                                
                                try await Task.sleep(for: .milliseconds(500))
                                
                                if newValue == passwordConfirmation {
                                    if passwordConfirmation != password {
                                        passwordConfirmationMessage = "The passwords don't match"
                                    }
                                }
                            }
                        }
                    
                    HStack {
                        Text(passwordConfirmationMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .frame(height: 10)
                    
                    
                    Button("Sign Up", action: register)
                        .buttonStyle(BorderedButtonStyle())
                        .padding(.top)
                        .disabled(email.isEmpty || emailStatus != .available || username.isEmpty || usernameStatus != .available || password.count < 15 || password != passwordConfirmation || !pronounsChecked)
                }
            }
        }
        .padding()
        .navigationTitle(viewSelection == 1 ? "Log In" : "Sign Up")
        .alert(viewSelection == 1 ? "Log In failed!" : "Sign Up failed!", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
    }
    
    func checkEmail() async {
        guard !email.isEmpty else {
            emailStatus = .idle
            emailMessage = ""
            return
        }
    
        
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let regex = try! NSRegularExpression(pattern: emailPattern)
        let range = NSRange(location: 0, length: email.utf16.count)

        if regex.firstMatch(in: email, options: [], range: range) == nil {
            // If the email doesn't match the pattern, it's a bad format.
            self.emailStatus = .bad
            self.emailMessage = "Please enter a valid email address."
            return // Stop before making any network call
        }
        
        let query = STARSAPI.CheckEmailExistsQuery(email: self.email)
        
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if (graphQLResult.data?.users.edges.first?.node) != nil {
                    self.emailStatus = .taken
                    self.emailMessage = "An account already uses this email address."
                }
                else {
                    
                    self.emailStatus = .available
                    self.emailMessage = ""
                }
            case .failure(let error):
                print("Network Error checking email: \(error.localizedDescription)")
                self.emailStatus = .idle
            }
        }
    }
    
    func checkUsername() async {
        guard !username.isEmpty else {
            usernameStatus = .idle
            usernameMessage = ""
            return
        }
        
        // 1. --- NEW: Check for invalid characters first ---
        // This pattern allows only lowercase letters (a-z), numbers (0-9), dots, and underscores.
        let allowedCharactersPattern = "^[a-z0-9._]+$"
        let regex = try! NSRegularExpression(pattern: allowedCharactersPattern)
        let range = NSRange(location: 0, length: username.utf16.count)
        
        if regex.firstMatch(in: username, options: [], range: range) == nil {
            // If the pattern does not match, the username is bad.
            self.usernameStatus = .bad
            self.usernameMessage = "Usernames can only contain letters, numbers, '.', and '_'."
            return // Stop before making a network call
        }
        // --- END NEW CHECK ---
        
        
        let query = STARSAPI.CheckUsernameExistsQuery(username: self.username)
        
        
        Network.shared.apollo.fetch(query: query) { result in
            switch result {
            case .success(let graphQLResult):
                if (graphQLResult.data?.users.edges.first?.node) != nil {
                    self.usernameStatus = .taken
                    self.usernameMessage = "This username is already taken."
                }
                else {
                    
                    self.usernameStatus = .available
                    self.usernameMessage = "Username is available!"
                }
            case .failure(let error):
                print("Network Error checking username: \(error.localizedDescription)")
                self.usernameStatus = .idle
            }
        }
    }
    
    
    // This function now calls your new GraphQL mutation
    func login() {
        // 1. Create the input object required by the mutation
        let loginData = STARSAPI.LoginInput(username: email, password: password)
        
        // 2. Perform the mutation
        Network.shared.apollo.perform(mutation: STARSAPI.LoginMutation(data: loginData)) { result in
            switch result {
            case .success(let graphQLResult):
                if let user = graphQLResult.data?.loginUser {
                    // 3. Login was successful, store basic info
                    print("Login successful for user: \(user.username)")
                    self.userID = user.id
                    self.userUsername = user.username
                    
                    // 4. Fetch the full profile to get extra details
                    fetchUserProfile(userID: user.id)
                    
                } else if let errors = graphQLResult.errors {
                    self.errorMessage = errors.first?.message ?? "GraphQL Error"
                    self.showAlert = true
                    print("GraphQL errors: \(errors)")
                }
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                print("Network error: \(error)")
            }
        }
    }
    
    func fetchUserProfile(userID: String) {
        let userFilter = STARSAPI.UserFilter(id: .some(STARSAPI.IDBaseFilterLookup(exact: .some(userID))))
        let profileFilter = STARSAPI.ProfileFilter(user: .some(userFilter))
        
        Network.shared.apollo.fetch(query: STARSAPI.GetProfileQuery(filters: .some(profileFilter))) { result in
            switch result {
            case .success(let graphQLResult):
                if let profile = graphQLResult.data?.profiles.edges.first?.node {
                    self.userHasPremium = profile.hasPremium
                    self.userIsStaff = profile.user.isStaff
                    self.userIsSuperuser = profile.user.isSuperuser
                    self.userCustomSecondaryColor = profile.customSecondaryColor
                    self.userPronouns = profile.pronouns
                    self.userDisplayName = profile.user.firstName
                    self.userIsLoggedIn = true
                }
                // You should also handle GraphQL-level errors here
                if let errors = graphQLResult.errors {
                    print("GraphQL Errors: \(errors)")
                    self.errorMessage = errors.first?.message ?? "An error occurred."
                    self.showAlert = true
                }
                
            case .failure(let error):
                // This is the code you need to add
                // 1. Print the detailed error for your own debugging
                print("Network Error: \(error.localizedDescription)")
                
                // 2. Set your state variables to show a user-friendly alert
                self.errorMessage = "Could not fetch user profile. Please check your internet connection and try again."
                self.showAlert = true
            }
        }
    }
    
    func register() {
        // 1. Client-side validation
        guard password == passwordConfirmation else {
            self.errorMessage = "Passwords do not match."
            self.showAlert = true
            return
        }
        
        // 2. Create the input object for the signup mutation
        let signupData = STARSAPI.SignupInput(
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation,
            username: username,
            firstName: .some(displayName)
        )
        
        // 3. Perform the signup mutation
        Network.shared.apollo.perform(mutation: STARSAPI.SignupMutation(data: signupData)) { result in
            switch result {
            case .success(let graphQLResult):
                if let newUser = graphQLResult.data?.signup {
                    print("Signup successful for user: \(newUser.username)")
                    
                    // 4. Store basic info
                    self.userID = newUser.id
                    self.userUsername = newUser.username
                                    
                    // 5. If pronouns were entered, call updateProfile
                    if !pronouns.isEmpty {
                        updateProfilePronouns(profileID: newUser.id, pronouns: pronouns)
                    } else {
                        // Otherwise, just log in
                        self.userIsLoggedIn = true
                    }
                    
                    fetchUserProfile(userID: newUser.id)
                    
                } else if let errors = graphQLResult.errors {
                    self.errorMessage = errors.first?.message
                    self.showAlert = true
                }
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
    
    func updateProfilePronouns(profileID: String, pronouns: String) {
        let profileData = STARSAPI.ProfileUpdateInput(id: profileID, pronouns: .some(pronouns))
        
        Network.shared.apollo.perform(mutation: STARSAPI.UpdateProfileMutation(data: profileData)) { result in
            switch result {
            case .success(let graphQLResult):
                if let updatedProfile = graphQLResult.data?.updateProfile {
                    print("Successfully set pronouns to \(updatedProfile.pronouns)")
                    self.userPronouns = updatedProfile.pronouns
                }
                // Log in regardless of whether pronouns were set successfully
                self.userIsLoggedIn = true
                
            case .failure(let error):
                print("Could not update pronouns after signup: \(error.localizedDescription)")
                // Still log the user in, they can update pronouns later
                self.userIsLoggedIn = true
            }
        }
    }
}
