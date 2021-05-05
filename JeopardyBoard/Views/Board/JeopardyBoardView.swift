import SwiftUI

/// A view that displays the game board in a *Jeopardy!* game.
struct JeopardyBoardView: View {
    
    /// The view model that binds this view to a *Jeopardy!* game.
    @ObservedObject var viewModel: JeopardyGameViewModel
    
    /// The spacing between adjacent items in the grid.
    private let gridItemSpacing = CGFloat(8)
    
    var body: some View {
        HStack(spacing: gridItemSpacing) {
            ForEach(viewModel.jeopardyRoundCategories) { category in
                VStack(spacing: gridItemSpacing) {
                    GameBoardCell {
                        Text(category.isDone ? "" : category.title.uppercased())
                            .font(.custom("Impact", size: 28))
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 0, x: 4, y: 4)
                            .multilineTextAlignment(.center)
                    }
                    ForEach(category.clues) { clue in
                        GameBoardCell {
                            Text(clue.isDone ? "" : String(clue.pointValue))
                                .font(.custom("Impact", size: 64))
                                .minimumScaleFactor(0.75)
                                .foregroundColor(.trebekGold)
                                .shadow(color: .black, radius: 0, x: 4, y: 4)
                        }
                            .onTapGesture {
                                if !clue.isDone {
                                    self.viewModel.selectClue(clue)
                                }
                            }
                    }
                }
            }
        }
            .scaledToGameBoard()
            .padding(gridItemSpacing)
            .background(Color.black)
    }
}

/// A cell in the game board grid.
fileprivate struct GameBoardCell<Content>: View where Content: View {
    
    /// The content that is presented in this cell.
    let content: () -> Content
    
    var body: some View {
        content()
            .padding(8)
            .frame(maxWidth: .infinity, minHeight: 64, maxHeight: .infinity)
            .background(Color.trebekBlue)
    }
}

#if DEBUG
struct JeopardyBoardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = JeopardyGameViewModel(game: exampleGame)
        return JeopardyBoardView(viewModel: viewModel)
    }
}
#endif
