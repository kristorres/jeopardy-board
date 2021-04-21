import Foundation

/// A Final Jeopardy! clue.
struct FinalJeopardyClue: Codable {
    
    /// The category title.
    let categoryTitle: String
    
    /// The “answer.”
    let answer: String
    
    /// The correct response to this clue.
    let correctResponse: String
    
    /// The filename of the image that accompanies this clue.
    let image: String?
    
    /// Creates a Final Jeopardy! clue with the specified category title,
    /// answer, and correct response.
    ///
    /// This initializer stores trimmed versions of `categoryTitle`, `answer`,
    /// `correctResponse`, and `image`.
    ///
    /// - Parameter categoryTitle:   The category title.
    /// - Parameter answer:          The answer.
    /// - Parameter correctResponse: The correct response.
    /// - Parameter image:           The filename of the accompanying image.
    ///                              The default is `nil`.
    init(
        categoryTitle: String,
        answer: String,
        correctResponse: String,
        image: String? = nil
    ) {
        self.categoryTitle = categoryTitle.trimmed
        self.answer = answer.trimmed
        self.correctResponse = correctResponse.trimmed
        self.image = image?.trimmed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categoryTitle = try container
            .decode(String.self, forKey: .categoryTitle)
            .trimmed
        answer = try container
            .decode(String.self, forKey: .answer)
            .trimmed
        correctResponse = try container
            .decode(String.self, forKey: .correctResponse)
            .trimmed
        image = try container
            .decodeIfPresent(String.self, forKey: .image)?
            .trimmed
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(categoryTitle, forKey: .categoryTitle)
        try container.encode(answer, forKey: .answer)
        try container.encode(correctResponse, forKey: .correctResponse)
        try container.encodeIfPresent(image, forKey: .image)
    }
    
    /// An internal type that contains the keys for encoding and decoding.
    private enum CodingKeys: String, CodingKey {
        case categoryTitle
        case answer
        case correctResponse
        case image
    }
}
