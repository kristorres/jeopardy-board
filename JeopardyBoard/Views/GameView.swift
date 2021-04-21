import SwiftUI

/// A view that displays an interactive *Jeopardy!* game.
struct GameView: View {
    
    /// The view model that binds this view to a *Jeopardy!* game.
    @ObservedObject var viewModel: JeopardyGameViewModel
    
    /// Indicates whether a Daily Double clue is already selected.
    @State private var dailyDoubleIsAlreadySelected = false
    
    /// The contestant name search text.
    @State private var playerNameSearchText = ""
    
    /// The wager text.
    @State private var wagerText = ""
    
    /// The action to perform when a contestant’s wager is submitted.
    @State private var onSubmitWager: ((Int) throws -> Void)? {
        didSet {
            wagerText = ""
        }
    }
    
    /// Indicates whether the leaderboard is visible.
    @State private var leaderboardIsVisible = false
    
    /// The info of the error alert that is currently presented onscreen.
    @State private var errorAlertInfo: ErrorAlertItem?
    
    var body: some View {
        if leaderboardIsVisible {
            LeaderboardView(players: viewModel.players) {
                self.leaderboardIsVisible = false
            }
        }
        else {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Image("jeopardy-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding()
                    if viewModel.currentRound == .finalJeopardy {
                        FinalJeopardyClueView(clue: viewModel.finalJeopardyClue)
                    }
                    else if let clue = viewModel.selectedClue {
                        ClueView(clue: clue) {
                            self.viewModel.markSelectedClueAsDone()
                            self.dailyDoubleIsAlreadySelected = false
                            self.onSubmitWager = nil
                        }
                            .onAppear {
                                if clue.isDailyDouble {
                                    if self.dailyDoubleIsAlreadySelected {
                                        return
                                    }
                                    self.displayWagerSection()
                                    self.dailyDoubleIsAlreadySelected = true
                                }
                            }
                    }
                    else {
                        JeopardyBoardView(viewModel: viewModel)
                    }
                }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing, .bottom])
                VStack(spacing: 0) {
                    Button("VIEW LEADERBOARD") {
                        self.leaderboardIsVisible = true
                    }
                        .buttonStyle(TrebekButtonStyle())
                        .padding()
                    Divider()
                    if onSubmitWager != nil {
                        HStack {
                            TextField(
                                "Wager",
                                text: $wagerText,
                                onCommit: submitWager
                            )
                                .textFieldStyle(TrebekTextFieldStyle())
                            Button("CONFIRM", action: submitWager)
                                .buttonStyle(TrebekButtonStyle())
                                .disabled(wagerText.trimmed.isEmpty)
                        }
                            .padding()
                        Divider()
                    }
                    TextField("Contestant Search", text: $playerNameSearchText)
                        .textFieldStyle(TrebekTextFieldStyle())
                        .padding()
                    Divider()
                    ScrollView(.vertical) {
                        ForEach(players) {
                            PlayerView(
                                player: $0,
                                viewModel: viewModel,
                                onSubmitWager: $onSubmitWager,
                                errorAlertInfo: $errorAlertInfo
                            )
                        }
                    }
                        .frame(maxWidth: .infinity)
                }
                    .frame(width: 300)
                    .frame(maxHeight: .infinity)
                    .background(Color("Player List Panel Background"))
            }
                .alert(item: $errorAlertInfo) {
                    Alert(title: Text($0.title), message: Text($0.message))
                }
        }
    }
    
    /// The filtered contestants as a result of the name search.
    private var players: [Player] {
        viewModel.players.filter { player in
            let searchText = playerNameSearchText.uppercased().trimmed
            if searchText.isEmpty {
                return true
            }
            let uppercasePlayerName = player.name.uppercased()
            return uppercasePlayerName.contains(searchText)
        }
    }
    
    /// Displays the wager section above the list of contestants.
    private func displayWagerSection() {
        onSubmitWager = {
            try self.viewModel.setDailyDoubleWager(to: $0)
        }
    }
    
    /// Submits a contestant’s wager.
    private func submitWager() {
        guard let onSubmitWager = self.onSubmitWager else {
            return
        }
        if wagerText.trimmed.isEmpty {
            return
        }
        guard let wager = Int(wagerText.trimmed) else {
            errorAlertInfo = ErrorAlertItem(
                title: "Invalid Input",
                message: "The value entered is not a valid wager. "
                    + "Please try again."
            )
            return
        }
        do {
            try onSubmitWager(wager)
            self.onSubmitWager = nil
        }
        catch let invalidWagerError as JeopardyGame.InvalidWagerError {
            errorAlertInfo = ErrorAlertItem(
                title: "Invalid Wager",
                message: invalidWagerError.message
            )
        }
        catch {
        }
    }
}

fileprivate extension JeopardyGame.InvalidWagerError {
    
    /// The error message.
    var message: String {
        switch self {
        case .forbidden:
            return "You are forbidden from wagering that amount!"
        case .outOfRange(let minimumWager, let maximumWager):
            return "The wager must be between "
                + "\(minimumWager) and \(maximumWager)."
        }
    }
}

#if DEBUG
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = JeopardyGameViewModel(game: exampleGame)
        return GameView(viewModel: viewModel).scaledToWindow()
    }
}
#endif
