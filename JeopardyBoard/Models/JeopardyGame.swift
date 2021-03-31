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
        currentRound = try container.decode(Round.self, forKey: .currentRound)
        try validateGame()
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Methods
    // -------------------------------------------------------------------------
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container
            .encode(jeopardyRoundCategories, forKey: .jeopardyRoundCategories)
        try container.encode(finalJeopardyClue, forKey: .finalJeopardyClue)
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
    // MARK:- Private methods
    // -------------------------------------------------------------------------
    
    /// Validates the category at the specified index.
    ///
    /// - Parameter index: The category index.
    private func validateCategory(at index: Int) throws {
        
        let category = jeopardyRoundCategories[index]
        
        if category.title.isEmpty {
            throw ValidationError.emptyCategoryTitle(categoryIndex: index)
        }
        
        let clueCount = category.clues.count
        if clueCount != 5 {
            throw ValidationError.incorrectClueCount(
                clueCount,
                categoryIndex: index
            )
        }
        
        var dailyDoubleCount = 0
        for clue in category.clues {
            if clue.isDailyDouble {
                dailyDoubleCount += 1
            }
        }
        if dailyDoubleCount > 1 {
            throw ValidationError.multipleDailyDoublesInCategory(
                categoryIndex: index
            )
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
            throw ValidationError.incorrectPointValue(
                clue.pointValue,
                expectedPointValue: expectedPointValue,
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
        if clue.answer.isEmpty {
            throw ValidationError.emptyAnswer(
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
        if clue.correctResponse.isEmpty {
            throw ValidationError.emptyCorrectResponse(
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
    }
    
    /// Validates the Final Jeopardy! clue.
    private func validateFinalJeopardyClue() throws {
        if finalJeopardyClue.categoryTitle.isEmpty {
            throw ValidationError.emptyFinalJeopardyCategoryTitle
        }
        if finalJeopardyClue.answer.isEmpty {
            throw ValidationError.emptyFinalJeopardyAnswer
        }
        if finalJeopardyClue.correctResponse.isEmpty {
            throw ValidationError.emptyFinalJeopardyCorrectResponse
        }
    }
    
    /// Validates this game.
    private func validateGame() throws {
        
        let categoryCount = jeopardyRoundCategories.count
        if categoryCount != 6 {
            throw ValidationError.incorrectCategoryCount(categoryCount)
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
            throw ValidationError.incorrectDailyDoubleCount(dailyDoubleCount)
        }
        
        try validateFinalJeopardyClue()
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
    
    /// A validation error.
    enum ValidationError: Error {
        
        /// An error that denotes an incorrect number of categories.
        case incorrectCategoryCount(Int)
        
        /// An error that denotes an empty category title.
        case emptyCategoryTitle(categoryIndex: Int)
        
        /// An error that denotes an incorrect number of clues in a category.
        case incorrectClueCount(Int, categoryIndex: Int)
        
        /// An error that denotes a category with more than one Daily Double.
        case multipleDailyDoublesInCategory(categoryIndex: Int)
        
        /// An error that denotes an incorrect point value.
        case incorrectPointValue(
            Int,
            expectedPointValue: Int,
            categoryIndex: Int,
            clueIndex: Int
        )
        
        /// An error that denotes an empty “answer.”
        case emptyAnswer(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes an empty correct response.
        case emptyCorrectResponse(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes an incorrect number of Daily Doubles.
        case incorrectDailyDoubleCount(Int)
        
        /// An error that denotes an empty Final Jeopardy! category title.
        case emptyFinalJeopardyCategoryTitle
        
        /// An error that denotes an empty Final Jeopardy! “answer.”
        case emptyFinalJeopardyAnswer
        
        /// An error that denotes an empty Final Jeopardy! correct response.
        case emptyFinalJeopardyCorrectResponse
    }
    
    private enum CodingKeys: String, CodingKey {
        case jeopardyRoundCategories
        case finalJeopardyClue
        case currentRound
    }
}
