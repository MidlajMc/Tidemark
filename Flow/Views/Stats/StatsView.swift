import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var sessions: [FocusSession]
    @Query private var habits: [Habit]

    @State private var animate = false
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let tint = Theme.accents[3]

    private struct DayPoint: Identifiable {
        let date: Date
        let minutes: Double
        var id: Date { date }
    }

    // MARK: Derived data

    private var week: [DayPoint] {
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let seconds = sessions
                .filter { calendar.isDate($0.startedAt, inSameDayAs: day) }
                .map(\.duration)
                .reduce(0, +)
            return DayPoint(date: day, minutes: seconds / 60)
        }
    }

    private var selectedPoint: DayPoint? {
        guard let selectedDate else { return nil }
        return week.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var todayMinutes: Double { week.last?.minutes ?? 0 }

    private var bestStreak: Int {
        habits.map { $0.currentStreak() }.max() ?? 0
    }

    private var weeklyConsistency: Double {
        guard !habits.isEmpty else { return 0 }
        let total = habits.map { $0.completionRate(overLast: 7) }.reduce(0, +)
        return total / Double(habits.count)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your progress")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("Last 7 days")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                HStack(spacing: 12) {
                    StatTile(title: "Focus today", value: animate ? todayMinutes : 0, suffix: "m", symbol: "timer", tint: Theme.accents[3])
                    StatTile(title: "Best streak", value: animate ? Double(bestStreak) : 0, suffix: "d", symbol: "flame.fill", tint: Theme.accents[1])
                    StatTile(title: "Consistency", value: animate ? weeklyConsistency * 100 : 0, suffix: "%", symbol: "checkmark.seal.fill", tint: Theme.accents[2])
                }

                chartCard
                habitBars
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .task {
            try? await Task.sleep(for: .milliseconds(250))
            withAnimation(.smooth(duration: 0.9)) { animate = true }
        }
    }

    // MARK: Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Focus minutes")
                .font(.headline)

            Chart {
                ForEach(week) { point in
                    BarMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Minutes", animate ? point.minutes : 0)
                    )
                    .foregroundStyle(isSelected(point) ? tint.gradient : tint.opacity(0.55).gradient)
                    .cornerRadius(8)
                }

                if let selectedPoint {
                    RuleMark(x: .value("Selected", selectedPoint.date, unit: .day))
                        .foregroundStyle(.secondary.opacity(0.35))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            Text("\(Int(selectedPoint.minutes)) min")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                }
            }
            .chartXSelection(value: $selectedDate)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
            .animation(.smooth(duration: 0.9), value: animate)
            .animation(Motion.snappy, value: selectedDate)
        }
        .padding(16)
        .flowCard(cornerRadius: 24)
    }

    private func isSelected(_ point: DayPoint) -> Bool {
        guard let selectedDate else { return false }
        return calendar.isDate(point.date, inSameDayAs: selectedDate)
    }

    // MARK: Habit consistency

    private var habitBars: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit consistency")
                .font(.headline)

            if habits.isEmpty {
                Text("Add a habit to see how consistent you are.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(habits.enumerated()), id: \.element.persistentModelID) { index, habit in
                    let rate = habit.completionRate(overLast: 14)
                    VStack(spacing: 8) {
                        HStack {
                            Text(habit.emoji)
                            Text(habit.title)
                                .font(.subheadline.weight(.medium))
                                .lineLimit(1)
                            Spacer()
                            Text("\(Int((rate * 100).rounded()))%")
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        ZStack(alignment: .leading) {
                            Capsule().fill(habit.accent.opacity(0.15))
                            GeometryReader { proxy in
                                Capsule()
                                    .fill(habit.accent.gradient)
                                    .frame(width: proxy.size.width * (animate ? rate : 0))
                                    .animation(.smooth(duration: 0.9).delay(Double(index) * 0.08), value: animate)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .flowCard(cornerRadius: 24)
    }
}

private struct StatTile: View {
    let title: String
    let value: Double
    let suffix: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)

            Text("\(Int(value.rounded()))\(suffix)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .contentTransition(.numericText(value: value))
                .animation(.smooth(duration: 0.9), value: value)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .flowCard(cornerRadius: 20)
    }
}
