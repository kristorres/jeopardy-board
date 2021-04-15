import SwiftUI

/// A view that displays an interactive *Jeopardy!* game.
struct GameView: View {
    
    /// The view model that binds this view to a *Jeopardy!* game.
    @ObservedObject var viewModel: JeopardyGameViewModel
    
    var body: some View {
        Image("jeopardy-logo").resizable().scaledToFit().frame(width: 800)
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
