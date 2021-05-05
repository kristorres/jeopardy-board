import SwiftUI

/// A view that presents a clue as a “stack” of slides onscreen.
///
/// In order to advance to the next slide, the host has to simply click on the
/// current slide. The last slide is always guaranteed to be the one that
/// contains the correct response to the clue.
///
/// If the clue has an accompanying image, then it will take the place of the
/// “answer.” Moreover, if the clue is a Daily Double, then the Daily Double
/// image will be displayed before the answer is revealed.
struct ClueView: View {
    
    /// The clue to be presented onscreen.
    private let clue: Clue
    
    /// The action to perform when the presentation slide that contains the
    /// correct response is clicked on.
    private let onExit: () -> Void
    
    /// Indicates whether the Daily Double slide is visible.
    @State private var dailyDoubleSlideIsVisible = true
    
    /// Indicates whether the “answer” is visible.
    @State private var answerIsVisible = true
    
    /// Creates a view with the specified clue.
    ///
    /// - Parameter clue:   The clue to be presented onscreen.
    /// - Parameter onExit: The action to perform when the presentation slide
    ///                     that contains the correct response is clicked on.
    ///                     The default is an action that does nothing (`{}`).
    init(clue: Clue, onExit: @escaping () -> Void = {}) {
        self.clue = clue
        self.onExit = onExit
    }
    
    var body: some View {
        if clue.isDailyDouble && dailyDoubleSlideIsVisible {
            ImageSlide(image: Image("daily-double"))
                .onTapGesture {
                    self.dailyDoubleSlideIsVisible = false
                }
        }
        else if answerIsVisible {
            if let image = image {
                ImageSlide(image: image).onTapGesture {
                    self.answerIsVisible = false
                }
            }
            else {
                BlueSlide {
                    Text(clue.answer.uppercased()).formatForClue()
                }
                    .onTapGesture {
                        self.answerIsVisible = false
                    }
            }
        }
        else {
            BlueSlide {
                Text(clue.correctResponse.uppercased()).formatForClue()
            }
                .onTapGesture(perform: onExit)
        }
    }
    
    /// The image that accompanies the clue.
    private var image: Image? {
        guard let imagePath = clue.image else {
            return nil
        }
        let imageURL = URL(fileURLWithPath: "Pictures/\(imagePath)")
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return nil
        }
        guard let nsImage = NSImage(data: imageData) else {
            return nil
        }
        return Image(nsImage: nsImage)
    }
}

fileprivate extension Text {
    
    /// Formats this text view for a clue.
    ///
    /// - Returns: The formatted text.
    func formatForClue() -> some View {
        return self
            .font(.custom("ITC Korinna Regular", size: 64))
            .minimumScaleFactor(0.5)
            .foregroundColor(.white)
            .shadow(color: .black, radius: 0, x: 4, y: 4)
            .multilineTextAlignment(.center)
    }
}

#if DEBUG
struct ClueView_Previews: PreviewProvider {
    static var previews: some View {
        let clue = exampleGame.jeopardyRoundCategories[0].clues[3]
        return ClueView(clue: clue)
    }
}
#endif
