import SwiftUI

/// The global app state.
final class AppState: ObservableObject {
    
    /// The key of the currently rendered view.
    @Published var currentViewKey = ViewKey.gameConfig
    
    /// The error alert that is currently presented onscreen.
    @Published var errorAlert: ErrorAlert?
    
    /// A valid key to render a view.
    enum ViewKey {
        
        /// The key to render a view where the host can create and start a new
        /// *Jeopardy!* game.
        case gameConfig
        
        /// The key to render a view that displays an interactive *Jeopardy!*
        /// game.
        case game(JeopardyGame)
    }
    
    /// An error alert with a title and message.
    struct ErrorAlert: Identifiable {
        
        let id = "ALERT-\(UUID())"
        
        /// The title of the error.
        let title: String
        
        /// The error message.
        let message: String
    }
}
