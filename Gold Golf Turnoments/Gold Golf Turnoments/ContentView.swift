//
//  ContentView.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 2/2/26.
//

import Foundation
import SwiftUI

class LeaderboardViewModel: ObservableObject {
    
    @Published var players: [Player] = []
    
    // MARK: - Add Player
    func addPlayer(name: String, holes: Int) {
        let newPlayer = Player(
            id: UUID(),
            name: name,
            holeScores: Array(repeating: 0, count: holes)
        )
        players.append(newPlayer)
        sortLeaderboard()
    }
    
    // MARK: - Update Score (called by scorecard screen later)
    func updateScore(playerID: UUID, holeIndex: Int, strokes: Int) {
        guard let index = players.firstIndex(where: { $0.id == playerID }),
              players[index].holeScores.indices.contains(holeIndex) else { return }
        
        players[index].holeScores[holeIndex] = strokes
        sortLeaderboard()
    }
    
    // MARK: - Sorting Logic (Lowest Score Wins)
    private func sortLeaderboard() {
        players.sort { $0.totalScore < $1.totalScore }
    }
    
    // MARK: - Position Calculation (Handles Ties)
    func position(for player: Player) -> Int {
        let sortedScores = players.map { $0.totalScore }.sorted()
        guard let firstIndex = sortedScores.firstIndex(of: player.totalScore) else { return 0 }
        return firstIndex + 1
    }
}
