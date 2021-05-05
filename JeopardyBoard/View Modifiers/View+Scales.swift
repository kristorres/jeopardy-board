import SwiftUI

extension View {
    
    /// Scales this view to fit the game board.
    ///
    /// - Returns: The scaled view.
    func scaledToGameBoard() -> some View {
        return self
            .aspectRatio(1.7778, contentMode: .fit)
            .frame(minWidth: 775, maxWidth: .infinity, minHeight: 450)
            .padding(8)
            .background(Color.black)
    }
    
    /// Scales this view to fit the window.
    ///
    /// - Returns: The scaled view.
    func scaledToWindow() -> some View {
        return self
            .frame(minWidth: 1125, minHeight: 625)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
