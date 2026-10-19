import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

enum Theme {
    /// Habit accent palette. `Habit.colorIndex` indexes into this array.
    static let accents: [Color] = [
        Color(hex: 0xFF6B6B), // coral
        Color(hex: 0xFFB84D), // amber
        Color(hex: 0x2EC4B6), // teal
        Color(hex: 0x5B8DEF), // blue
        Color(hex: 0xA66CFF), // violet
        Color(hex: 0xFF7EB6)  // pink
    ]
}

/// One place for animation curves, so the whole app has a consistent feel.
enum Motion {
    static let snappy = Animation.spring(response: 0.35, dampingFraction: 0.78)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let gentle = Animation.smooth(duration: 0.6)
}

extension Habit {
    var accent: Color { Theme.accents[abs(colorIndex) % Theme.accents.count] }
}
