import SwiftUI

/// A presentation slide with an image background fill.
struct ImageSlide: View {
    
    /// The image that is presented on this slide.
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(minWidth: 1200, minHeight: 700)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
