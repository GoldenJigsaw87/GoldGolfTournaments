import SwiftUI
import FirebaseFirestore
import ClerkKit

struct ScorecardView: View {
    @Environment(Clerk.self) private var clerk
    
    let holes: Int
    let courseName: String
    let roomCode: String
    
    @State private var card: Card
    @State private var scores: [[Int]]
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var listener: ListenerRegistration?
    @State private var hasJoinedCard = false
    
    private let firebaseService = FirebaseCardService()

    init(card: Card) {
        self.holes = card.numberOfHoles
        self.courseName = card.courseName
        self.roomCode = card.roomId
        
        _card = State(initialValue: card)
        
        // Initialize scores - start with empty array, will be populated when players join
        _scores = State(initialValue: Array(
            repeating: Array(repeating: 0, count: max(card.players.count, 1)),
            count: card.numberOfHoles
        ))
    }

    var body: some View {
        VStack {
            Text(courseName)
                .font(.title)
            
            Text("Room Code: \(roomCode)")
                .font(.headline)
                .foregroundColor(.blue)
            
            // Error message display
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // Loading indicator
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Updating...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            // Show players count
            Text("\(card.players.count) player(s) joined")
                .font(.caption)
                .foregroundColor(.secondary)

            if card.players.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("Waiting for players to join...")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Share the room code: \(roomCode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                Spacer()
            } else {
                // Scrollable table (vertical + horizontal)
                ScrollView([.vertical, .horizontal]) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Header Row
                        HStack {
                            Text("Hole").frame(width: 40)
                            Text("Par").frame(width: 40)

                            ForEach(card.players, id: \.id) { player in
                                Text(player.username)
                                    .frame(width: 90)
                                    .lineLimit(1)
                            }
                        }
                        .font(.headline)

                        // Holes
                        ForEach(Array(1...holes), id: \.self) { hole in
                            HStack {
                                Text("\(hole)").frame(width: 40)
                                
                                // Get par for this hole from card data
                                let par = card.holes.first(where: { $0.number == hole })?.par ?? 4
                                Text("\(par)").frame(width: 40)

                                ForEach(Array(card.players.enumerated()), id: \.offset) { playerIndex, player in
                                    // Score stepper with Firebase integration
                                    VStack {
                                        Stepper(
                                            value: Binding(
                                                get: {
                                                    guard playerIndex < scores[hole - 1].count else { return 0 }
                                                    return scores[hole - 1][playerIndex]
                                                },
                                                set: { newValue in
                                                    ensureScoresArraySize()
                                                    if playerIndex < scores[hole - 1].count {
                                                        scores[hole - 1][playerIndex] = newValue
                                                    }
                                                }
                                            ),
                                            in: 0...20,
                                            onEditingChanged: { isEditing in
                                                if !isEditing {
                                                    // User finished editing, update Firebase
                                                    updateScoreInFirebase(holeNumber: hole, playerIndex: playerIndex)
                                                }
                                            }
                                        ) {
                                            Text("\(playerIndex < scores[hole - 1].count ? scores[hole - 1][playerIndex] : 0)")
                                                .frame(width: 40)
                                        }
                                    }
                                    .frame(width: 90)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            setupRealtimeListener()
            joinCardAsCurrentUser()
        }
        .onDisappear {
            cleanupListener()
        }
    }
    
    // MARK: - Helper Methods
    
    private func ensureScoresArraySize() {
        let playerCount = card.players.count
        
        // Ensure scores array has the right dimensions
        while scores.count < holes {
            scores.append(Array(repeating: 0, count: playerCount))
        }
        
        for holeIndex in 0..<scores.count {
            while scores[holeIndex].count < playerCount {
                scores[holeIndex].append(0)
            }
        }
    }
    
    private func joinCardAsCurrentUser() {
        guard let user = clerk.user, !hasJoinedCard else { return }
        
        Task {
            do {
                let player = Player(
                    id: user.id,
                    username: user.username ?? user.emailAddresses.first?.emailAddress ?? "Unknown"
                )
                
                isLoading = true
                try await firebaseService.addPlayerToCard(roomId: roomCode, player: player)
                await MainActor.run {
                    hasJoinedCard = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to join card: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Firebase Integration Methods
    
    private func setupRealtimeListener() {
        // First, save the card to Firebase if it doesn't exist
        Task {
            do {
                // Try to get existing card first
                let existingCard = try await firebaseService.getCard(roomId: roomCode)
                if existingCard == nil {
                    // Card doesn't exist, save the new one
                    print("💾 Saving new card to Firebase: \(roomCode)")
                    try await firebaseService.saveCard(card)
                    print("✅ New card saved to Firebase: \(roomCode)")
                } else {
                    print("ℹ️ Card already exists in Firebase: \(roomCode)")
                }
            } catch {
                print("❌ Failed to save card: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to save card: \(error.localizedDescription)"
                }
                return
            }
        }
        
        // Listen for real-time updates to the card
        listener = firebaseService.listenToCard(roomId: roomCode) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedCard):
                    if let updatedCard = updatedCard {
                        self.card = updatedCard
                        self.updateLocalScores(from: updatedCard)
                        // Clear any previous error messages
                        self.errorMessage = nil
                    } else {
                        // Card not found - this might be expected for new cards
                        print("ℹ️ Card not found yet: \(self.roomCode)")
                    }
                case .failure(let error):
                    print("❌ Firebase sync error: \(error)")
                    self.errorMessage = "Failed to sync: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func cleanupListener() {
        listener?.remove()
    }
    
    private func updateLocalScores(from card: Card) {
        // Update scores array size to match current players
        ensureScoresArraySize()
        
        // Update local scores array from Firebase data
        for (holeIndex, hole) in card.holes.enumerated() {
            for (playerIndex, player) in card.players.enumerated() {
                if let playerScore = hole.scores.first(where: { $0.playerId == player.id }) {
                    if holeIndex < scores.count && playerIndex < scores[holeIndex].count {
                        scores[holeIndex][playerIndex] = playerScore.score
                    }
                }
            }
        }
    }
    
    private func updateScoreInFirebase(holeNumber: Int, playerIndex: Int) {
        guard playerIndex < card.players.count else { return }
        
        let player = card.players[playerIndex]
        let newScore = scores[holeNumber - 1][playerIndex]
        
        // Create updated scores for this hole
        var updatedScores = card.holes.first(where: { $0.number == holeNumber })?.scores ?? []
        
        // Update or add the player's score
        if let existingIndex = updatedScores.firstIndex(where: { $0.playerId == player.id }) {
            updatedScores[existingIndex].score = newScore
        } else {
            updatedScores.append(PlayerScore(playerId: player.id, score: newScore))
        }
        
        // Update Firebase
        Task {
            do {
                isLoading = true
                try await firebaseService.updateHoleScores(
                    cardId: roomCode,
                    holeNumber: holeNumber,
                    scores: updatedScores
                )
                await MainActor.run {
                    isLoading = false
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to update score: \(error.localizedDescription)"
                }
            }
        }
    }
}