import SwiftUI

/// A view that displays a contestant’s name and score.
struct PlayerView: View {
    
    /// The contestant.
    let player: Player
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    
    /// The view model that binds this view to a *Jeopardy!* game.
    @ObservedObject var viewModel: JeopardyGameViewModel
    
    /// Indicates whether the contestant’s score is currently being edited.
    @State private var editModeIsEnabled = false
    
    /// The editable score text.
    @State private var editableScoreText = ""
    
    var body: some View {
        HStack {
            VStack {
                Button(action: addPoints) {
                    Image(systemName: "arrowtriangle.up.fill")
                }
                    .disabled(responseButtonsAreDisabled)
                Button(action: deductPoints) {
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
        if player.hasRespondedToCurrentClue {
            return true
        }
        if let selectedClue = viewModel.selectedClue {
            return selectedClue.isDailyDouble && !player.canSelectClue
        }
        return true
    }
    
    /// The score color.
    private var scoreColor: Color {
        player.score < 0 ? .red : .primary
    }
    
    /// Add the selected clue’s point value to the contestant’s score.
    private func addPoints() {
        viewModel.respondToSelectedClue(for: player, correct: true)
    }
    
    /// Change the contestant’s score to the value in the *Score* text field.
    private func changeScore() {
        if let newScore = Int(editableScoreText.trimmed) {
            viewModel.setScore(to: newScore, for: player)
            editModeIsEnabled = false
            return
        }
        self.appState.errorAlert = AppState.ErrorAlert(
            title: "Invalid Input",
            message: "The value entered is not a valid score. Please try again."
        )
    }
    
    /// Deduct the selected clue’s point value from the contestant’s score.
    private func deductPoints() {
        viewModel.respondToSelectedClue(for: player, correct: false)
    }
    
    /// Enables “Edit Mode” on this view.
    private func enableEditMode() {
        editableScoreText = String(player.score)
        editModeIsEnabled = true
    }
}

#if DEBUG
struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = JeopardyGameViewModel(game: exampleGame)
        return PlayerView(player: exampleGame.players[1], viewModel: viewModel)
            .frame(width: 300)
    }
}
#endif
