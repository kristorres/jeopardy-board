import SwiftUI

/// The **root view**.
struct RootView: View {
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        currentView
            .scaledToWindow()
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(red: 0.0706, green: 0.0745, blue: 0.098),
                            Color(red: 0.0431, green: 0.1176, blue: 0.2353)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
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
