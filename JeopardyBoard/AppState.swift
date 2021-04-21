import SwiftUI

/// The global app state.
final class AppState: ObservableObject {
    
    /// The key of the currently rendered view.
    @Published var currentViewKey = ViewKey.gameConfig
    
    /// A valid key to render a view.
    enum ViewKey {
        
        /// The key to render a view where the host can create and start a new
        /// *Jeopardy!* game.
        case gameConfig
        
        /// The key to render a view that displays an interactive *Jeopardy!*
        /// game.
        case game(JeopardyGame)
    }
}
