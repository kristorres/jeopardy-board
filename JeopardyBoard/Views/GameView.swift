import SwiftUI

/// A view that displays an interactive *Jeopardy!* game.
struct GameView: View {
    
    /// The view model that binds this view to a *Jeopardy!* game.
    @ObservedObject var viewModel: JeopardyGameViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Image("jeopardy-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding()
                if let clue = viewModel.selectedClue {
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
            Text("Players View")
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(width: 300)
                .frame(maxHeight: .infinity)
                .background(Color.purple)
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
