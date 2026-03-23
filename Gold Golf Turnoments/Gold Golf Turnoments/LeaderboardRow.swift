//
//  LeaderboardRow.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/23/26.
//

import SwiftUI

struct LeaderboardRow: View {
    var rank: Int
    var player: Player
   
    var body: some View {
        HStack {
            
            // 🥇 Rank
            Text("#\(rank)")
                .font(.headline)
                .frame(width: 50)
            
            // 👤 Name
            Text(player.name)
                .font(.headline)
            
            Spacer()
            
           
            Text("\(player.score)")
                .font(.title3)
                .fontWeight(.bold)
        }
        
        
        
        
        .padding()
        .background(.ultraThinMaterial) // 🔥 frosted glass look
        .cornerRadius(12)
    }
}
