import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    var onDelete: () -> Void

    @State private var appeared = false
    @State private var shownStreak = 0
    @State private var showDeleteConfirm = false

    private let calendar = Calendar.current

    /// Last 35 days, oldest first.
    private var days: [Date] {
        let today = calendar.startOfDay(for: .now)
        return (0..<35).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero
                statsRow
                heatmap
                deleteButton
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .background { AnimatedBackground() }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            withAnimation(Motion.bouncy) { appeared = true }
            withAnimation(.smooth(duration: 0.9)) { shownStreak = habit.currentStreak() }
        }
        .confirmationDialog("Delete this habit?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Your streak and history will be removed.")
        }
    }

    // MARK: Sections

    private var hero: some View {
        VStack(spacing: 12) {
            Text(habit.emoji)
                .font(.system(size: 76))
                .padding(28)
                .background(habit.accent.opacity(0.18), in: Circle())
                .scaleEffect(appeared ? 1 : 0.4)
                .opacity(appeared ? 1 : 0)

            Text(habit.title)
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Started \(habit.createdAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCell(title: "Streak", value: "\(shownStreak)", symbol: "flame.fill", tint: .orange, numeric: Double(shownStreak))
            statCell(
                title: "30 days",
                value: "\(Int((habit.completionRate(overLast: 30) * 100).rounded()))%",
                symbol: "chart.line.uptrend.xyaxis",
                tint: habit.accent,
                numeric: nil
            )
            statCell(title: "Total", value: "\(habit.completions.count)", symbol: "checkmark.circle.fill", tint: habit.accent, numeric: nil)
        }
    }

    private func statCell(title: String, value: String, symbol: String, tint: Color, numeric: Double?) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .contentTransition(
                    numeric.map { ContentTransition.numericText(value: $0) } ?? ContentTransition.identity
                )
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .flowCard(cornerRadius: 20)
    }

    private var heatmap: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 5 weeks")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(habit.isCompleted(on: day) ? habit.accent : habit.accent.opacity(0.12))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            if calendar.isDateInToday(day) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(.primary.opacity(0.6), lineWidth: 1.5)
                            }
                        }
                        .scaleEffect(appeared ? 1 : 0.2)
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.65).delay(Double(index) * 0.015),
                            value: appeared
                        )
                }
            }
        }
        .padding(16)
        .flowCard(cornerRadius: 24)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label("Delete habit", systemImage: "trash")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(PressableButtonStyle())
        .foregroundStyle(.red)
    }
}
