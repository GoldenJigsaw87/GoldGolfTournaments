//
//  UserProfile.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 4/1/26.
//


import SwiftUI

struct UserProfile: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    var body: some View {
        
        ZStack {
            
            LinearGradient(colors: [.green.opacity(0.6), .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            Text("Coming soon")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        
//        TabView {
//            
//            
//            
//            LeaderboardView()
//                .tabItem {
//                    Label("Leaderboard", systemImage: "list.number")
//                }
//            
//            FriendsList()
//                .tabItem {
//                    Label("Friends", systemImage: "person.2")
//                }
//        }
    }
    
   
}

#Preview {
    ContentView()
}
