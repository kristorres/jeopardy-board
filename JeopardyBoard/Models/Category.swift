import Foundation

/// A category on the game board.
///
/// A category contains five clues which are valued by difficulty. Its title
/// often features puns, wordplay, or shared themes.
struct Category: Codable, Identifiable {
    
    let id = "CATEGORY-\(UUID())"
    
    /// The title of this category.
    let title: String
    
    /// The clues in this category.
    var clues: [Clue]
    
    /// Indicates whether this category is marked as “done.”
    var isDone: Bool {
        clues.allSatisfy { $0.isDone }
    }
    
    /// Creates a category with the specified title and clues.
    ///
    /// This initializer stores a trimmed version of `title`.
    ///
    /// - Parameter title: The title.
    /// - Parameter clues: The clues.
    init(title: String, clues: [Clue]) {
        self.title = title.trimmed
        self.clues = clues
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title).trimmed
        clues = try container.decode([Clue].self, forKey: .clues)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(clues, forKey: .clues)
    }
    
    /// An internal type that contains the keys for encoding and decoding.
    private enum CodingKeys: String, CodingKey {
        case title
        case clues
    }
}
