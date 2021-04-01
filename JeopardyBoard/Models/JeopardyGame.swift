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
    
    /// The current round in this game of *Jeopardy!*
    var currentRound: Round
    
    /// The wager for a Daily Double clue by a contestant.
    private(set) var dailyDoubleWager: Int?
    
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
        currentRound = try container.decode(Round.self, forKey: .currentRound)
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Methods
    // -------------------------------------------------------------------------
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container
            .encode(jeopardyRoundCategories, forKey: .jeopardyRoundCategories)
        try container.encode(finalJeopardyClue, forKey: .finalJeopardyClue)
        try container.encode(players, forKey: .players)
        try container.encode(currentRound, forKey: .currentRound)
    }
    
    /// Marks the selected clue as “done.”
    ///
    /// If there is currently no selected clue, or this game is currently in
    /// Final Jeopardy!, then this method will do nothing.
    mutating func markSelectedClueAsDone() {
        switch currentRound {
        case .jeopardy:
            for categoryIndex in jeopardyRoundCategories.indices {
                let currentCategory = jeopardyRoundCategories[categoryIndex]
                for clueIndex in currentCategory.clues.indices {
                    let currentClue = currentCategory.clues[clueIndex]
                    if currentClue.isSelected && !currentClue.isDone {
                        jeopardyRoundCategories[categoryIndex]
                            .clues[clueIndex]
                            .isSelected = false
                        jeopardyRoundCategories[categoryIndex]
                            .clues[clueIndex]
                            .isDone = true
                        return
                    }
                }
            }
        case .finalJeopardy:
            return
        }
    }
    
    /// Selects the specified clue.
    ///
    /// Only one clue on the game board may be selected at a time. If the
    /// selected clue is already marked as “done,” or this game is currently in
    /// Final Jeopardy!, then this method will do nothing.
    ///
    /// - Parameter clue: The clue to be selected.
    mutating func selectClue(_ clue: Clue) {
        if clue.isDone {
            return
        }
        switch currentRound {
        case .jeopardy:
            for categoryIndex in jeopardyRoundCategories.indices {
                let currentCategory = jeopardyRoundCategories[categoryIndex]
                for clueIndex in currentCategory.clues.indices {
                    let currentClue = currentCategory.clues[clueIndex]
                    if !currentClue.isDone {
                        jeopardyRoundCategories[categoryIndex]
                            .clues[clueIndex]
                            .isSelected = (currentClue.id == clue.id)
                    }
                }
            }
        case .finalJeopardy:
            return
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Nested enums
    // -------------------------------------------------------------------------
    
    /// An internal type that represents a round in a game of *Jeopardy!*
    enum Round: String, Codable {
        
        /// A value that represents the Jeopardy! round.
        case jeopardy = "Jeopardy!"
        
        /// A value that represents the Final Jeopardy! round.
        case finalJeopardy = "Final Jeopardy!"
    }
    
    private enum CodingKeys: String, CodingKey {
        case jeopardyRoundCategories
        case finalJeopardyClue
        case players
        case currentRound
    }
}
