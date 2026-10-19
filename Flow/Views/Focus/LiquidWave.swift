import SwiftUI

/// A filled sine-wave surface. `level` (0...1) is how full the container is.
/// Drive `phase` from a TimelineView to make the surface ripple.
struct LiquidWave: Shape {
    var phase: Double
    var level: Double
    var amplitude: CGFloat
    var frequency: Double = 1.4

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clamped = min(max(level, 0), 1)
        let baseline = rect.height * (1 - CGFloat(clamped))

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: baseline))

        var x: CGFloat = 0
        while x <= rect.width {
            let relative = Double(x / rect.width)
            let wave = sin(relative * 2 * Double.pi * frequency + phase)
            path.addLine(to: CGPoint(x: rect.minX + x, y: baseline + CGFloat(wave) * amplitude))
            x += 3
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
