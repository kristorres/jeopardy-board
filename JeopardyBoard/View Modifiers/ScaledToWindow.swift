import SwiftUI

/// The minimum width of the window.
fileprivate let minimumWindowWidth = CGFloat(1600)

/// The minimum height of the window.
fileprivate let minimumWindowHeight = CGFloat(900)

extension View {
    
    /// Scales this view to fit the window.
    ///
    /// - Returns: The scaled view.
    func scaledToWindow() -> some View {
        return self.frame(
            minWidth: minimumWindowWidth,
            maxWidth: .infinity,
            minHeight: minimumWindowHeight,
            maxHeight: .infinity
        )
    }
}
