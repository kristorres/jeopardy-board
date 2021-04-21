import SwiftUI

/// A view that displays a contestant’s name and score.
struct PlayerView: View {
    
    /// The contestant.
    let player: Player
    
    /// The view model that binds this view to a *Jeopardy!* game.
    @ObservedObject var viewModel: JeopardyGameViewModel
    
    /// A binding to the action to perform when a contestant’s wager is
    /// submitted.
    @Binding var onSubmitWager: ((Int) throws -> Void)?
    
    /// A binding to the info of the error alert that is currently presented
    /// onscreen.
    @Binding var errorAlertInfo: ErrorAlertItem?
    
    /// Indicates whether the contestant’s score is currently being edited.
    @State private var editModeIsEnabled = false
    
    /// The editable score text.
    @State private var editableScoreText = ""
    
    var body: some View {
        HStack {
            VStack {
                Button(action: respondToClue(correct: true)) {
                    Image(systemName: "arrowtriangle.up.fill")
                }
                    .disabled(responseButtonsAreDisabled)
                Button(action: respondToClue(correct: false)) {
                    Image(systemName: "arrowtriangle.down.fill")
                }
                    .disabled(responseButtonsAreDisabled)
            }
            VStack(alignment: .leading) {
                Text(player.name).font(.custom("PT Sans", size: 20))
                if editModeIsEnabled {
                    TextField(
                        "Score",
                        text: $editableScoreText,
                        onCommit: changeScore
                    )
                        .textFieldStyle(TrebekTextFieldStyle())
                }
                else {
                    Text("\(player.score)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(scoreColor)
                }
            }
            if !editModeIsEnabled {
                Spacer(minLength: 6)
                Button(action: enableEditMode) {
                    Image(systemName: "pencil")
                }
                    .buttonStyle(TrebekButtonStyle())
            }
        }
            .padding()
            .background(backgroundColor)
    }
    
    /// The background color of this view.
    private var backgroundColor: Color {
        player.canSelectClue ? Color.trebekBlue.opacity(0.5) : .clear
    }
    
    /// Indicates whether the response buttons are disabled.
    private var responseButtonsAreDisabled: Bool {
        onSubmitWager != nil || !player.canRespondToCurrentClue
    }
    
    /// The score color.
    private var scoreColor: Color {
        player.score < 0 ? .red : .primary
    }
    
    /// Change the contestant’s score to the value in the *Score* text field.
    private func changeScore() {
        if let newScore = Int(editableScoreText.trimmed) {
            viewModel.setScore(to: newScore, for: player)
            editModeIsEnabled = false
            return
        }
        errorAlertInfo = ErrorAlertItem(
            title: "Invalid Input",
            message: "The value entered is not a valid score. Please try again."
        )
    }
    
    /// Enables “Edit Mode” on this view.
    private func enableEditMode() {
        editableScoreText = String(player.score)
        editModeIsEnabled = true
    }
    
    /// Responds to the current clue.
    ///
    /// If the contestant’s response is correct, then the selected clue’s point
    /// value (or his/her Daily Double wager) is added to his/her score. If the
    /// game is currently in the Final Jeopardy! round, then the wager section
    /// will appear above the list of contestants instead.
    ///
    /// An incorrect response deducts that amount from the contestant’s score.
    ///
    /// - Parameter responseIsCorrect: `true` if the contestant’s response is
    ///                                correct, or `false` otherwise.
    ///
    /// - Returns: The action to perform when ruling the contestant’s response.
    private func respondToClue(
        correct responseIsCorrect: Bool
    ) -> (() -> Void) {
        return {
            switch self.viewModel.currentRound {
            case .jeopardy:
                self.viewModel.respondToSelectedClue(
                    for: player,
                    correct: responseIsCorrect
                )
            case .finalJeopardy:
                self.onSubmitWager = {
                    try self.viewModel.respondToFinalJeopardyClue(
                        for: player,
                        wager: $0,
                        correct: responseIsCorrect
                    )
                }
            }
        }
    }
}

#if DEBUG
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = JeopardyGameViewModel(game: exampleGame)
        return PlayerView(
            player: exampleGame.players[1],
            viewModel: viewModel,
            onSubmitWager: .constant(nil),
            errorAlertInfo: .constant(nil)
        )
            .frame(width: 300)
    }
}
#endif
