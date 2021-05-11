import SwiftUI

/// The **root view**.
struct RootView: View {
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        currentView
            .scaledToWindow()
            .background(BackgroundView())
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
    }
    
    /// The currently rendered view.
    @ViewBuilder private var currentView: some View {
        switch appState.currentViewKey {
        case .gameConfig:
            GameConfigView()
        case .game(let game):
            GameView(viewModel: JeopardyGameViewModel(game: game))
        case .champions(let champions):
            ChampionView(champions: champions)
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
