////
////  LeaderboardView.swift
////  Gold Golf Turnoments
////
////  Created by Mark Jensen on 3/11/26.
////
//
//import SwiftUI
//
//struct LeaderboardView: View {
//    @State private var players: [Player] = [
//        Player(name: "", score: []),
//        Player(name: "", score: []),
//        Player(name: "", score: []),
//        Player(name: "", score: [])
//    ]
//    
//    // Sort players by their first score (lower is better)
//    var sortedPlayers: [Player] {
//        players.sorted { ($0.score.first ?? .max) < ($1.score.first ?? .max) }
//    }
//    @State private var ratio: Double = 0
//    
//    var body: some View {
//                ZStack {
//                   
//                    LinearGradient(colors: [.green.opacity(0.6), .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                       .ignoresSafeArea()
//        
//                    Text("Coming soon")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//        
//        //            VStack {
//        //                // 🏆 Title
//        //                Text("Leaderboard")
//        //                    .font(.largeTitle)
//        //                    .fontWeight(.bold)
//        //                    .foregroundColor(.white)
//        //                    .padding(.top)
//        //
//        //                ScrollView {
//        //                    VStack(spacing: 12) {
//        //                        ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
//        //                            LeaderboardRow(
//        //                                rank: index + 1,
//        //                                player: player
//        //                            )
//        //                        }
//        //                        Text("Stroke Ratio: \(ratio)")
//        //                    }
//        //                    .padding()
//        //                }
//        //            }
//        //            .onAppear {
//        //                APIService.shared.getStats(userID: "USER_ID_HERE") { value in
//        //                    DispatchQueue.main.async {
//        //                        self.ratio = value
//        //                    }
//        //                }
//        //            }
//               }
//           }
//       
//    
//}
//
//#Preview {
//    LeaderboardView()
//}
