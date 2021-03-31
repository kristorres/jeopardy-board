import Foundation

/// A clue on the game board.
///
/// All clues are presented as “answers,” and responses must be phrased in the
/// form of a question. For example, if the clue is “This ‘Father of Our
/// Country’ didn’t really chop down a cherry tree,” then the correct response
/// is “Who is/was George Washington?”
struct Clue: Codable, Identifiable {
    
    let id = "CLUE-\(UUID())"
    
    /// The point value of this clue.
    let pointValue: Int
    
    /// The “answer.”
    let answer: String
    
    /// The correct response to this clue.
    let correctResponse: String
    
    /// Indicates whether this clue is a Daily Double.
    let isDailyDouble: Bool
    
    /// Indicates whether this clue is selected.
    var isSelected: Bool = false
    
    /// Indicates whether this clue is marked as “done.”
    var isDone: Bool = false
    
    /// Creates a clue with the specified point value, answer, and correct
    /// response.
    ///
    /// This initializer stores trimmed versions of both `answer` and
    /// `correctResponse`.
    ///
    /// - Parameter pointValue:      The point value.
    /// - Parameter answer:          The answer.
    /// - Parameter correctResponse: The correct response.
    /// - Parameter isDailyDouble:   `true` if the clue is a Daily Double, or
    ///                              `false` otherwise. The default is `false`.
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
        pointValue = try container.decode(Int.self, forKey: .pointValue)
        answer = try container
            .decode(String.self, forKey: .answer)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        correctResponse = try container
            .decode(String.self, forKey: .correctResponse)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        isDailyDouble = try container.decode(Bool.self, forKey: .isDailyDouble)
        isDone = try container.decode(Bool.self, forKey: .isDone)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pointValue, forKey: .pointValue)
        try container.encode(answer, forKey: .answer)
        try container.encode(correctResponse, forKey: .correctResponse)
        try container.encode(isDailyDouble, forKey: .isDailyDouble)
        try container.encode(isDone, forKey: .isDone)
    }
    
    /// An internal type that contains the keys for encoding and decoding.
    private enum CodingKeys: String, CodingKey {
        case pointValue
        case answer
        case correctResponse
        case isDailyDouble
        case isDone
    }
}
