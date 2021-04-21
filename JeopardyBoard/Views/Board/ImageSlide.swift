import SwiftUI

/// A presentation slide with an image background fill.
struct ImageSlide: View {
    
    /// The image that is presented on this slide.
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .scaledToGameBoard()
            .clipped()
    }
}

#if DEBUG
struct ImageSlide_Previews: PreviewProvider {
    static var previews: some View {
        ImageSlide(image: Image("daily-double"))
    }
}
#endif
