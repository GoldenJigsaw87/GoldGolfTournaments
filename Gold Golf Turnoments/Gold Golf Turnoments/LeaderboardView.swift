//
//  LeaderboardView.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/11/26.
//



import SwiftUI

struct LeaderboardView: View {
    
    @State private var players: [Player] = [
        Player(name: "Tommy", score: [72]),
        Player(name: "Mark", score: [75]),
        Player(name: "Jordan", score: [78]),
        Player(name: "Chris", score: [80])
    ]
    
    var sortedPlayers: [Player] {
        players.sorted { $0.score < $1.score }
    }
    
    var body: some View {
       
            
          
            
            VStack {
                
                // 🏆 Title
                Text("Leaderboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                            
                            LeaderboardRow(
                                rank: index + 1,
                                player: player
                            )
                        }
                    
                    .padding()
                }
            }
        }
    }
}
