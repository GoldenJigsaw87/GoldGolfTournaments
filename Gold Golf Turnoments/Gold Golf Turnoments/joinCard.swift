//
//  joinCard.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 4/9/26.
//

import SwiftUI
import ClerkKit

struct JoinScorecardView: View {
    @Environment(Clerk.self) private var clerk
    @State private var code = ""
    @State private var message = ""
    @State private var isLoading = false
    @State private var navigateToScorecard = false
    @State private var foundCard: Card?
    
    private let firebaseService = FirebaseCardService()

    var body: some View {
        VStack(spacing: 20) {
            Text("Join Scorecard")
                .font(.title)

            TextField("Enter Room Code", text: $code)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()

            if isLoading {
                ProgressView("Joining...")
            } else {
                Button("Join") {
                    joinGame()
                }
                .disabled(code.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(message.contains("Success") ? .green : .red)
            }

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $navigateToScorecard) {
            if let card = foundCard {
                ScorecardView(card: card)
            }
        }
    }

    func joinGame() {
        guard let user = clerk.user else {
            message = "Please sign in to join a game"
            return
        }
        
        let roomCode = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard !roomCode.isEmpty else {
            message = "Please enter a room code"
            return
        }
        
        isLoading = true
        message = ""
        
        Task {
            do {
                print("🔍 Attempting to join room: \(roomCode)")
                
                // Try to get the card
                guard let card = try await firebaseService.getCard(roomId: roomCode) else {
                    print("❌ Room code not found: \(roomCode)")
                    await MainActor.run {
                        isLoading = false
                        message = "Room code not found. Please check the code and try again."
                    }
                    return
                }
                
                print("✅ Found card: \(roomCode) with \(card.players.count) players")
                
                // Check if game is still active
                guard card.isActive else {
                    print("❌ Game is not active: \(roomCode)")
                    await MainActor.run {
                        isLoading = false
                        message = "This game has ended."
                    }
                    return
                }
                
                // Create player object
                let player = Player(
                    id: user.id,
                    username: user.username ?? user.emailAddresses.first?.emailAddress ?? "Unknown Player"
                )
                
                print("👤 Adding player \(player.username) to room \(roomCode)")
                
                // Add player to card
                try await firebaseService.addPlayerToCard(roomId: roomCode, player: player)
                
                print("✅ Player successfully added to room \(roomCode)")
                
                // Navigate to scorecard
                await MainActor.run {
                    foundCard = card
                    isLoading = false
                    message = "Successfully joined the game!"
                    navigateToScorecard = true
                }
                
            } catch {
                print("❌ Join game error: \(error)")
                await MainActor.run {
                    isLoading = false
                    message = "Failed to join game: \(error.localizedDescription)"
                }
            }
        }
    }
}
