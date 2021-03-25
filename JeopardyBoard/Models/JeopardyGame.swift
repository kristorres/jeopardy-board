import Foundation

/// A game of *Jeopardy!*
struct JeopardyGame {
    
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
        init(answer: String, correctResponse: String) throws {
            self.pointValue = nil
            self.answer = answer
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.correctResponse = correctResponse
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.isDailyDouble = false
            try validateProperties()
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
        ///                              Daily Double.
        init(
            pointValue: Int,
            answer: String,
            correctResponse: String,
            isDailyDouble: Bool = false
        ) throws {
            self.pointValue = pointValue
            self.answer = answer
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.correctResponse = correctResponse
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.isDailyDouble = isDailyDouble
            try validateProperties()
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
            try validateProperties()
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(pointValue, forKey: .pointValue)
            try container.encode(answer, forKey: .answer)
            try container.encode(correctResponse, forKey: .correctResponse)
            try container.encode(isDailyDouble, forKey: .isDailyDouble)
            try container.encode(isDone, forKey: .isDone)
        }
        
        /// Validates all properties of this clue.
        private func validateProperties() throws {
            if let pointValue = pointValue, pointValue <= 0 {
                throw APIError.invalidPointValue(pointValue)
            }
            if isDailyDouble && pointValue == nil {
                throw APIError.missingDailyDoublePointValue
            }
            if answer.isEmpty {
                throw APIError.emptyAnswer
            }
            if correctResponse.isEmpty {
                throw APIError.emptyCorrectResponse
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case pointValue
            case answer
            case correctResponse
            case isDailyDouble
            case isDone
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
