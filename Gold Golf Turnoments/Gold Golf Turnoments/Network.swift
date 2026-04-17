//
//  Network.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 4/1/26.
//

import Foundation
import ClerkKit
import FirebaseFirestore
import FirebaseCore

//TODO - Remove
struct RegisterRequest: Codable {
    let username: String
    let password: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct TokenResponse: Codable {
    let token: String
}

struct User_DEP: Codable, Identifiable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String
}

// MARK: - Firebase Data Models
struct Member: Identifiable, Codable {
    var id: String
    var cards: [String]
    
    // Note: Clerk User is NOT saved to Firebase as requested
    // Only the user ID is stored for reference
    init(userId: String, cards: [String] = []) {
        self.id = userId
        self.cards = cards
    }
}

struct Card: Identifiable, Codable {
    var id: String { roomId }
    var roomId: String
    var maxPlayers: Int
    var numberOfHoles: Int
    var courseName: String
    var holes: [Hole]
    var players: [Player] // Changed from playersId to players
    var createdAt: Date
    var isActive: Bool
    
    init(roomId: String, maxPlayers: Int, numberOfHoles: Int, courseName: String, holes: [Hole], players: [Player] = []) {
        self.roomId = roomId
        self.maxPlayers = maxPlayers
        self.numberOfHoles = numberOfHoles
        self.courseName = courseName
        self.holes = holes
        self.players = players
        self.createdAt = Date()
        self.isActive = true
    }
    
    // Legacy support for playersId
    var playersId: [String] {
        return players.map { $0.id }
    }
    
    // Custom coding keys to handle potential Firebase field naming
    private enum CodingKeys: String, CodingKey {
        case roomId
        case maxPlayers
        case numberOfHoles
        case courseName
        case holes
        case players
        case createdAt
        case isActive
    }
}

// New Player structure
struct Player: Identifiable, Codable {
    var id: String // User ID from Clerk
    var username: String
    var joinedAt: Date
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
        self.joinedAt = Date()
    }
}

struct Hole: Identifiable, Codable {
    var id: String { "\(number)" }
    var par: Int
    var number: Int
    var scores: [PlayerScore]
    
    init(par: Int, number: Int, scores: [PlayerScore] = []) {
        self.par = par
        self.number = number
        self.scores = scores
    }
}

struct PlayerScore: Identifiable, Codable {
    var id: String { playerId }
    var playerId: String
    var score: Int
    var strokesGained: Double?
    
    init(playerId: String, score: Int, strokesGained: Double? = nil) {
        self.playerId = playerId
        self.score = score
        self.strokesGained = strokesGained
    }
}

// MARK: - Firebase Service
class FirebaseCardService {
    private let db = Firestore.firestore()
    
    // MARK: - Card Operations
    
    /// Save a new card to Firebase
    func saveCard(_ card: Card) async throws {
        do {
            let encoder = Firestore.Encoder()
            encoder.dateEncodingStrategy = .timestamp
            let cardData = try encoder.encode(card)
            try await db.collection("cards").document(card.roomId).setData(cardData)
            print("✅ Card saved to Firebase: \(card.roomId)")
        } catch {
            print("❌ Error encoding card: \(error)")
            print("Card data: roomId=\(card.roomId), players=\(card.playersId), holes=\(card.numberOfHoles)")
            throw error
        }
    }
    
    /// Update an existing card
    func updateCard(_ card: Card) async throws {
        let encoder = Firestore.Encoder()
        encoder.dateEncodingStrategy = .timestamp
        let cardData = try encoder.encode(card)
        try await db.collection("cards").document(card.roomId).updateData(cardData)
        print("✅ Card updated in Firebase: \(card.roomId)")
    }
    
    /// Update scores for a specific hole
    func updateHoleScores(cardId: String, holeNumber: Int, scores: [PlayerScore]) async throws {
        let cardRef = db.collection("cards").document(cardId)
        
        // Get current card data
        let document = try await cardRef.getDocument()
        guard document.exists else {
            throw FirebaseError.cardNotFound
        }
        
        var card = try document.data(as: Card.self)
        
        // Update the specific hole's scores
        if let holeIndex = card.holes.firstIndex(where: { $0.number == holeNumber }) {
            card.holes[holeIndex].scores = scores
            
            // Save back to Firebase
            try await updateCard(card)
        } else {
            throw FirebaseError.holeNotFound
        }
    }
    
    /// Retrieve a card by room ID
    func getCard(roomId: String) async throws -> Card? {
        let document = try await db.collection("cards").document(roomId).getDocument()
        
        guard document.exists else {
            return nil
        }
        
        do {
            let decoder = Firestore.Decoder()
            decoder.dateDecodingStrategy = .timestamp
            return try document.data(as: Card.self, decoder: decoder)
        } catch {
            print("❌ Error decoding card \(roomId): \(error)")
            throw error
        }
    }
    
