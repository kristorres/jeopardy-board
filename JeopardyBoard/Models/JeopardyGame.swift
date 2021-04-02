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
    var currentRound: Round = .jeopardy
    
    /// The selected clue.
    private(set) var selectedClue: Clue?
    
    /// The wager for a Daily Double clue by a contestant.
    private(set) var dailyDoubleWager: Int?
    
    // -------------------------------------------------------------------------
    // MARK:- Initializers
    // -------------------------------------------------------------------------
    
    /// Creates a game with the specified clue set and contestants.
    ///
    /// - Parameter clueSet: The clue set.
    /// - Parameter players: The contestants.
    init(clueSet: ClueSet, players: [Player]) {
        self.jeopardyRoundCategories = clueSet.jeopardyRoundCategories
        self.finalJeopardyClue = clueSet.finalJeopardyClue
        self.players = players
    }
    
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
    
    /// Adds the selected clue’s point value to the specified contestant’s
    /// score.
    ///
    /// If the clue is a Daily Double, then the contestant’s wager is added to
    /// his/her score instead. After this method is called, he/she can select
    /// the next clue.
    ///
    /// - Parameter player: The player who gave the correct response to the
    ///                     selected clue.
    mutating func awardPoints(to player: Player) {
        if let playerIndex = players.firstIndex(matching: player) {
            if let wager = dailyDoubleWager {
                if !players[playerIndex].canSelectClue {
                    return
                }
                players[playerIndex].score += wager
                dailyDoubleWager = nil
                return
            }
            if let clue = selectedClue {
                players[playerIndex].score += clue.pointValue
                for index in players.indices {
                    players[index].canSelectClue = (index == playerIndex)
                }
            }
        }
    }
    
    /// Subtracts the selected clue’s point value from the specified
    /// contestant’s score.
    ///
    /// If the clue is a Daily Double, then the contestant’s wager is subtracted
    /// from his/her score instead.
    ///
    /// - Parameter player: The player who gave an incorrect response to the
    ///                     selected clue.
    mutating func deductPoints(from player: Player) {
        if let playerIndex = players.firstIndex(matching: player) {
            if let wager = dailyDoubleWager {
                if !players[playerIndex].canSelectClue {
                    return
                }
                players[playerIndex].score -= wager
                dailyDoubleWager = nil
                return
            }
            if let clue = selectedClue {
                players[playerIndex].score -= clue.pointValue
            }
        }
    }
    
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
        if selectedClue == nil {
            return
        }
        switch currentRound {
        case .jeopardy:
            selectedClue = nil
            for categoryIndex in jeopardyRoundCategories.indices {
                let category = jeopardyRoundCategories[categoryIndex]
                for clueIndex in category.clues.indices {
                    let clue = category.clues[clueIndex]
                    if !clue.isDone {
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
            selectedClue = clue
        case .finalJeopardy:
            return
        }
    }
    
    /// Sets the wager for a Daily Double clue.
    ///
    /// Only the contestant who selected the Daily Double can declare a wager.
    /// The minimum wager allowed is 5 points, and the maximum wager allowed is
    /// his/her entire score (known as a “true Daily Double”) or 1,000 points,
    /// whichever is greater.
    ///
    /// If there is currently no selected clue, or the selected clue is not a
    /// Daily Double, then this method will do nothing.
    ///
    /// - Parameter wager: The contestant’s wager.
    mutating func setDailyDoubleWager(to wager: Int) throws {
        guard let clue = selectedClue, clue.isDailyDouble else {
            return
        }
        if Self.forbiddenWagers.contains(wager) {
            throw InvalidWagerError.forbidden
        }
        if let playerIndex = players.firstIndex(where: { $0.canSelectClue }) {
            let player = players[playerIndex]
            let maximumWager = max(player.score, 1000)
            if (wager < Self.minimumDailyDoubleWager || wager > maximumWager) {
                throw InvalidWagerError.outOfRange(
                    minimumWager: Self.minimumDailyDoubleWager,
                    maximumWager: maximumWager
                )
            }
            dailyDoubleWager = wager
        }
    }
    
    /// Sets the score of the specified contestant.
    ///
    /// - Parameter newScore: The new score.
    /// - Parameter player:   The affected player.
    mutating func setScore(to newScore: Int, for player: Player) {
        if let playerIndex = players.firstIndex(matching: player) {
            players[playerIndex].score = newScore
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Type properties
    // -------------------------------------------------------------------------
    
    /// The minimum wager allowed for a Daily Double clue.
    static let minimumDailyDoubleWager = 5
    
    /// The forbidden wagers.
    static let forbiddenWagers = [69, 666, 14, 88, 1488]
    
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
    
    /// An error on invalid wagering.
    enum InvalidWagerError: Error {
        
        /// An error that denotes an out-of-range wager.
        case outOfRange(minimumWager: Int, maximumWager: Int)
        
        /// An error that denotes a wager that is deemed inappropriate.
        case forbidden
    }
    
    /// An internal type that contains the keys for encoding and decoding.
    private enum CodingKeys: String, CodingKey {
        case jeopardyRoundCategories
        case finalJeopardyClue
        case players
        case currentRound
    }
}
