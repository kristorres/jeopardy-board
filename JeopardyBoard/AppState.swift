import SwiftUI

/// The global app state.
final class AppState: ObservableObject {
    
    /// The key of the currently rendered view.
    @Published var currentViewKey = ViewKey.gameConfig
    
    /// The error alert that is currently presented onscreen.
    @Published var errorAlert: ErrorAlert?
    
    /// A valid key to render a view.
    enum ViewKey {
        
        /// The key to render a view where the user can create and start a new
        /// game of *Jeopardy!*
        case gameConfig
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
