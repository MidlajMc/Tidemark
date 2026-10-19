import SwiftUI

/// A particle burst drawn with Canvas + TimelineView (no view per particle, so it stays at 120 fps).
/// Increment `trigger` to fire it. Positions are computed analytically from elapsed time.
struct ConfettiBurst: View {
    let trigger: Int
    var colors: [Color] = Theme.accents
    var particleCount = 30

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var particles: [Particle] = []
    @State private var startDate: Date?
    @State private var runID = 0

    private let duration: TimeInterval = 1.3
    private let gravity: Double = 700

    struct Particle {
        let angle: Double
        let speed: Double
        let size: CGFloat
        let spin: Double
        let color: Color
        let isCircle: Bool
    }

    var body: some View {
        TimelineView(.animation(paused: startDate == nil)) { timeline in
            Canvas { context, size in
                guard let start = startDate else { return }
                let t = timeline.date.timeIntervalSince(start)
                guard t >= 0, t < duration else { return }

                let origin = CGPoint(x: size.width / 2, y: size.height / 2)
                let fade = max(0, 1 - pow(t / duration, 2))

                for particle in particles {
                    var layer = context
                    let x = origin.x + cos(particle.angle) * particle.speed * t
                    let y = origin.y + sin(particle.angle) * particle.speed * t + 0.5 * gravity * t * t
                    layer.translateBy(x: x, y: y)
                    layer.rotate(by: .radians(particle.spin * t))
                    layer.opacity = fade

                    let rect = CGRect(
                        x: -particle.size / 2,
                        y: -particle.size / 2,
                        width: particle.size,
                        height: particle.size * 0.6
                    )
                    let path = particle.isCircle
                        ? Path(ellipseIn: rect)
                        : Path(roundedRect: rect, cornerRadius: 1.5)
                    layer.fill(path, with: .color(particle.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onChange(of: trigger) { _, _ in fire() }
    }

    private func fire() {
        guard !reduceMotion else { return }
        runID += 1
        let currentRun = runID

        particles = (0..<particleCount).map { _ in
            Particle(
                angle: Double.random(in: -3.4...0.25),
                speed: Double.random(in: 140...340),
                size: CGFloat.random(in: 6...11),
                spin: Double.random(in: -8...8),
                color: colors.randomElement() ?? .white,
                isCircle: Bool.random()
            )
        }
        startDate = .now

        Task {
            try? await Task.sleep(for: .seconds(duration + 0.1))
            if runID == currentRun { startDate = nil }
        }
    }
}
