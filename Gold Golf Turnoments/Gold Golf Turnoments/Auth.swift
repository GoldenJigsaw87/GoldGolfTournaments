////
////  Auth.swift
////  Gold Golf Turnoments
////
////  Created by Mark Jensen on 4/1/26.
////
//
//import SwiftUI
//
//struct AuthView: View {
//    
//    @State private var showSignIn = false
//    @State private var showSignUp = false
//    @State private var isLoggedIn = false
//
//    var body: some View {
//        Group {
//            if isLoggedIn {
//                ContentView() // or your main app screen
//            } else {
//                VStack(spacing: 30) {
//                    
//                    Spacer()
//                    
//                    Text("Golf Tracker")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                    
//                    Text("Track your game. Compete with friends.")
//                        .foregroundColor(.gray)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        showSignIn = true
//                    }) {
//                        Text("Sign In")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//                    
//                    Button(action: {
//                        showSignUp = true
//                    }) {
//                        Text("Create Account")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.black)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//                    
//                    Spacer()
//                }
//                .padding()
//                .fullScreenCover(isPresented: $showSignIn) {
//                    SignInView()
//                }
//                .fullScreenCover(isPresented: $showSignUp) {
//                    CreateAccountView()
//                }
//            }
//        }
//        .onAppear {
//            if UserDefaults.standard.string(forKey: "authToken") != nil {
//                isLoggedIn = true
//            }
//        }
//    }
//}
