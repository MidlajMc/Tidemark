import SwiftUI
import SwiftData

enum FlowTab: String, CaseIterable, Identifiable {
    case habits, focus, stats

    var id: String { rawValue }

    var title: String {
        switch self {
        case .habits: "Habits"
        case .focus: "Focus"
        case .stats: "Stats"
        }
    }

    var symbol: String {
        switch self {
        case .habits: "checklist"
        case .focus: "timer"
        case .stats: "chart.bar.fill"
        }
    }
}

struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("didSeedDemo") private var didSeedDemo = false
    @Environment(\.modelContext) private var context
    @State private var tab: FlowTab = .habits

    var body: some View {
        ZStack {
            AnimatedBackground()

            if hasOnboarded {
                ZStack { screen }
                    .safeAreaInset(edge: .bottom) {
                        FlowTabBar(selection: $tab)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            } else {
                OnboardingView {
                    withAnimation(Motion.gentle) { hasOnboarded = true }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(Motion.snappy, value: tab)
        .task { seedIfNeeded() }
    }

    @ViewBuilder
    private var screen: some View {
        switch tab {
        case .habits:
            HabitListView().transition(.opacity.combined(with: .scale(scale: 0.98)))
        case .focus:
            FocusTimerView().transition(.opacity.combined(with: .scale(scale: 0.98)))
        case .stats:
            StatsView().transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
    }

    private func seedIfNeeded() {
        #if DEBUG
        guard !didSeedDemo else { return }
        didSeedDemo = true
        DemoData.seed(in: context)
        #endif
    }
}

/// Floating tab bar with a pill that glides between tabs via matchedGeometryEffect.
struct FlowTabBar: View {
    @Binding var selection: FlowTab
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(FlowTab.allCases) { tab in
                Button {
                    withAnimation(Motion.snappy) { selection = tab }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab.symbol)
                            .symbolEffect(.bounce, value: selection == tab)
                        if selection == tab {
                            Text(tab.title)
                                .font(.subheadline.weight(.semibold))
                                .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                        }
                    }
                    .foregroundStyle(selection == tab ? Color.white : Color.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background {
                        if selection == tab {
                            Capsule()
                                .fill(Theme.accents[3].gradient)
                                .matchedGeometryEffect(id: "pill", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(6)
        .flowCard(cornerRadius: 34)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .sensoryFeedback(.selection, trigger: selection)
    }
}
