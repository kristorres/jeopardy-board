import SwiftUI

/// A view that presents a Final Jeopardy! clue as a “stack” of slides onscreen.
///
/// In order to advance to the next slide, the host has to simply click on the
/// current slide. The last slide is always guaranteed to be the one that
/// contains the correct response to the clue.
///
/// The first two slides present the Final Jeopardy! image and category, in that
/// order.
struct FinalJeopardyClueView: View {
    
    /// The category title.
    private let categoryTitle: String
    
    /// The clue view to be presented onscreen.
    private let clueView: ClueView
    
    /// Indicates whether the Final Jeopardy! slide is visible.
    @State private var finalJeopardySlideIsVisible = true
    
    /// Indicates whether the category is visible.
    @State private var categoryIsVisible = true
    
    /// Creates a view with the specified Final Jeopardy! clue.
    ///
    /// - Parameter clue:   The clue to be presented onscreen.
    /// - Parameter onExit: The action to perform when the presentation slide
    ///                     that contains the correct response is clicked on.
    ///                     The default is an action that does nothing (`{}`).
    init(clue: FinalJeopardyClue, onExit: @escaping () -> Void = {}) {
        self.categoryTitle = clue.categoryTitle
        let clue = Clue(
            pointValue: 0,
            answer: clue.answer,
            correctResponse: clue.correctResponse
        )
        self.clueView = ClueView(clue: clue, onExit: onExit)
    }
    
    var body: some View {
        if finalJeopardySlideIsVisible {
            ImageSlide(image: Image("final-jeopardy"))
                .onTapGesture {
                    self.finalJeopardySlideIsVisible = false
                }
        }
        else if categoryIsVisible {
            BlueSlide {
                Text(categoryTitle.uppercased())
                    .font(.custom("Impact", size: 150))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 0, x: 4, y: 4)
                    .multilineTextAlignment(.center)
            }
                .onTapGesture {
                    self.categoryIsVisible = false
                }
        }
        else {
            clueView
        }
    }
}

#if DEBUG
struct FinalJeopardyClueView_Previews: PreviewProvider {
    static var previews: some View {
        FinalJeopardyClueView(clue: exampleGame.finalJeopardyClue)
    }
}
#endif