    /// Get all active cards for a player
    func getActiveCardsForPlayer(playerId: String) async throws -> [Card] {
        let query = db.collection("cards")
            .whereField("players", arrayContains: ["id": playerId])
            .whereField("isActive", isEqualTo: true)
        
        let snapshot = try await query.getDocuments()
        
        let decoder = Firestore.Decoder()
        decoder.dateDecodingStrategy = .timestamp
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Card.self, decoder: decoder)
        }.filter { card in
            // Additional filter to ensure the player is actually in the card
            card.players.contains { $0.id == playerId }
        }
    }
    
    /// Add a player to an existing card
    func addPlayerToCard(roomId: String, player: Player) async throws {
        let cardRef = db.collection("cards").document(roomId)
        
        print("🔄 Adding player \(player.username) (\(player.id)) to card \(roomId)")
        
        // Get current card data
        let document = try await cardRef.getDocument()
        guard document.exists else {
            print("❌ Card document \(roomId) does not exist")
            throw FirebaseError.cardNotFound
        }
        
        let decoder = Firestore.Decoder()
        decoder.dateDecodingStrategy = .timestamp
        var card = try document.data(as: Card.self, decoder: decoder)
        
        print("📊 Current card has \(card.players.count) players: \(card.players.map { $0.username })")
        
        // Check if player is already in the card
        if !card.players.contains(where: { $0.id == player.id }) {
            // Add player to the card
            card.players.append(player)
            
            print("➕ Adding new player \(player.username), total players will be: \(card.players.count)")
            
            // Save updated card using setData instead of updateCard to avoid updateData issues
            let encoder = Firestore.Encoder()
            encoder.dateEncodingStrategy = .timestamp
            let cardData = try encoder.encode(card)
            try await cardRef.setData(cardData)
            
            // Also update member's cards list
            try await addCardToMember(memberId: player.id, cardId: roomId)
            
            print("✅ Player \(player.username) (\(player.id)) added to card \(roomId)")
        } else {
            print("ℹ️ Player \(player.username) already in card \(roomId)")
        }
    }
    
    /// End a card game (mark as inactive)
    func endCard(roomId: String) async throws {
        try await db.collection("cards").document(roomId).updateData([
            "isActive": false
        ])
        print("✅ Card \(roomId) marked as ended")
    }
    
    // MARK: - Member Operations
    
    /// Save or update member data
    func saveMember(_ member: Member) async throws {
        let memberData = try Firestore.Encoder().encode(member)
        try await db.collection("members").document(member.id).setData(memberData, merge: true)
        print("✅ Member saved to Firebase: \(member.id)")
    }
    
    /// Add a card to a member's card list
    func addCardToMember(memberId: String, cardId: String) async throws {
        try await db.collection("members").document(memberId).updateData([
            "cards": FieldValue.arrayUnion([cardId])
        ])
    }
    
    /// Get member data
    func getMember(id: String) async throws -> Member? {
        let document = try await db.collection("members").document(id).getDocument()
        return try document.data(as: Member.self)
    }
    
    /// Create a member if they don't exist
    func createMemberIfNeeded(userId: String) async throws {
        let existingMember = try await getMember(id: userId)
        if existingMember == nil {
            let newMember = Member(userId: userId, cards: [])
            try await saveMember(newMember)
        }
    }
    
    // MARK: - Real-time Listeners
    
    /// Listen for real-time updates to a card
    func listenToCard(roomId: String, completion: @escaping (Result<Card?, Error>) -> Void) -> ListenerRegistration {
        return db.collection("cards").document(roomId).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = documentSnapshot else {
                completion(.success(nil))
                return
            }
            
            guard document.exists else {
                completion(.success(nil))
                return
            }
            
            do {
                let decoder = Firestore.Decoder()
                decoder.dateDecodingStrategy = .timestamp
                let card = try document.data(as: Card.self, decoder: decoder)
                completion(.success(card))
            } catch {
                print("❌ Error decoding card in listener: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Batch Operations
    
    /// Save multiple score updates in a batch
    func batchUpdateScores(updates: [(cardId: String, holeNumber: Int, scores: [PlayerScore])]) async throws {
        let batch = db.batch()
        
        for update in updates {
            let cardRef = db.collection("cards").document(update.cardId)
            
            // This is a simplified approach - in production you might want to read first
            batch.updateData([
                "holes.\(update.holeNumber - 1).scores": update.scores.map { try! Firestore.Encoder().encode($0) }
            ], forDocument: cardRef)
        }
        
        try await batch.commit()
        print("✅ Batch score updates completed")
    }
}

// MARK: - Custom Errors
enum FirebaseError: Error, LocalizedError {
    case cardNotFound
    case holeNotFound
    case memberNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .cardNotFound:
            return "Card not found"
        case .holeNotFound:
            return "Hole not found"
        case .memberNotFound:
            return "Member not found"
        case .invalidData:
            return "Invalid data format"
        }
    }
}


