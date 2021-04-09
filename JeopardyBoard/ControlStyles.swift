import SwiftUI

/// A button style for contained buttons.
struct ContainedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return ContainedButtonLabel(configuration: configuration)
    }
}

/// A view that describes the effect of pressing a contained button.
fileprivate struct ContainedButtonLabel: View {
    
    /// Indicates whether the button allows user interaction.
    @Environment(\.isEnabled) private var isEnabled
    
    /// The properties of the button.
    let configuration: ContainedButtonStyle.Configuration
    
    /// The background color of the button.
    private var backgroundColor: Color {
        if !isEnabled {
            return .gray
        }
        if configuration.isPressed {
            return .darkBlue
        }
        return .primaryBlue
    }
    
    var body: some View {
        configuration.label
            .font(.system(size: 16, weight: .heavy))
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(backgroundColor)
            .foregroundColor(.white)
            .opacity(isEnabled ? 1 : 0.5)
            .cornerRadius(12)
    }
}

fileprivate extension Color {
    static let primaryBlue = Color(red: 0.102, green: 0.383, blue: 0.84)
    static let darkBlue = Color(red: 0.082, green: 0.305, blue: 0.672)
}
