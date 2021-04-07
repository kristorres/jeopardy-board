import SwiftUI

/// The content view.
struct ContentView: View {
    
    /// The global app state.
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        VStack {
            Text("🌎").font(.system(size: 200)).padding()
            Text("おはよう、世界！").font(.system(size: 50)).fontWeight(.black)
        }
            .frame(
                minWidth: 1600,
                maxWidth: .infinity,
                minHeight: 900,
                maxHeight: .infinity
            )
            .alert(item: $appState.errorAlert) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
#endif
