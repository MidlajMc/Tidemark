import SwiftUI

/// Springy press feedback with a light haptic on touch-down.
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, pressed in
                pressed
            }
    }
}

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var tint: Color = Theme.accents[3]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .contentTransition(.symbolEffect(.replace))
                }
                Text(title)
                    .contentTransition(.interpolate)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(tint.gradient, in: Capsule())
            .shadow(color: tint.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
