import SwiftUI

/// The font size of the text in the controls.
fileprivate let fontSize = CGFloat(20)

/// The vertical padding in the controls.
fileprivate let verticalPadding = CGFloat(12)

/// A button style that displays a golden yellow rectangular container around a
/// title in black text.
///
/// The style is named in honor of Alex Trebek, who hosted *Jeopardy!* from 1984
/// until his death in 2020. It is heavily inspired by a button style that is
/// used throughout the game show’s [website](https://www.jeopardy.com).
struct TrebekButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        return ContainerView(configuration: configuration)
    }
    
    /// A container view that describes the effect of pressing the button.
    private struct ContainerView: View {
        
        /// Indicates whether the button allows user interaction.
        @Environment(\.isEnabled) private var isEnabled
        
        /// The properties of the button.
        let configuration: TrebekButtonStyle.Configuration
        
        var body: some View {
            configuration.label
                .font(.custom("PT Sans Narrow Bold", size: fontSize))
                .padding(.vertical, verticalPadding)
                .padding(.horizontal)
                .background(backgroundColor)
                .foregroundColor(isEnabled ? .black : .white)
                .opacity(isEnabled ? 1 : 0.5)
                .animation(.default, value: isEnabled)
        }
        
        /// The background color of the button.
        private var backgroundColor: Color {
            if !isEnabled {
                return .gray
            }
            if configuration.isPressed {
                return .darkTrebekGold
            }
            return .trebekGold
        }
    }
}

extension TextField {
    
    /// Sets the Trebek style for this text field.
    ///
    /// - Returns: The styled text field.
    func trebekTextFieldStyle() -> some View {
        return self
            .textFieldStyle(PlainTextFieldStyle())
            .font(.custom("PT Sans", size: fontSize))
            .padding(.vertical, verticalPadding)
            .padding(.horizontal)
            .background(Color("Text Field Background"))
    }
}

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { return .none }
        set {}
    }
}

fileprivate extension Color {
    static let trebekGold = Color(red: 0.98, green: 0.648, blue: 0.109)
    static let darkTrebekGold = Color(red: 0.855, green: 0.535, blue: 0.016)
}
