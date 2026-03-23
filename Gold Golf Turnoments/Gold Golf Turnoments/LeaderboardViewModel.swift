//
//  LeaderboardViewModel.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/11/26.
//

import Foundation
import SwiftUI
internal import Combine

class LeaderboardViewModel: ObservableObject {

    @Published var players: [Player] = [
        Player(name: "Tommy", totalScore: 82),
        Player(name: "Mark", totalScore: 86),
        Player(name: "Sam", totalScore: 90)
    ]

    func position(for player: Player) -> Int {
        let sortedPlayers = players.sorted { $0.totalScore < $1.totalScore }
        return (sortedPlayers.firstIndex { $0.id == player.id } ?? 0) + 1
    }
}
