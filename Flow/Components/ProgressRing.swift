import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 8
    var tint: Color = Theme.accents[2]

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(progress, 1)))
                .stroke(tint.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .animation(Motion.gentle, value: progress)
        .accessibilityHidden(true)
    }
}
