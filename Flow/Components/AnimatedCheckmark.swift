import SwiftUI

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.maxY - rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.minY + rect.height * 0.2))
        return path
    }
}

/// A checkmark that draws itself in (and un-draws) with a trimmed stroke.
struct AnimatedCheckmark: View {
    var isChecked: Bool
    var lineWidth: CGFloat = 3

    var body: some View {
        CheckmarkShape()
            .trim(from: 0, to: isChecked ? 1 : 0)
            .stroke(.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .animation(.easeOut(duration: 0.3).delay(isChecked ? 0.12 : 0), value: isChecked)
    }
}
