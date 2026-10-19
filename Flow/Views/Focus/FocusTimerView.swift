import SwiftUI
import SwiftData

struct FocusTimerView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var vm = FocusTimerViewModel()
    @State private var minutes = 25
    @Namespace private var chipNamespace

    private let options = [15, 25, 45, 60]
    private let tint = Theme.accents[3]

    var body: some View {
        VStack(spacing: 28) {
            header
            orb
            durationPicker
            controls
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .onAppear {
            vm.onComplete = { total in save(duration: total) }
        }
        .sensoryFeedback(.success, trigger: vm.completedCount)
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .contentTransition(.interpolate)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.interpolate)
        }
        .multilineTextAlignment(.center)
        .animation(Motion.snappy, value: vm.state)
    }

    private var title: String {
        switch vm.state {
        case .idle: "Focus"
        case .running: "In the flow"
        case .paused: "Paused"
        case .finished: "Well done!"
        }
    }

    private var subtitle: String {
        switch vm.state {
        case .idle: "Pick a length and dive in"
        case .running: "Stay with it. The water is rising."
        case .paused: "Take a breath, then continue"
        case .finished: "Session saved to your stats"
        }
    }

    // MARK: Orb

    private var orb: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion && vm.state != .running)) { timeline in
            let now = timeline.date
            let remaining = vm.remaining(at: now)
            let progress = vm.progress(at: now)
            let time = reduceMotion ? 0 : now.timeIntervalSinceReferenceDate
            let level = vm.state == .idle ? 0.1 : max(0.1, progress)

            ZStack {
                Circle().fill(.ultraThinMaterial)

                ZStack {
                    LiquidWave(phase: time * 1.7, level: level, amplitude: 9)
                        .fill(tint.opacity(0.45))
                    LiquidWave(phase: time * 1.2 + 2, level: level, amplitude: 13, frequency: 1.0)
                        .fill(tint.gradient)
                }
                .clipShape(Circle())

                Circle().strokeBorder(.white.opacity(0.3), lineWidth: 1.5)

                Text(format(remaining))
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.snappy, value: Int(remaining.rounded(.up)))
            }
            .frame(width: 290, height: 290)
            .shadow(color: tint.opacity(0.25), radius: 30, y: 16)
        }
        .overlay {
            ConfettiBurst(trigger: vm.completedCount)
                .frame(width: 340, height: 340)
        }
        .scaleEffect(vm.state == .running ? 1.0 : 0.96)
        .animation(Motion.bouncy, value: vm.state)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Timer")
        .accessibilityValue(format(vm.remaining(at: .now)))
    }

    private func format(_ remaining: TimeInterval) -> String {
        let seconds = Int(remaining.rounded(.up))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: Duration chips

    private var durationPicker: some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(Motion.snappy) { minutes = option }
                    vm.configure(minutes: option)
                } label: {
                    Text("\(option)m")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(minutes == option ? Color.white : Color.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background {
                            if minutes == option {
                                Capsule()
                                    .fill(tint.gradient)
                                    .matchedGeometryEffect(id: "chip", in: chipNamespace)
                            }
                        }
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .opacity(canChangeDuration ? 1 : 0)
        .allowsHitTesting(canChangeDuration)
        .animation(Motion.snappy, value: vm.state)
    }

    private var canChangeDuration: Bool {
        vm.state == .idle || vm.state == .finished
    }

    // MARK: Controls

    private var controls: some View {
        HStack(spacing: 14) {
            if vm.state == .running || vm.state == .paused {
                Button {
                    stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .frame(width: 56, height: 56)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("Stop session")
                .transition(.scale.combined(with: .opacity))
            }

            PrimaryButton(title: primaryTitle, systemImage: primaryIcon, tint: tint, action: primaryAction)
        }
        .animation(Motion.snappy, value: vm.state)
    }

    private var primaryTitle: String {
        switch vm.state {
        case .idle: "Start focus"
        case .running: "Pause"
        case .paused: "Resume"
        case .finished: "Go again"
        }
    }

    private var primaryIcon: String {
        switch vm.state {
        case .idle, .paused: "play.fill"
        case .running: "pause.fill"
        case .finished: "arrow.clockwise"
        }
    }

    private func primaryAction() {
        withAnimation(Motion.snappy) {
            switch vm.state {
            case .idle, .paused, .finished: vm.start()
            case .running: vm.pause()
            }
        }
    }

    private func stop() {
        let elapsed = vm.reset()
        if elapsed >= 60 { save(duration: elapsed) }
    }

    private func save(duration: TimeInterval) {
        let session = FocusSession(startedAt: Date.now.addingTimeInterval(-duration), duration: duration)
        context.insert(session)
    }
}
