import Foundation

/// A game of *Jeopardy!*
struct JeopardyGame: Codable {
    
    // -------------------------------------------------------------------------
    // MARK:- Stored properties
    // -------------------------------------------------------------------------
    
    /// The categories in the Jeopardy! round.
    private(set) var jeopardyRoundCategories: [Category]
    
    /// The Final Jeopardy! clue.
    let finalJeopardyClue: FinalJeopardyClue
    
    /// The contestants in this game of *Jeopardy!*
    private(set) var players: [Player]
    
    // -------------------------------------------------------------------------
    // MARK:- Initializer
    // -------------------------------------------------------------------------
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jeopardyRoundCategories = try container
            .decode([Category].self, forKey: .jeopardyRoundCategories)
        finalJeopardyClue = try container
            .decode(FinalJeopardyClue.self, forKey: .finalJeopardyClue)
        players = try container.decode([Player].self, forKey: .players)
        try validateGame()
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Method
    // -------------------------------------------------------------------------
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container
            .encode(jeopardyRoundCategories, forKey: .jeopardyRoundCategories)
        try container.encode(finalJeopardyClue, forKey: .finalJeopardyClue)
        try container.encode(players, forKey: .players)
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Private methods
    // -------------------------------------------------------------------------
    
    /// Validates the category at the specified index.
    ///
    /// - Parameter index: The category index.
    private func validateCategory(at index: Int) throws {
        
        let category = jeopardyRoundCategories[index]
        
        if category.title.isEmpty {
            throw APIError.emptyCategoryTitle(categoryIndex: index)
        }
        
        let clueCount = category.clues.count
        if clueCount != 5 {
            throw APIError.invalidClueCount(clueCount, categoryIndex: index)
        }
        
        var dailyDoubleCount = 0
        for clue in category.clues {
            if clue.isDailyDouble {
                dailyDoubleCount += 1
            }
        }
        if dailyDoubleCount > 1 {
            throw APIError.multipleDailyDoubles(categoryIndex: index)
        }
        
        for clueIndex in category.clues.indices {
            try validateClue(at: clueIndex, categoryIndex: index)
        }
    }
    
    /// Validates the clue at the specified index and category.
    ///
    /// - Parameter clueIndex:     The clue index.
    /// - Parameter categoryIndex: The category index.
    private func validateClue(at clueIndex: Int, categoryIndex: Int) throws {
        
        let clue = jeopardyRoundCategories[categoryIndex].clues[clueIndex]
        let expectedPointValue = (clueIndex + 1) * 200
        
        if clue.pointValue != expectedPointValue {
            throw APIError.invalidPointValue(
                clue.pointValue,
                expectedPointValue: expectedPointValue,
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
        if clue.answer.isEmpty {
            throw APIError.emptyAnswer(
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
        if clue.correctResponse.isEmpty {
            throw APIError.emptyCorrectResponse(
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
    }
    
    /// Validates the Final Jeopardy! clue.
    private func validateFinalJeopardyClue() throws {
        if finalJeopardyClue.categoryTitle.isEmpty {
            throw APIError.emptyFinalJeopardyCategoryTitle
        }
        if finalJeopardyClue.answer.isEmpty {
            throw APIError.emptyFinalJeopardyAnswer
        }
        if finalJeopardyClue.correctResponse.isEmpty {
            throw APIError.emptyFinalJeopardyCorrectResponse
        }
    }
    
    /// Validates this game.
    private func validateGame() throws {
        
        let categoryCount = jeopardyRoundCategories.count
        if categoryCount != 6 {
            throw APIError.invalidCategoryCount(categoryCount)
        }
        for index in jeopardyRoundCategories.indices {
            try validateCategory(at: index)
        }
        
        var dailyDoubleCount = 0
        for category in jeopardyRoundCategories {
            for clue in category.clues {
                if clue.isDailyDouble {
                    dailyDoubleCount += 1
                }
            }
        }
        if dailyDoubleCount != 2 {
            throw APIError.invalidDailyDoubleCount(dailyDoubleCount)
        }
        
        try validateFinalJeopardyClue()
        
        let playerCount = players.count
        if playerCount < 3 {
            throw APIError.invalidPlayerCount
        }
        for index in players.indices {
            if players[index].name.isEmpty {
                throw APIError.emptyPlayerName(index: index)
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Nested structs
    // -------------------------------------------------------------------------
    
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
                .decode(Int.self, forKey: .pointValue)
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
    
    /// A Final Jeopardy! clue.
    struct FinalJeopardyClue: Codable {
        
        /// The category title.
        let categoryTitle: String
        
        /// The “answer.”
        let answer: String
        
        /// The correct response to this clue.
        let correctResponse: String
        
        /// Indicates whether this clue is marked as “done.”
        var isDone: Bool = false
        
        /// Creates a Final Jeopardy! clue with the specified category title,
        /// answer, and correct response.
        ///
        /// This initializer stores trimmed versions of all `String` arguments.
        ///
        /// - Parameter categoryTitle:   The category title.
        /// - Parameter answer:          The answer.
        /// - Parameter correctResponse: The correct response.
        init(categoryTitle: String, answer: String, correctResponse: String) {
            self.categoryTitle = categoryTitle
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.answer = answer
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.correctResponse = correctResponse
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            categoryTitle = try container
                .decode(String.self, forKey: .categoryTitle)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            answer = try container
                .decode(String.self, forKey: .answer)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            correctResponse = try container
                .decode(String.self, forKey: .correctResponse)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            isDone = try container.decode(Bool.self, forKey: .isDone)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(categoryTitle, forKey: .categoryTitle)
            try container.encode(answer, forKey: .answer)
            try container.encode(correctResponse, forKey: .correctResponse)
            try container.encode(isDone, forKey: .isDone)
        }
        
        private enum CodingKeys: String, CodingKey {
            case categoryTitle
            case answer
            case correctResponse
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
    
    // -------------------------------------------------------------------------
    // MARK:- Nested enums
    // -------------------------------------------------------------------------
    
    /// An API error.
    enum APIError: Error {
        
        /// An invalid number of categories.
        case invalidCategoryCount(Int)
        
        /// An empty category title.
        case emptyCategoryTitle(categoryIndex: Int)
        
        /// An invalid number of clues in a category.
        case invalidClueCount(Int, categoryIndex: Int)
        
        /// A category has more than one Daily Double.
        case multipleDailyDoubles(categoryIndex: Int)
        
        /// An invalid point value.
        case invalidPointValue(
            Int,
            expectedPointValue: Int,
            categoryIndex: Int,
            clueIndex: Int
        )
        
        /// An empty “answer.”
        case emptyAnswer(categoryIndex: Int, clueIndex: Int)
        
        /// An empty correct response.
        case emptyCorrectResponse(categoryIndex: Int, clueIndex: Int)
        
        /// An invalid number of Daily Doubles.
        case invalidDailyDoubleCount(Int)
        
        /// An empty Final Jeopardy! category title.
        case emptyFinalJeopardyCategoryTitle
        
        /// An empty Final Jeopardy! “answer.”
        case emptyFinalJeopardyAnswer
        
        /// An empty Final Jeopardy! correct response.
        case emptyFinalJeopardyCorrectResponse
        
        /// An invalid number of contestants.
        case invalidPlayerCount
        
        /// An empty contestant name.
        case emptyPlayerName(index: Int)
    }
    
    private enum CodingKeys: String, CodingKey {
        case jeopardyRoundCategories
        case finalJeopardyClue
        case players
    }
}
