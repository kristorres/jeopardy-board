import SwiftUI

/// A view that displays the champions in a *Jeopardy!* game.
struct ChampionView: View {
    
    /// The champions in the *Jeopardy!* game.
    let champions: [Player]
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    
    /// The color scheme of this view.
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if champions.isEmpty {
            VStack {
                HStack {
                    Spacer()
                    startANewGameButton
                }
                Spacer(minLength: 0)
                Image("sad-ken-jennings")
                    .resizable()
                    .scaledToFit()
                    .border(Color.white, width: 12)
                    .frame(minHeight: 400, maxHeight: 600)
                    .shadow(radius: 8)
                Text("OOOOH, SORRY!")
                    .font(.custom("PT Sans Narrow Bold", size: 48))
                Text("Looks like we have no champion. Better luck next time.")
                    .font(.custom("PT Sans", size: 20))
                Spacer(minLength: 0)
            }
                .padding(48)
        }
        else {
            ZStack {
                Image("trophy").resizable().scaledToFit()
                VStack {
                    HStack(alignment: .top) {
                        Text("CHAMPION").font(.custom("PT Sans Bold", size: 64))
                        Spacer()
                        startANewGameButton
                    }
                    if champions.count == 1 {
                        Spacer()
                        championRow(for: champions.first!)
                        Spacer()
                    }
                    else {
                        ScrollView(.vertical) {
                            ForEach(champions) {
                                championRow(for: $0)
                            }
                        }
                    }
                }
            }
                .padding(48)
        }
    }
    
    /// The *Start a New Game* button, which ends the current game.
    private var startANewGameButton: some View {
        Button("START A NEW GAME", action: endGame)
            .buttonStyle(TrebekButtonStyle())
    }
    
    /// Creates a row for the specified champion.
    ///
    /// - Parameter player: The champion to be displayed.
    ///
    /// - Returns: The champion row.
    private func championRow(for player: Player) -> some View {
        return VStack {
            Text(player.name.uppercased())
                .font(.custom("PT Sans Bold", size: 120))
            Text("\(player.score)")
                .font(.custom("PT Sans Bold", size: 64))
        }
            .foregroundColor((colorScheme == .dark) ? .white : .black)
            .shadow(radius: 8)
            .padding(.vertical, 48)
    }
    
    /// Ends the current game.
    private func endGame() {
        appState.currentViewKey = .gameConfig
    }
}

#if DEBUG
struct ChampionView_Previews: PreviewProvider {
    static var previews: some View {
        let champion = Player(name: "James Holzhauer", score: 131127)
        return Group {
            ChampionView(champions: [champion]).scaledToWindow()
            ChampionView(champions: []).scaledToWindow()
        }
    }
}
#endif
