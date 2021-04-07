import SwiftUI

/// A view to create and start a new game of *Jeopardy!*
///
/// The host can upload the clue set and enter the contestants.
struct GameConfigView: View {
    var body: some View {
        VStack {
            Text("🌎").font(.system(size: 200)).padding()
            Text("おはよう、世界！").font(.system(size: 50)).fontWeight(.black)
        }
    }
}

#if DEBUG
struct GameConfigView_Previews: PreviewProvider {
    static var previews: some View {
        GameConfigView().scaledToWindow()
    }
}
#endif
