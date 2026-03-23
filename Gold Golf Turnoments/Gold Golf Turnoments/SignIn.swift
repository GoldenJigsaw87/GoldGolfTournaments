//
//  SignIn.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI

struct SignInView: View {

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

            }

            Spacer()
        }
        .padding()
    }
}
