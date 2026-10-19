import SwiftUI

/// Habit row with three interactions:
/// 1. tap the circle: animated check + confetti + success haptic
/// 2. swipe right: rubber-banded reveal, haptic when the threshold is crossed
/// 3. tap the card: opens the detail screen (zoom transition on iOS 18+)
struct HabitCardView: View {
    let habit: Habit
    var onOpen: () -> Void

    @State private var dragX: CGFloat = 0
    @State private var burst = 0
    @State private var isBursting = false

    private let threshold: CGFloat = 55

    private var done: Bool { habit.isCompleted(on: .now) }
    private var armed: Bool { dragX > threshold }
    private var streak: Int { habit.currentStreak() }

    var body: some View {
        ZStack(alignment: .leading) {
            revealBackground
            card
                .offset(x: dragX)
                .gesture(swipe)
        }
        .zIndex(isBursting ? 10 : 0)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: armed)
        .sensoryFeedback(.success, trigger: burst)
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: done ? "Mark incomplete" : "Mark complete") { toggle() }
    }

    // MARK: Pieces

    private var card: some View {
        HStack(spacing: 14) {
            Text(habit.emoji)
                .font(.system(size: 30))
                .frame(width: 56, height: 56)
                .background(
                    habit.accent.opacity(0.2),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(habit.title)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                        Text("\(streak)")
                            .contentTransition(.numericText())
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(streak > 0 ? Color.orange : Color.secondary)

                    weekDots
                }
            }

            Spacer(minLength: 8)

            checkButton
        }
        .padding(16)
        .flowCard(cornerRadius: 24)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: onOpen)
    }

    private var weekDots: some View {
        HStack(spacing: 5) {
            ForEach(lastSevenDays, id: \.self) { day in
                Circle()
                    .fill(habit.isCompleted(on: day) ? habit.accent : habit.accent.opacity(0.18))
                    .frame(width: 8, height: 8)
            }
        }
        .animation(Motion.snappy, value: habit.completions.count)
        .accessibilityHidden(true)
    }

    private var checkButton: some View {
        Button(action: toggle) {
            ZStack {
                Circle()
                    .strokeBorder(habit.accent.opacity(0.45), lineWidth: 2)
                Circle()
                    .fill(habit.accent.gradient)
                    .scaleEffect(done ? 1 : 0.01)
                AnimatedCheckmark(isChecked: done, lineWidth: 3)
                    .padding(12)
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.88))
        .overlay {
            ConfettiBurst(trigger: burst, colors: [habit.accent, .white, .yellow, Theme.accents[5]])
                .frame(width: 240, height: 240)
        }
        .accessibilityLabel(done ? "Completed" : "Mark as complete")
    }

    private var revealBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(habit.accent.gradient)
            .overlay(alignment: .leading) {
                Image(systemName: done ? "arrow.uturn.backward" : "checkmark")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .padding(.leading, 22)
                    .scaleEffect(min(1, dragX / threshold))
                    .opacity(Double(min(1, dragX / 30)))
            }
            .frame(width: max(dragX, 0) + 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(dragX > 2 ? 1 : 0)
    }

    // MARK: Gesture & actions

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 14)
            .onChanged { value in
                // Ignore mostly-vertical drags so the ScrollView keeps working.
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let x = max(0, value.translation.width)
                dragX = 110 * (1 - exp(-x / 110))   // rubber-band: resists the further you pull
            }
            .onEnded { _ in
                let shouldToggle = dragX > threshold
                withAnimation(Motion.bouncy) { dragX = 0 }
                if shouldToggle { toggle() }
            }
    }

    private func toggle() {
        let willComplete = !done
        withAnimation(Motion.snappy) { habit.toggle() }

        if willComplete {
            burst += 1
            isBursting = true
            Task {
                try? await Task.sleep(for: .seconds(1.4))
                isBursting = false
            }
        }
    }

    private var lastSevenDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }
}
