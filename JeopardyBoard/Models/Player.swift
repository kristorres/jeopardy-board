import Foundation

/// A player in a *Jeopardy!* game.
struct Player: Codable, Identifiable {
    
    let id = "PLAYER-\(UUID())"
    
    /// The name of this player.
    let name: String
    
    /// The score of this player.
    var score: Int
    
    /// Indicates whether this player can select a clue.
    var canSelectClue: Bool = false
    
    /// Indicates whether this player can respond to the current clue.
    var canRespondToCurrentClue: Bool = false
    
    /// Creates a player with the specified name and score.
    ///
    /// This initializer stores a trimmed version of his/her `name`.
    ///
    /// - Parameter name:  The name.
    /// - Parameter score: The score. The default is `0`.
    init(name: String, score: Int = 0) {
        self.name = name.trimmed
        self.score = score
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name).trimmed
        score = try container.decode(Int.self, forKey: .score)
        canSelectClue = try container.decode(Bool.self, forKey: .canSelectClue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(score, forKey: .score)
        try container.encode(canSelectClue, forKey: .canSelectClue)
    }
    
    /// An internal type that contains the keys for encoding and decoding.
    private enum CodingKeys: String, CodingKey {
        case name
        case score
        case canSelectClue
    }
}
