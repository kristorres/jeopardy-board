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
    
    /// The contestants in this *Jeopardy!* game.
    private(set) var players: [Player]
    
    /// The current round in this *Jeopardy!* game.
    private(set) var currentRound: Round = .jeopardy {
        didSet {
            if currentRound == .finalJeopardy {
                players = players.filter {
                    $0.score > 0
                }
            }
        }
    }
    
    /// The selected clue.
    private(set) var selectedClue: Clue?
    
    /// The wager for a Daily Double clue by a contestant.
    private(set) var dailyDoubleWager: Int?
    
    // -------------------------------------------------------------------------
    // MARK:- Initializers
    // -------------------------------------------------------------------------
    
    /// Creates a new game with the specified clue set and contestants.
    ///
    /// The starting player is chosen randomly.
    ///
    /// - Parameter clueSet: The clue set.
    /// - Parameter players: The contestants.
    init(clueSet: ClueSet, players: [Player]) {
        
        self.jeopardyRoundCategories = clueSet.jeopardyRoundCategories
        self.finalJeopardyClue = clueSet.finalJeopardyClue
        self.players = players
        
        let startingPlayerIndex = Int.random(in: self.players.indices)
        for index in players.indices {
            self.players[index].canSelectClue = (index == startingPlayerIndex)
        }
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
    /// If there is currently no selected clue, or this game is currently in the
    /// Final Jeopardy! round, then this method will do nothing.
    ///
    /// Finally, if all categories are finished, then the game will move to the
    /// Final Jeopardy! round.
    mutating func markSelectedClueAsDone() {
        guard let selectedClue = self.selectedClue else {
            return
        }
        switch currentRound {
        case .jeopardy:
            self.selectedClue = nil
            for categoryIndex in jeopardyRoundCategories.indices {
                let clues = jeopardyRoundCategories[categoryIndex].clues
                if let clueIndex = clues.firstIndex(matching: selectedClue) {
                    if !clues[clueIndex].isDone {
                        jeopardyRoundCategories[categoryIndex]
                            .clues[clueIndex]
                            .isDone = true
                    }
                }
            }
            if jeopardyRoundCategories.allSatisfy({ $0.isDone }) {
                currentRound = .finalJeopardy
            }
        case .finalJeopardy:
            return
        }
    }
    
    /// Responds to the Final Jeopardy! clue.
    ///
    /// If the contestant’s response is correct, then his/her wager is added to
    /// his/her score. An incorrect response deducts the amount from his/her
    /// score.
    ///
    /// If the contestant has already given a response to the clue, or this game
    /// is currently in the Jeopardy! round, then this method will do nothing.
    ///
    /// - Parameter player:            The contestant who responded to the clue.
    /// - Parameter wager:             The Final Jeopardy! wager.
    /// - Parameter responseIsCorrect: `true` if the contestant’s response is
    ///                                correct, or `false` otherwise.
    mutating func respondToFinalJeopardyClue(
        for player: Player,
        wager: Int,
        correct responseIsCorrect: Bool
    ) throws {
        if !player.canRespondToCurrentClue {
            return
        }
        switch currentRound {
        case .jeopardy:
            return
        case .finalJeopardy:
            if Self.forbiddenWagers.contains(wager) {
                throw InvalidWagerError.forbidden
            }
            if wager < 0 || wager > player.score {
                throw InvalidWagerError.outOfRange(
                    minimumWager: 0,
                    maximumWager: player.score
                )
            }
            ruleResponse(for: player, amount: wager, correct: responseIsCorrect)
        }
    }
    
    /// Responds to the selected clue.
    ///
    /// If the contestant’s response is correct, then the selected clue’s point
    /// value is added to his/her score, and he/she may select a new clue from
    /// the game board. An incorrect response deducts the amount from his/her
    /// score and allows the other contestants the opportunity to ring in and
    /// respond.
    ///
    /// If the clue is a Daily Double, then the contestant’s wager is added or
    /// subtracted instead depending on his/her response. Whether or not he/she
    /// responds correctly, he/she chooses the next clue.
    ///
    /// If the contestant has already given a response to the clue, then this
    /// method will do nothing.
    ///
    /// - Parameter player:            The contestant who responded to the clue.
    /// - Parameter responseIsCorrect: `true` if the contestant’s response is
    ///                                correct, or `false` otherwise.
    mutating func respondToSelectedClue(
        for player: Player,
        correct responseIsCorrect: Bool
    ) {
        if !player.canRespondToCurrentClue {
            return
        }
        if let playerIndex = players.firstIndex(matching: player) {
            if let wager = dailyDoubleWager {
                if !players[playerIndex].canSelectClue {
                    return
                }
                ruleResponse(
                    for: player,
                    amount: wager,
                    correct: responseIsCorrect
                )
                dailyDoubleWager = nil
                return
            }
            if let clue = selectedClue {
                ruleResponse(
                    for: player,
                    amount: clue.pointValue,
                    correct: responseIsCorrect
                )
                if responseIsCorrect {
                    for index in players.indices {
                        players[index].canSelectClue = (index == playerIndex)
                        players[index].canRespondToCurrentClue = false
                    }
                }
            }
        }
    }
    
    /// Selects the specified clue.
    ///
    /// Only one clue on the game board may be selected at a time. If the
    /// selected clue is already marked as “done,” or this game is currently in
    /// the Final Jeopardy! round, then this method will do nothing.
    ///
    /// - Parameter clue: The clue to be selected.
    mutating func selectClue(_ clue: Clue) {
        if clue.isDone {
            return
        }
        switch currentRound {
        case .jeopardy:
            selectedClue = clue
            for playerIndex in players.indices {
                let canRespond = (clue.isDailyDouble)
                    ? players[playerIndex].canSelectClue
                    : true
                players[playerIndex].canRespondToCurrentClue = canRespond
            }
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
            let maximumWager = max(player.score, Self.maximumCluePointValue)
            if wager < Self.minimumDailyDoubleWager || wager > maximumWager {
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
    /// - Parameter player:   The affected contestant.
    mutating func setScore(to newScore: Int, for player: Player) {
        if let playerIndex = players.firstIndex(matching: player) {
            players[playerIndex].score = newScore
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Private method
    // -------------------------------------------------------------------------
    
    /// Rules the specified contestant’s response to the current clue.
    ///
    /// - Parameter player:            The contestant who responded to the clue.
    /// - Parameter amount:            The amount to add or deduct.
    /// - Parameter responseIsCorrect: `true` if the contestant’s response is
    ///                                correct, or `false` otherwise.
    private mutating func ruleResponse(
        for player: Player,
        amount: Int,
        correct responseIsCorrect: Bool
    ) {
        if let playerIndex = players.firstIndex(matching: player) {
            let changeInScore = responseIsCorrect ? +amount : -amount
            players[playerIndex].score = player.score + changeInScore
            players[playerIndex].canRespondToCurrentClue = false
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Type properties
    // -------------------------------------------------------------------------
    
    /// The number of categories in the Jeopardy! round.
    static let categoryCount = 6
    
    /// The number of clues in each category.
    static let clueCountPerCategory = 5
    
    /// The highest clue value available in the Jeopardy! round.
    static let maximumCluePointValue = 1000
    
    /// The minimum wager allowed for a Daily Double clue.
    static let minimumDailyDoubleWager = 5
    
    /// The forbidden wagers.
    static let forbiddenWagers = [69, 666, 14, 88, 1488]
    
    // -------------------------------------------------------------------------
    // MARK:- Nested enums
    // -------------------------------------------------------------------------
    
    /// An internal type that represents a round in a *Jeopardy!* game.
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
