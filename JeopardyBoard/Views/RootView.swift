import SwiftUI

/// The **root view**.
struct RootView: View {
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        currentView
            .scaledToWindow()
            .alert(item: $appState.errorAlert) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
    }
    
    /// The currently rendered view.
    @ViewBuilder private var currentView: some View {
        switch appState.currentViewKey {
        case .gameConfig:
            GameConfigView()
        }
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(AppState())
    }
}
#endif
