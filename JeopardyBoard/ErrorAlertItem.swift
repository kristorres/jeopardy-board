import Foundation

/// An error alert item with a title and message.
struct ErrorAlertItem: Identifiable {
    
    let id = "ALERT-\(UUID())"
    
    /// The title of the error.
    let title: String
    
    /// The error message.
    let message: String
}
