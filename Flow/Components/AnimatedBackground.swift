import SwiftUI

/// Slowly drifting mesh-gradient backdrop (iOS 18+), with a static gradient fallback.
/// Respects Reduce Motion by freezing the mesh.
struct AnimatedBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: meshPoints(at: reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate),
                        colors: meshColors
                    )
                }
            } else {
                LinearGradient(
                    colors: [meshColors[0], meshColors[4], meshColors[8]],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
    }

    private var meshColors: [Color] {
        if scheme == .dark {
            return [
                Color(hex: 0x1B1B3A), Color(hex: 0x2B1F5C), Color(hex: 0x1B2A4E),
                Color(hex: 0x2E1F5E), Color(hex: 0x4B2A86), Color(hex: 0x1F4B6E),
                Color(hex: 0x14142B), Color(hex: 0x2A1C4D), Color(hex: 0x12303F)
            ]
        } else {
            return [
                Color(hex: 0xEAF0FF), Color(hex: 0xF3E9FF), Color(hex: 0xE3F6F5),
                Color(hex: 0xFCE8F1), Color(hex: 0xE6E3FF), Color(hex: 0xDDF1FF),
                Color(hex: 0xFFF0E1), Color(hex: 0xF0E8FF), Color(hex: 0xE5F7EE)
            ]
        }
    }

    @available(iOS 18.0, *)
    private func meshPoints(at time: TimeInterval) -> [SIMD2<Float>] {
        let a = Float(sin(time * 0.45)) * 0.08
        let b = Float(cos(time * 0.38)) * 0.08
        return [
            SIMD2<Float>(0, 0), SIMD2<Float>(0.5, 0), SIMD2<Float>(1, 0),
            SIMD2<Float>(0, 0.5 + b), SIMD2<Float>(0.5 + a, 0.5 - b), SIMD2<Float>(1, 0.5 + a),
            SIMD2<Float>(0, 1), SIMD2<Float>(0.5, 1), SIMD2<Float>(1, 1)
        ]
    }
}
