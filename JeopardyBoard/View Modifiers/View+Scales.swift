import SwiftUI

extension View {
    
    /// Scales this view to fit the game board.
    ///
    /// - Returns: The scaled view.
    func scaledToGameBoard() -> some View {
        return self.baseFrame(minWidth: 1200, minHeight: 700)
    }
    
    /// Scales this view to fit the window.
    ///
    /// - Returns: The scaled view.
    func scaledToWindow() -> some View {
        return self.baseFrame(minWidth: 1600, minHeight: 900)
    }
    
    /// Wraps this view in a frame with the specified minimum width and height.
    ///
    /// - Parameter minWidth:  The minimum width of the frame.
    /// - Parameter minHeight: The minimum height of the frame.
    ///
    /// - Returns: The modified view.
    private func baseFrame(minWidth: CGFloat, minHeight: CGFloat) -> some View {
        return self
            .frame(minWidth: minWidth, minHeight: minHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
