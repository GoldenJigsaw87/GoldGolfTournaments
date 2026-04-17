////
////  Bracket.swift
////  Gold Golf Turnoments
////
////  Created by Mark Jensen on 2/2/26.
////
//
//import SwiftUI
//import Combine
//
//class BracketViewModel: ObservableObject {
//    @Published var players: [Player] = [
//        Player(name: "Tommy", score: [72]),
//        Player(name: "Mark", score: [75]),
//        Player(name: "Jordan", score: [78]),
//        Player(name: "Chris", score: [80])
//    ]
//    
//    func position(for player: Player) -> Int {
//        let sorted = players.sorted { $0.totalScore < $1.totalScore }
//        return (sorted.firstIndex { $0.id == player.id } ?? 0) + 1
//    }
//}
//
//struct Bracket: View {
//    @StateObject var viewModel = BracketViewModel()
//
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(viewModel.players) { player in
//                    NavigationLink(destination: ScorecardView(holes: 4, players: 4, courseName: "Sugar Hills", playerNames: viewModel.players.map { $0.name }, roomCode: "LEADERBOARD")) {
//                        HStack {
//                            Text("#\(viewModel.position(for: player))")
//                                .font(.headline)
//                                .frame(width: 40)
//
//                            Text(player.name)
//                                .font(.title3)
//
//                            Spacer()
//
//                            Text("\(player.totalScore)")
//                                .bold()
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Leaderboard")
//        }
//    }
//}
//
//
//// End of file
//
