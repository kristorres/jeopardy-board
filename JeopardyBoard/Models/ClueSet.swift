import Foundation

/// A clue set for a game of *Jeopardy!*
struct ClueSet: Codable {
    
    /// The categories in the Jeopardy! round.
    let jeopardyRoundCategories: [Category]
    
    /// The Final Jeopardy! clue.
    let finalJeopardyClue: FinalJeopardyClue
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jeopardyRoundCategories = try container
            .decode([Category].self, forKey: .jeopardyRoundCategories)
        finalJeopardyClue = try container
            .decode(FinalJeopardyClue.self, forKey: .finalJeopardyClue)
        try validateClueSet()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container
            .encode(jeopardyRoundCategories, forKey: .jeopardyRoundCategories)
        try container.encode(finalJeopardyClue, forKey: .finalJeopardyClue)
    }
    
    /// Validates the category at the specified index.
    ///
    /// - Parameter index: The category index.
    private func validateCategory(at index: Int) throws {
        
        let category = jeopardyRoundCategories[index]
        
        if category.title.isEmpty {
            throw ValidationError.emptyCategoryTitle(categoryIndex: index)
        }
        
        let clueCount = category.clues.count
        if clueCount != JeopardyGame.clueCountPerCategory {
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
        if let image = clue.image, image.isEmpty {
            throw ValidationError.emptyImage(
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
        if clue.isDone {
            throw ValidationError.clueIsDone(
                categoryIndex: categoryIndex,
                clueIndex: clueIndex
            )
        }
    }
    
    /// Validates this clue set.
    private func validateClueSet() throws {
        
        let categoryCount = jeopardyRoundCategories.count
        if categoryCount != JeopardyGame.categoryCount {
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
        if let image = finalJeopardyClue.image, image.isEmpty {
            throw ValidationError.emptyFinalJeopardyImage
        }
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
        
        /// An error that denotes an empty image filename.
        case emptyImage(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes a clue already marked as “done.”
        case clueIsDone(categoryIndex: Int, clueIndex: Int)
        
        /// An error that denotes an incorrect number of Daily Doubles.
        case incorrectDailyDoubleCount(Int)
        
        /// An error that denotes an empty Final Jeopardy! category title.
        case emptyFinalJeopardyCategoryTitle
        
        /// An error that denotes an empty Final Jeopardy! “answer.”
        case emptyFinalJeopardyAnswer
        
        /// An error that denotes an empty Final Jeopardy! correct response.
        case emptyFinalJeopardyCorrectResponse
        
        /// An error that denotes an empty Final Jeopardy! image filename.
        case emptyFinalJeopardyImage
    }
    
    /// An internal type that contains the keys for encoding and decoding.
    private enum CodingKeys: String, CodingKey {
        case jeopardyRoundCategories
        case finalJeopardyClue
    }
}
