//
//  ContentView.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 2/2/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import ClerkKit
import ClerkKitUI
struct ContentView: View {
    @Environment(Clerk.self) private var clerk
//    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var goToProfile = false
    @State private var showProfileSheet = false
    
    
    
    private func fetchPlayers() async {
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("Players").getDocuments()
            for document in snapshot.documents {
                print("\(document.documentID) => \(document.data())")
            }
            // Handle snapshot if desired
        } catch {
            // Handle error if desired
            print("error")
        }
    }
    
    var body: some View {
        if let user = clerk.user {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.green.opacity(0.6), .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("Welcome!")
                            .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .padding()
                                        .background(.ultraThinMaterial) // 👈 subtle glass effect
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(radius: 5)
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
                            NavigationLink("Card Builder", destination: CardBuilderView())
                                .frame(maxWidth: .infinity)
                                                   .padding()
                                                   .background(Color.white.opacity(0.9))
                                                   .foregroundColor(.black)
                                                   .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            NavigationLink("Join a Card", destination: JoinScorecardView())
                                .frame(maxWidth: .infinity)
                                                   .padding()
                                                   .background(Color.white.opacity(0.9))
                                                   .foregroundColor(.black)
                                                   .clipShape(RoundedRectangle(cornerRadius: 10))
//                            NavigationLink("Leaderboard", destination: LeaderboardView())
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        UserButton()
//                        Button {
//                            showProfileSheet = true
//                        } label: {
//                            Circle()
//                                .fill(Color.gray)
//                                .frame(width: 35, height: 35)
//                                .overlay(
//                                    Image(systemName: "person.fill")
//                                        .foregroundColor(.white)
//                                )
//                        }
                    }
                }
//                .sheet(isPresented: $showProfileSheet) {
//                    if let user = clerk.user {
//                        
//                        
//                    } else {
//                        SignInView()
//                    }
//                }
            }
        } else {
            // Show authentication (login/sign-up) interface only
            AuthView()
                
//            NavigationStack {
//                VStack(spacing: 20) {
//                    Text("Welcome! Please log in or create an account.")
//                        .font(.title)
//                        .fontWeight(.bold)
//                    NavigationLink("Sign In", destination: SignInView())
//                    NavigationLink("Create Account", destination: CreateAccountView())
//                    Spacer()
//                }
//                .padding()
//            }
        }
    }
}

