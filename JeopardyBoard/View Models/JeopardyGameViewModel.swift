import SwiftUI

/// A view model that binds a view to a *Jeopardy!* game.
final class JeopardyGameViewModel: ObservableObject {
    
    // -------------------------------------------------------------------------
    // MARK:- Model
    // -------------------------------------------------------------------------
    
    /// The *Jeopardy!* game.
    @Published private var game: JeopardyGame
    
    // -------------------------------------------------------------------------
    // MARK:- Access to the model
    // -------------------------------------------------------------------------
    
    /// The current round in the *Jeopardy!* game.
    var currentRound: JeopardyGame.Round {
        game.currentRound
    }
    
    /// The wager for a Daily Double clue by a contestant.
    var dailyDoubleWager: Int? {
        game.dailyDoubleWager
    }
    
    /// The Final Jeopardy! clue.
    var finalJeopardyClue: FinalJeopardyClue {
        game.finalJeopardyClue
    }
    
    /// The categories in the Jeopardy! round.
    var jeopardyRoundCategories: [Category] {
        game.jeopardyRoundCategories
    }
    
    /// The contestants in the *Jeopardy!* game.
    var players: [Player] {
        game.players
    }
    
    /// The selected clue.
    var selectedClue: Clue? {
        game.selectedClue
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Initializer
    // -------------------------------------------------------------------------
    
    /// Creates a view model with the specified *Jeopardy!* game.
    ///
    /// - Parameter game: The *Jeopardy!* game.
    init(game: JeopardyGame) {
        self.game = game
    }
    
    // -------------------------------------------------------------------------
    // MARK:- Intents
    // -------------------------------------------------------------------------
    
    /// Marks the selected clue as “done.”
    ///
    /// If there is currently no selected clue, or the game is currently in the
    /// Final Jeopardy! round, then this method will do nothing.
    ///
    /// Finally, if all categories are finished, then the game will move to the
    /// Final Jeopardy! round.
    func markSelectedClueAsDone() {
        game.markSelectedClueAsDone()
    }
    
    /// Responds to the Final Jeopardy! clue.
    ///
    /// If the contestant’s response is correct, then his/her wager is added to
    /// his/her score. An incorrect response deducts the amount from his/her
    /// score.
    ///
    /// If the contestant has already given a response to the clue, or the game
    /// is currently in the Jeopardy! round, then this method will do nothing.
    ///
    /// - Parameter player:            The contestant who responded to the clue.
    /// - Parameter wager:             The Final Jeopardy! wager.
    /// - Parameter responseIsCorrect: `true` if the contestant’s response is
    ///                                correct, or `false` otherwise.
    func respondToFinalJeopardyClue(
        for player: Player,
        wager: Int,
        correct responseIsCorrect: Bool
    ) throws {
        try game.respondToFinalJeopardyClue(
            for: player,
            wager: wager,
            correct: responseIsCorrect
        )
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
    func respondToSelectedClue(
        for player: Player,
        correct responseIsCorrect: Bool
    ) {
        game.respondToSelectedClue(for: player, correct: responseIsCorrect)
    }
    
    /// Selects the specified clue.
    ///
    /// Only one clue on the game board may be selected at a time. If the
    /// selected clue is already marked as “done,” or the game is currently in
    /// the Final Jeopardy! round, then this method will do nothing.
    ///
    /// - Parameter clue: The clue to be selected.
    func selectClue(_ clue: Clue) {
        game.selectClue(clue)
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
    func setDailyDoubleWager(to wager: Int) throws {
        try game.setDailyDoubleWager(to: wager)
    }
    
    /// Sets the score of the specified contestant.
    ///
    /// - Parameter newScore: The new score.
    /// - Parameter player:   The affected contestant.
    func setScore(to newScore: Int, for player: Player) {
        game.setScore(to: newScore, for: player)
    }
}
