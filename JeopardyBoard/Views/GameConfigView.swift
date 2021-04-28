import SwiftUI

/// A view to create and start a new *Jeopardy!* game.
///
/// The host can upload the clue set and enter the contestants.
struct GameConfigView: View {
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    
    /// The uploaded clue set.
    @State private var clueSet: ClueSet?
    
    /// The filename of the uploaded clue set.
    @State private var clueSetFilename: String?
    
    /// The contestants in the game.
    @State private var players = [Player]()
    
    /// The name of the new contestant to add.
    @State private var newPlayerName = ""
    
    /// The info of the error alert that is currently presented onscreen.
    @State private var errorAlertInfo: ErrorAlertItem?
    
    /// The minimum number of contestants in a game.
    private let minimumPlayerCount = 3
    
    var body: some View {
        VStack(spacing: 32) {
            Text("START A NEW GAME")
                .font(.custom("PT Sans Bold", size: 48))
            
            VStack {
                Button("UPLOAD CLUE SET", action: uploadClueSet)
                    .buttonStyle(TrebekButtonStyle())
                Text(clueSetFilename ?? " ")
                    .font(.custom("PT Sans", size: 14))
                    .padding(.top, 4)
            }
            
            VStack {
                Text("CONTESTANTS")
                    .font(.custom("PT Sans", size: 32))
                    .padding()
                HStack(spacing: 12) {
                    TextField(
                        "Player Name",
                        text: $newPlayerName,
                        onCommit: addNewPlayer
                    )
                        .textFieldStyle(TrebekTextFieldStyle())
                    Button(action: addNewPlayer) {
                        Label(
                            title: { Text("ADD") },
                            icon: { Image(systemName: "plus.circle.fill") }
                        )
                    }
                        .buttonStyle(TrebekButtonStyle())
                        .disabled(newPlayerName.trimmed.isEmpty)
                }
                if players.isEmpty {
                    Text("No contestants added.")
                        .font(.custom("PT Sans", size: 14))
                        .padding(.top)
                }
                else {
                    ScrollView(.vertical) {
                        ForEach(players) { player in
                            HStack {
                                Text(player.name.uppercased())
                                Spacer()
                                removePlayerButton(for: player)
                            }
                                .padding(.vertical, 4)
                        }
                    }
                        .font(.custom("PT Sans", size: 20))
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
            }
                .frame(width: 600)
            
            Spacer(minLength: 0)
            Button("START GAME", action: startGame)
                .buttonStyle(TrebekButtonStyle())
                .disabled(clueSet == nil || players.count < minimumPlayerCount)
        }
            .padding(32)
            .alert(item: $errorAlertInfo) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
    }
    
    /// Adds a new contestant to the game.
    ///
    /// If the trimmed name input is empty, then this method will do nothing.
    /// Otherwise, after completing this method, the *Player Name* text field
    /// will be cleared out.
    private func addNewPlayer() {
        if newPlayerName.trimmed.isEmpty {
            return
        }
        players.append(Player(name: newPlayerName))
        newPlayerName = ""
    }
    
    /// Removes the specified contestant from the game.
    ///
    /// - Parameter player: The contestant to remove.
    private func removePlayer(_ player: Player) {
        if let playerIndex = players.firstIndex(matching: player) {
            players.remove(at: playerIndex)
        }
    }
    
    /// Creates a button that removes the specified contestant from the game
    /// when the host clicks on it.
    ///
    /// - Parameter player: The contestant to remove.
    private func removePlayerButton(for player: Player) -> some View {
        return Button(action: { self.removePlayer(player) }) {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .bold))
                .padding(12)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
            .buttonStyle(PlainButtonStyle())
    }
    
    /// Creates and starts a new game with the uploaded clue set and
    /// contestants.
    private func startGame() {
        if let clueSet = clueSet {
            let game = JeopardyGame(clueSet: clueSet, players: players)
            appState.currentViewKey = .game(game)
        }
    }
    
