import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var path: [Habit] = []
    @State private var showAdd = false
    @Namespace private var zoomNamespace

    private var doneToday: Int {
        habits.filter { $0.isCompleted(on: .now) }.count
    }

    private var progress: Double {
        habits.isEmpty ? 0 : Double(doneToday) / Double(habits.count)
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "Good morning"
        case 12..<18: "Good afternoon"
        default: "Good evening"
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 14) {
                    header

                    if habits.isEmpty {
                        EmptyHabitsView { showAdd = true }
                    } else {
                        ForEach(habits) { habit in
                            HabitCardView(habit: habit) { path.append(habit) }
                                .matchedZoomSource(id: habit.uuid, in: zoomNamespace)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.4)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.94)
                                        .blur(radius: phase.isIdentity ? 0 : 2)
                                }
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.85).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .animation(Motion.snappy, value: habits.count)
            }
            .scrollIndicators(.hidden)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit) { delete(habit) }
                    .matchedZoomTransition(sourceID: habit.uuid, in: zoomNamespace)
            }
        }
        .sheet(isPresented: $showAdd) {
            AddHabitSheet { title, emoji, colorIndex in
                withAnimation(Motion.snappy) {
                    context.insert(Habit(title: title, emoji: emoji, colorIndex: colorIndex))
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            ZStack {
                ProgressRing(progress: progress, lineWidth: 7)
                Text("\(doneToday)/\(habits.count)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .contentTransition(.numericText())
            }
            .frame(width: 58, height: 58)
            .animation(Motion.snappy, value: doneToday)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(doneToday) of \(habits.count) habits done today")

            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Theme.accents[3].gradient, in: Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Add habit")
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private func delete(_ habit: Habit) {
        path.removeAll()
        // Let the pop transition finish before the model disappears from under the detail view.
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            withAnimation(Motion.snappy) {
                context.delete(habit)
            }
        }
    }
}

struct EmptyHabitsView: View {
    var onAdd: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            PhaseAnimator([false, true]) { up in
                Text("🌱")
                    .font(.system(size: 84))
                    .offset(y: up ? -12 : 12)
                    .rotationEffect(.degrees(up ? 4 : -4))
            } animation: { _ in
                .easeInOut(duration: 1.6)
            }
            .accessibilityHidden(true)

            Text("Nothing here yet")
                .font(.title2.bold())
            Text("Start with one small habit. Streaks do the rest.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Add your first habit", systemImage: "plus", action: onAdd)
                .padding(.horizontal, 20)
        }
        .padding(.top, 60)
    }
}
