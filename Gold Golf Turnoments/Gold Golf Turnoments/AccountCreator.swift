//
//  AccountCreator.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI

struct CreateAccountView: View {

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""

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

                }

            }
            .padding()
            
        }
    }
}
