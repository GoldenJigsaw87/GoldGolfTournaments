//
//  Welcome.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//
import SwiftUI

struct WelcomeView: View {

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 16) {
                    NavigationLink("Card Builder", destination: CardBuilderView())
                    NavigationLink("Join a Card", destination: ScorecardView())
                    NavigationLink("Leaderboard", destination: LeaderboardView())
                }

                Spacer()

                VStack(spacing: 12) {
                    NavigationLink("Sign In", destination: SignInView())
                    NavigationLink("Create Account", destination: CreateAccountView())
                }
            
            .padding()
            .foregroundColor(.white)
            
                .foregroundColor(.black)
                .padding()
            }
        }
    }
}