    /// Uploads a clue set to the app.
    private func uploadClueSet() {
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Upload Clue Set"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.showsHiddenFiles = false
        openPanel.allowedFileTypes = ["json"]
        
        let response = openPanel.runModal()
        if response == .OK {
            let clueSetURL = openPanel.url!
            let clueSetData = try! Data(contentsOf: clueSetURL)
            let decoder = JSONDecoder()
            do {
                let clueSet = try decoder
                    .decode(ClueSet.self, from: clueSetData)
                self.clueSet = clueSet
                self.clueSetFilename = clueSetURL.lastPathComponent
            }
            catch let validationError as ClueSet.ValidationError {
                errorAlertInfo = ErrorAlertItem(
                    title: "Invalid Clue Set",
                    message: validationError.message
                )
            }
            catch DecodingError.keyNotFound(let codingKey, _) {
                errorAlertInfo = ErrorAlertItem(
                    title: "Parsing Error",
                    message: codingKey.description
                )
            }
            catch DecodingError.dataCorrupted(let context) {
                errorAlertInfo = ErrorAlertItem(
                    title: "Parsing Error",
                    message: context.debugDescription
                )
            }
            catch {
            }
        }
    }
}

fileprivate extension ClueSet.ValidationError {
    
    /// The error message.
    var message: String {
        switch self {
        case .incorrectCategoryCount(let categoryCount):
            return "Incorrect number of categories "
                + "(expected: \(JeopardyGame.categoryCount), "
                + "actual: \(categoryCount))"
        case .emptyCategoryTitle(let categoryIndex):
            return "The title of category \(categoryIndex + 1) is empty."
        case .incorrectClueCount(let clueCount, let categoryIndex):
            return "Incorrect number of clues in category \(categoryIndex + 1) "
                + "(expected: \(JeopardyGame.clueCountPerCategory), "
                + "actual: \(clueCount))"
        case .multipleDailyDoublesInCategory(let categoryIndex):
            return "There cannot be more than one Daily Double in category "
                + "\(categoryIndex + 1)."
        case .incorrectPointValue(
            let actualPointValue,
            let expectedPointValue,
            let categoryIndex,
            let clueIndex
        ):
            return "Incorrect point value of clue \(clueIndex + 1) in "
                + "category \(categoryIndex + 1) "
                + "(expected: \(expectedPointValue), "
                + "actual: \(actualPointValue))"
        case .emptyAnswer(let categoryIndex, let clueIndex):
            return "The “answer” of clue \(clueIndex + 1) in "
                + "category \(categoryIndex + 1) is empty."
        case .emptyCorrectResponse(let categoryIndex, let clueIndex):
            return "The correct response to clue \(clueIndex + 1) in "
                + "category \(categoryIndex + 1) is empty."
        case .emptyImage(let categoryIndex, let clueIndex):
            return "The accompanying image filename for clue \(clueIndex + 1) "
                + "in category \(categoryIndex + 1) is empty."
        case .clueIsDone(let categoryIndex, let clueIndex):
            return "Clue \(clueIndex + 1) in category \(categoryIndex + 1) "
                + "cannot be marked as “done.”"
        case .incorrectDailyDoubleCount(let dailyDoubleCount):
            return "Incorrect number of Daily Doubles "
                + "(expected: 2, actual: \(dailyDoubleCount))"
        case .emptyFinalJeopardyCategoryTitle:
            return "The title of the Final Jeopardy! category is empty."
        case .emptyFinalJeopardyAnswer:
            return "The “answer” of the Final Jeopardy! clue is empty."
        case .emptyFinalJeopardyCorrectResponse:
            return "The correct response to the Final Jeopardy! clue is empty."
        case .emptyFinalJeopardyImage:
            return "The accompanying image filename for the Final Jeopardy! "
                + "clue is empty."
        }
    }
}

#if DEBUG
struct GameConfigView_Previews: PreviewProvider {
    static var previews: some View {
        GameConfigView().scaledToWindow()
    }
}
#endif
