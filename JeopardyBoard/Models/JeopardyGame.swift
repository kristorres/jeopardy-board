import Foundation

/// A game of *Jeopardy!*
struct JeopardyGame {
    
    /// A category on the game board.
    ///
    /// A category contains five clues which are valued by difficulty. Its title
    /// often features puns, wordplay, or shared themes.
    struct Category: Codable, Identifiable {
        
        let id = "CATEGORY-\(UUID())"
        
        /// The title of this category.
        let title: String
        
        /// The clues in this category.
        let clues: [Clue]
        
        /// Creates a category with the specified title and clues.
        ///
        /// This initializer stores a trimmed version of the `title`.
        ///
        /// - Parameter title: The title.
        /// - Parameter clues: The clues.
        init(title: String, clues: [Clue]) {
            self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            self.clues = clues
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container
                .decode(String.self, forKey: .title)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            clues = try container.decode([Clue].self, forKey: .clues)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(clues, forKey: .clues)
        }
        
        private enum CodingKeys: String, CodingKey {
            case title
            case clues
        }
    }
    
    /// A clue on the game board.
    ///
    /// All clues are presented as “answers,” and responses must be phrased in
    /// the form of a question. For example, if the clue is “This ‘Father of Our
    /// Country’ didn’t really chop down a cherry tree,” then the correct
    /// response is “Who is/was George Washington?”
    struct Clue: Codable, Identifiable {
        
        let id = "CLUE-\(UUID())"
        
        /// The point value of this clue.
        let pointValue: Int?
        
        /// The “answer.”
        let answer: String
        
        /// The correct response to this clue.
        let correctResponse: String
        
        /// Indicates whether this clue is a Daily Double.
        let isDailyDouble: Bool
        
        /// Indicates whether this clue is marked as “done.”
        var isDone: Bool = false
        
        /// Creates a Final Jeopardy! clue with the specified answer and correct
        /// response.
        ///
        /// This initializer stores trimmed versions of both `String` arguments.
        ///
        /// - Parameter answer:          The answer.
        /// - Parameter correctResponse: The correct response.
        init(answer: String, correctResponse: String) {
            self.pointValue = nil
            self.answer = answer
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.correctResponse = correctResponse
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.isDailyDouble = false
        }
        
        /// Creates a clue with the specified point value, answer, and correct
        /// response.
        ///
        /// This initializer stores trimmed versions of both `String` arguments.
        ///
        /// - Parameter pointValue:      The point value.
        /// - Parameter answer:          The answer.
        /// - Parameter correctResponse: The correct response.
        /// - Parameter isDailyDouble:   Indicates whether the clue is a
        ///                              Daily Double. The default is `false`.
        init(
            pointValue: Int,
            answer: String,
            correctResponse: String,
            isDailyDouble: Bool = false
        ) {
            self.pointValue = pointValue
            self.answer = answer
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.correctResponse = correctResponse
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.isDailyDouble = isDailyDouble
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            pointValue = try container
                .decodeIfPresent(Int.self, forKey: .pointValue)
            answer = try container
                .decode(String.self, forKey: .answer)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            correctResponse = try container
                .decode(String.self, forKey: .correctResponse)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            isDailyDouble = try container
                .decode(Bool.self, forKey: .isDailyDouble)
            isDone = try container.decode(Bool.self, forKey: .isDone)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(pointValue, forKey: .pointValue)
            try container.encode(answer, forKey: .answer)
            try container.encode(correctResponse, forKey: .correctResponse)
            try container.encode(isDailyDouble, forKey: .isDailyDouble)
            try container.encode(isDone, forKey: .isDone)
        }
        
        private enum CodingKeys: String, CodingKey {
            case pointValue
            case answer
            case correctResponse
            case isDailyDouble
            case isDone
        }
    }
    
    /// A contestant in a game of *Jeopardy!*
    struct Player: Codable, Identifiable {
        
        let id = "PLAYER-\(UUID())"
        
        /// The name of this player.
        let name: String
        
        /// The score of this player.
        let score: Int
        
        /// Indicates whether this player can select a clue.
        var canSelectClue: Bool = false
        
        /// Creates a contestant with the specified name and score.
        ///
        /// This initializer stores a trimmed version of his/her `name`.
        ///
        /// - Parameter name:  The name.
        /// - Parameter score: The score. The default is `0`.
        init(name: String, score: Int = 0) {
            self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            self.score = score
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container
                .decode(String.self, forKey: .name)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            score = try container.decode(Int.self, forKey: .score)
            canSelectClue = try container
                .decode(Bool.self, forKey: .canSelectClue)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(score, forKey: .score)
            try container.encode(canSelectClue, forKey: .canSelectClue)
        }
        
        private enum CodingKeys: String, CodingKey {
            case name
            case score
            case canSelectClue
        }
    }
    
    /// An API error.
    enum APIError: Error {
        
        /// An invalid point value.
        case invalidPointValue(Int)
        
        /// The point value of a Daily Double is missing.
        case missingDailyDoublePointValue
        
        /// An empty “answer.”
        case emptyAnswer
        
        /// An empty correct response.
        case emptyCorrectResponse
    }
}
