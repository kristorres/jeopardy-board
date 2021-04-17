import SwiftUI

/// A presentation slide with a blue background.
///
/// The content is horizontally and vertically aligned on the slide.
struct BlueSlide<Content>: View where Content: View {
    
    /// The content that is presented on this slide.
    let content: () -> Content
    
    var body: some View {
        content()
            .padding(.vertical, 40)
            .padding(.horizontal, 80)
            .frame(minWidth: 1200, minHeight: 700)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.trebekBlue)
    }
}

#if DEBUG
struct BlueSlide_Previews: PreviewProvider {
    static var previews: some View {
        let answer = exampleGame.jeopardyRoundCategories[0].clues[3].answer
        return BlueSlide {
            Text(answer.uppercased())
                .font(.custom("ITC Korinna Regular", size: 64))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 0, x: 4, y: 4)
                .multilineTextAlignment(.center)
        }
    }
}
#endif
