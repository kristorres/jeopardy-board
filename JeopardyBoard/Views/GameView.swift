import SwiftUI

/// A view that displays an interactive *Jeopardy!* game.
struct GameView: View {
    
    /// The *Jeopardy!* game that the host interacts with.
    let game: JeopardyGame
    
    var body: some View {
        Image("jeopardy-logo").resizable().scaledToFit().frame(width: 800)
    }
}

#if DEBUG
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(game: exampleGame).scaledToWindow()
    }
}
#endif
