//
//  CardBuilder.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 3/6/26.
//

import SwiftUI
import ClerkKit

struct CardBuilderView: View {
    @Environment(Clerk.self) private var clerk
    @State private var joinCode = ""
    @State private var holes = 18
    @State private var courseName = ""
    @State private var isCreating = false
    @State private var errorMessage = ""
    @State private var navigateToScorecard = false
    @State private var savedCard: Card?
    
    private let firebaseService = FirebaseCardService()

    func generateRoomCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    var createdCard: Card {
        let holesArray: [Hole] = (0..<holes).map { i in
            Hole(par: 4, number: i + 1, scores: [])
        }
        
        // Add the creator as the first player
        var initialPlayers: [Player] = []
        if let user = clerk.user {
            let creator = Player(
                id: user.id,
                username: user.username ?? user.emailAddresses.first?.emailAddress ?? "Creator"
            )
            initialPlayers.append(creator)
        }
        
        return Card(
            roomId: joinCode,
            maxPlayers: 32,
            numberOfHoles: holes,
            courseName: courseName.isEmpty ? "Unnamed Course" : courseName,
            holes: holesArray,
            players: initialPlayers
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Room Code: \(joinCode)")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.bottom, 5)

            Text("Card Builder")
                .font(.title)

            //  Course Name
            TextField("Course Name", text: $courseName)
                .textFieldStyle(.roundedBorder)
                .disabled(isCreating)

            //  Holes (1–18)
            Stepper("Holes: \(holes)", value: $holes, in: 1...18)
                .disabled(isCreating)

            Text("Players will join automatically when they enter the room code")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            //  Start Scorecard
            if isCreating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Creating scorecard...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                Button("Create Scorecard") {
                    createScorecard()
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            joinCode = generateRoomCode()
        }
        .navigationDestination(isPresented: $navigateToScorecard) {
            if let card = savedCard {
                ScorecardView(card: card)
            }
        }
    }
    
    private func createScorecard() {
        isCreating = true
        errorMessage = ""
        
        Task {
            do {
                // Save the card to Firebase first
                let cardToSave = createdCard
                print("🚀 Creating card with room ID: \(cardToSave.roomId)")
                try await firebaseService.saveCard(cardToSave)
                print("💾 Card saved to Firebase: \(cardToSave.roomId)")
                
                // Wait a brief moment to ensure the card is available in Firestore
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Verify the card was saved by trying to retrieve it
                let savedCard = try await firebaseService.getCard(roomId: cardToSave.roomId)
                guard savedCard != nil else {
                    print("❌ Card verification failed - card not found after save")
                    throw FirebaseError.cardNotFound
                }
                print("✅ Card verified in Firebase: \(cardToSave.roomId)")
                
                // Navigate to scorecard view
                await MainActor.run {
                    isCreating = false
                    self.savedCard = cardToSave
                    navigateToScorecard = true
                }
                
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = "Failed to create scorecard: \(error.localizedDescription)"
                    print("❌ Card creation error: \(error)")
                }
            }
        }
    }
}

