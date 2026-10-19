import Foundation
import SwiftData

/// Deterministic sample data so screenshots and demo recordings always look good.
/// Only seeded in DEBUG builds (see RootView).
enum DemoData {
    static func seed(in context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        let samples: [(title: String, emoji: String, color: Int)] = [
            ("Morning meditation", "🧘", 4),
            ("Drink 2L of water", "💧", 3),
            ("Read 20 pages", "📚", 2),
            ("Evening run", "🏃", 0)
        ]

        for (index, sample) in samples.enumerated() {
            let created = calendar.date(byAdding: .day, value: -35, to: today) ?? today
            let habit = Habit(title: sample.title, emoji: sample.emoji, colorIndex: sample.color, createdAt: created)
            var rng = SplitMix64(seed: UInt64(index + 7))
            let hitChance = 8 - index

            for offset in 1...34 {
                let forced = index == 0 && offset <= 6          // guarantee one impressive streak
                let roll = Int.random(in: 0..<10, using: &rng)
                if forced || roll < hitChance,
                   let day = calendar.date(byAdding: .day, value: -offset, to: today) {
                    habit.completions.append(day)
                }
            }
            context.insert(habit)
        }

        let minutesPerDay = [40, 75, 25, 100, 60, 0, 45]
        for (offset, minutes) in minutesPerDay.enumerated() where minutes > 0 {
            if let day = calendar.date(byAdding: .day, value: -offset, to: today)?.addingTimeInterval(9 * 3600) {
                context.insert(FocusSession(startedAt: day, duration: TimeInterval(minutes * 60)))
            }
        }
    }
}

/// Small seeded RNG so demo data is identical on every launch.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
