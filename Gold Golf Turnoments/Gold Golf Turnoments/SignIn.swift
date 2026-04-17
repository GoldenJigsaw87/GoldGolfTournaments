//
//  SignIn.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI
import FirebaseFirestore

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false


    @State private var username = ""
    @State private var password = ""

    var body: some View {

        VStack(spacing:20) {

            Text("Sign In")
                .font(.largeTitle)

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Login") {
                let db = Firestore.firestore()
                let userDoc = db.collection("users").document(username)
                userDoc.getDocument { document, error in
                    if let error = error {
                        print("Error fetching user: \(error.localizedDescription)")
                        return
                    }
                    guard let document = document, document.exists else {
                        print("User not found")
                        return
                    }
                    let data = document.data()
                    let storedPassword = data?["password"] as? String ?? ""
                    if storedPassword == password {
                        isLoggedIn = true
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Incorrect password")
                    }
                }
            }
            

            Spacer()
        }
        .padding()
    }
}

