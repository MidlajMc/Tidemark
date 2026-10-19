import Foundation
import SwiftData

/// A habit the user wants to build. Completions are stored as start-of-day dates.
@Model
final class Habit {
    var uuid: UUID
    var title: String
    var emoji: String
    var colorIndex: Int
    var createdAt: Date
    var completions: [Date]

    init(
        title: String,
        emoji: String,
        colorIndex: Int,
        createdAt: Date = .now,
        completions: [Date] = []
    ) {
        self.uuid = UUID()
        self.title = title
        self.emoji = emoji
        self.colorIndex = colorIndex
        self.createdAt = createdAt
        self.completions = completions
    }
}

// MARK: - Domain logic (pure, easy to unit test)

extension Habit {
    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        completions.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    /// Adds or removes the completion for the given day.
    func toggle(on date: Date = .now, calendar: Calendar = .current) {
        if let index = completions.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            completions.remove(at: index)
        } else {
            completions.append(calendar.startOfDay(for: date))
        }
    }

    /// Consecutive completed days ending today. If today is not done yet,
    /// the streak is still alive and counts back from yesterday.
    func currentStreak(asOf today: Date = .now, calendar: Calendar = .current) -> Int {
        var day = calendar.startOfDay(for: today)
        if !isCompleted(on: day, calendar: calendar) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var streak = 0
        while isCompleted(on: day, calendar: calendar) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    /// Share of the last `days` days (including today) that were completed, from 0 to 1.
    func completionRate(overLast days: Int, asOf today: Date = .now, calendar: Calendar = .current) -> Double {
        guard days > 0 else { return 0 }
        let start = calendar.startOfDay(for: today)
        let hits = (0..<days).filter { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: start) else { return false }
            return isCompleted(on: day, calendar: calendar)
        }.count
        return Double(hits) / Double(days)
    }
}
