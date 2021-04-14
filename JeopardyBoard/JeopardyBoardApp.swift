import SwiftUI

@main
struct JeopardyBoardApp: App {
    
    /// The global app state.
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(appState)
        }
            .windowStyle(HiddenTitleBarWindowStyle())
            .commands {
                CommandGroup(replacing: .newItem, addition: {})
            }
    }
}
