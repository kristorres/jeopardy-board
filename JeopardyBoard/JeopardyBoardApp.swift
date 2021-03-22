import SwiftUI

@main
struct JeopardyBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
            .commands {
                CommandGroup(replacing: .newItem, addition: {})
            }
    }
}
