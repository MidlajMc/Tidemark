import SwiftUI

private struct OnboardingPage {
    let emoji: String
    let title: String
    let subtitle: String
    let tint: Color
}

struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "🌱",
            title: "Small steps,\nbig streaks",
            subtitle: "Build habits that stick with a tap, a swipe and a little celebration.",
            tint: Theme.accents[2]
        ),
        OnboardingPage(
            emoji: "🌊",
            title: "Find your\nflow",
            subtitle: "A liquid focus timer that fills up as you concentrate.",
            tint: Theme.accents[3]
        ),
        OnboardingPage(
            emoji: "📈",
            title: "See it\nadd up",
            subtitle: "Clear charts that make your progress feel real.",
            tint: Theme.accents[4]
        )
    ]

    private var isLastPage: Bool { page == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index], isActive: page == index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 24) {
                pageDots
                PrimaryButton(title: isLastPage ? "Get started" : "Continue", tint: pages[page].tint) {
                    if isLastPage {
                        onFinish()
                    } else {
                        withAnimation(Motion.snappy) { page += 1 }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .animation(Motion.snappy, value: page)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == page ? pages[page].tint : Color.secondary.opacity(0.3))
                    .frame(width: index == page ? 28 : 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                FloatingOrbs(tint: page.tint)
                HeroEmoji(emoji: page.emoji)
            }
            .frame(height: 300)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(isActive ? 1 : 0)
            .offset(y: isActive ? 0 : 24)
            .animation(.smooth(duration: 0.6).delay(0.1), value: isActive)

            Spacer()
        }
    }
}

/// Soft blurred circles that float forever (PhaseAnimator loops its phases).
private struct FloatingOrbs: View {
    let tint: Color

    private let orbs: [(size: CGFloat, x: CGFloat, y: CGFloat, duration: Double)] = [
        (200, -70, -30, 2.4),
        (120, 90, 60, 2.8),
        (70, 60, -90, 3.2)
    ]

    var body: some View {
        ZStack {
            ForEach(orbs.indices, id: \.self) { index in
                let orb = orbs[index]
                PhaseAnimator([false, true]) { up in
                    Circle()
                        .fill(tint.opacity(0.28 - Double(index) * 0.05).gradient)
                        .frame(width: orb.size, height: orb.size)
                        .blur(radius: 6)
                        .offset(x: orb.x + (up ? 14 : -14), y: orb.y + (up ? -18 : 18))
                } animation: { _ in
                    .easeInOut(duration: orb.duration)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

/// Keyframe-driven bounce: separate tracks for offset, scale and rotation
/// so each property gets its own timing curve.
private struct HeroEmoji: View {
    let emoji: String

    struct Values {
        var scale = 1.0
        var offsetY = 0.0
        var rotation = 0.0
    }

    var body: some View {
        KeyframeAnimator(initialValue: Values(), repeating: true) { values in
            Text(emoji)
                .font(.system(size: 110))
                .scaleEffect(values.scale)
                .rotationEffect(.degrees(values.rotation))
                .offset(y: values.offsetY)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 18)
        } keyframes: { _ in
            KeyframeTrack(\.offsetY) {
                SpringKeyframe(-26, duration: 0.6, spring: .bouncy)
                SpringKeyframe(0, duration: 0.6, spring: .bouncy)
                LinearKeyframe(0, duration: 0.8)
            }
            KeyframeTrack(\.scale) {
                CubicKeyframe(1.1, duration: 0.6)
                CubicKeyframe(1.0, duration: 0.6)
                LinearKeyframe(1.0, duration: 0.8)
            }
            KeyframeTrack(\.rotation) {
                CubicKeyframe(-8, duration: 0.5)
                CubicKeyframe(8, duration: 1.0)
                CubicKeyframe(0, duration: 0.5)
            }
        }
        .accessibilityHidden(true)
    }
}
