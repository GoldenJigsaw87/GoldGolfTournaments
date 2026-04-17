//
//  AccountCreator.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct CreateAccountView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    
    
    let db = Firestore.firestore()
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing:15) {
                
                Text("Create Account")
                    .font(.largeTitle)
                
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                
                Divider()
                
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Phone", text: $phone)
                    .textFieldStyle(.roundedBorder)
                
                Button("Create Account") {
                    db.collection("users").document(username).setData([
                        "holesPlayed": 0,
                        "score": 0
                    ]) { error in
                        if let error = error {
                            print("Firestore Error: \(error.localizedDescription)")
                        } else {
                            print("Account successfully created")
                        }
                    }
                    
                    NavigationLink("Already have an account? Sign in", destination: SignInView())
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                    
                }
                .padding()
                
            }
        }
    }
}

