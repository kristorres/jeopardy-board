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
                    Text(category.isDone ? "" : category.title.uppercased())
                        .font(.custom("Impact", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 0, x: 4, y: 4)
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.trebekBlue)
                    ForEach(category.clues) { clue in
                        Text(clue.isDone ? "" : String(clue.pointValue))
                            .font(.custom("Impact", size: 64))
                            .foregroundColor(.trebekGold)
                            .shadow(color: .black, radius: 0, x: 4, y: 4)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.trebekBlue)
                            .onTapGesture {
                                if !clue.isDone {
                                    self.viewModel.selectClue(clue)
                                }
                            }
                    }
                }
                    
            }
        }
            .frame(minWidth: 1200, minHeight: 700)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(gridItemSpacing)
            .background(Color.black)
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
