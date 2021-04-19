import SwiftUI

/// A view that displays an interactive *Jeopardy!* game.
struct GameView: View {
    
    /// The view model that binds this view to a *Jeopardy!* game.
    @ObservedObject var viewModel: JeopardyGameViewModel
    
    /// The contestant name search text.
    @State private var playerNameSearchText = ""
    
    /// The info of the error alert that is currently presented onscreen.
    @State private var errorAlertInfo: ErrorAlertItem?
    
    var body: some View {
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
                    }
                }
                else {
                    JeopardyBoardView(viewModel: viewModel)
                }
            }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing, .bottom])
            VStack(spacing: 0) {
                TextField("Contestant Search", text: $playerNameSearchText)
                    .textFieldStyle(TrebekTextFieldStyle())
                    .padding()
                Divider()
                ScrollView(.vertical) {
                    ForEach(players) {
                        PlayerView(
                            player: $0,
                            viewModel: viewModel,
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
    
    /// The filtered contestants as a result of the name search.
    private var players: [Player] {
        viewModel.players.filter { player in
            if viewModel.currentRound == .finalJeopardy {
                return player.score > 0
            }
            let searchText = playerNameSearchText.uppercased().trimmed
            if searchText.isEmpty {
                return true
            }
            let uppercasePlayerName = player.name.uppercased()
            return uppercasePlayerName.contains(searchText)
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
