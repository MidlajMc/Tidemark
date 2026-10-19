import XCTest
@testable import Flow

final class HabitTests: XCTestCase {
    /// Fixed calendar so tests behave the same in every time zone.
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func day(_ offset: Int) -> Date {
        let base = calendar.date(from: DateComponents(year: 2026, month: 10, day: 19, hour: 12))!
        return calendar.date(byAdding: .day, value: offset, to: base)!
    }

    private func habit(completedOffsets: [Int]) -> Habit {
        let habit = Habit(title: "Test", emoji: "✅", colorIndex: 0)
        habit.completions = completedOffsets.map { calendar.startOfDay(for: day($0)) }
        return habit
    }

    func testStreakCountsConsecutiveDays() {
        let habit = habit(completedOffsets: [0, -1, -2, -4])
        XCTAssertEqual(habit.currentStreak(asOf: day(0), calendar: calendar), 3)
    }

    func testStreakIsAliveWhenTodayIsNotDoneYet() {
        let habit = habit(completedOffsets: [-1, -2])
        XCTAssertEqual(habit.currentStreak(asOf: day(0), calendar: calendar), 2)
    }

    func testStreakBreaksAfterMissedDay() {
        let habit = habit(completedOffsets: [-2, -3])
        XCTAssertEqual(habit.currentStreak(asOf: day(0), calendar: calendar), 0)
    }

    func testToggleAddsThenRemovesCompletion() {
        let habit = habit(completedOffsets: [])

        habit.toggle(on: day(0), calendar: calendar)
        XCTAssertTrue(habit.isCompleted(on: day(0), calendar: calendar))

        habit.toggle(on: day(0), calendar: calendar)
        XCTAssertFalse(habit.isCompleted(on: day(0), calendar: calendar))
    }

    func testCompletionRateOverWindow() {
        let habit = habit(completedOffsets: [0, -1, -2])
        let rate = habit.completionRate(overLast: 7, asOf: day(0), calendar: calendar)
        XCTAssertEqual(rate, 3.0 / 7.0, accuracy: 0.0001)
    }
}
