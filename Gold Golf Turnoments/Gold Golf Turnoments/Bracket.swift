//
//  Bracket.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 2/2/26.
//

import SwiftUI

struct LeaderboardView: View {
    
    @StateObject var viewModel = LeaderboardViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.players) { player in
                    
                    NavigationLink(destination: ScorecardView(LeaderboardViewModel: viewModel, player: player)) {
                        
                        HStack {
                            Text("#\(viewModel.position(for: player))")
                                .font(.headline)
                                .frame(width: 40)
                            
                            Text(player.name)
                                .font(.title3)
                            
                            Spacer()
                            
                            Text("\(player.totalScore)")
                                .bold()
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
        }
    }
}

