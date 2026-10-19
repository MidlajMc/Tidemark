# Flow

A habit and focus app built to feel good in the hand. SwiftUI + SwiftData, iOS 17+, with extra polish on iOS 18 and iOS 26.

Flow is a portfolio project. The point is not the feature list, it is the motion: every tap, swipe, transition and number change is animated on purpose, and the code behind it is small, testable and reusable.

## What to look at

| Screen | Interaction | Technique |
| --- | --- | --- |
| Onboarding | Floating orbs, bouncing hero | `PhaseAnimator`, `KeyframeAnimator` with independent tracks |
| Habits | Swipe right to complete, rubber-band resistance, haptic at the threshold | `DragGesture`, `exp()` easing, `sensoryFeedback` |
| Habits | Check draws itself, confetti bursts from the button | Trimmed `Shape` stroke, `Canvas` + `TimelineView` particles |
| Habits | Cards fade, scale and blur at the screen edges | `scrollTransition` |
| Habit detail | Card zooms into the detail screen | `matchedTransitionSource` + `.navigationTransition(.zoom)` (iOS 18), graceful fallback on 17 |
| Habit detail | Heatmap cells pop in with a stagger, streak counts up | Per-item `.delay`, `contentTransition(.numericText)` |
| Add sheet | Selection rings and pills glide between options | `matchedGeometryEffect` |
| Focus | Liquid timer that fills as time passes | Custom `Shape` driven by `TimelineView(.animation)` |
| Stats | Bars grow in, tap or drag to scrub values | Swift Charts, `chartXSelection`, animated data |
| Everywhere | Drifting background, glass cards, floating tab bar | `MeshGradient`, Liquid Glass on iOS 26 with a material fallback |

Also: Reduce Motion is respected (background, waves, confetti), VoiceOver labels and custom actions on the card, Dynamic Type friendly layouts.

## Run it

You need Xcode 16 or newer (Xcode 26 for Liquid Glass).

1. Unzip, then double-click `Flow.xcodeproj` (or `open Flow.xcodeproj`).
2. Select the **Flow** target, open **Signing & Capabilities**, pick your Team and change the bundle identifier from `com.example.flow` to your own.
3. Choose an iPhone simulator and press Cmd+R. Cmd+U runs the unit tests.

The included app icon is a simple placeholder. `project.yml` is optional: it is an XcodeGen spec that produces the same project if you ever want to regenerate it.

Debug builds seed demo data on first launch (4 habits, a streak, a week of focus sessions) so screenshots and recordings look full. Release builds start empty.

## Structure

```
Flow/
  FlowApp.swift
  Models/          Habit, FocusSession (SwiftData), DemoData
  ViewModels/      FocusTimerViewModel (@Observable, date-based timer)
  Components/      ConfettiBurst, AnimatedCheckmark, ProgressRing,
                   AnimatedBackground, PressableButtonStyle
  Theme/           colors, shared animation curves, card + zoom modifiers
  Views/           Onboarding, Habits, Focus, Stats, RootView
FlowTests/         streak logic, timer logic
```

Design decisions worth mentioning:

- **One motion vocabulary.** `Motion.snappy / bouncy / gentle` are defined once, so the whole app has a consistent feel.
- **Timer is date-based.** The view model stores an end date instead of counting ticks, so it survives backgrounding and the UI can sample it at 60 fps from `TimelineView`.
- **Particles in a Canvas.** Confetti is one drawing pass, not 30 views, and positions are computed from elapsed time.
- **Pure domain logic.** Streak and completion-rate code takes a `Calendar` and a date, so tests are deterministic.
- **Availability-guarded polish.** iOS 18 and 26 features sit behind small modifiers (`matchedZoomSource`, `flowCard`) so the rest of the code stays clean.

## Make it work for your job search

1. **Record a 30 to 60 second demo** on a real device or simulator (Cmd+R, then QuickTime or `xcrun simctl io booted recordVideo`). Show: onboarding, swipe-to-complete with confetti, the zoom into detail, the liquid timer, scrubbing the chart. Put it at the top of this README as a GIF or video link.
2. **Ship it to TestFlight or the App Store.** Your resume already shows release ownership; a live link proves it.
3. **Write one short case study** (Medium works) on the hardest piece, for example the liquid timer or the rubber-band swipe.
4. **Resume line:** *Flow: SwiftUI + SwiftData habit and focus app with custom gesture-driven animations, Canvas particle effects, Swift Charts and Liquid Glass; unit-tested domain logic; Reduce Motion and VoiceOver support.*
5. **Verify smoothness** in Instruments (Animation Hitches template) and note the result in the README.

## Roadmap ideas (good next commits)

- Live Activity and Dynamic Island for the running focus timer
- Home Screen widgets and interactive widgets for checking off habits
- App Intents and Siri Shortcuts ("Log my run")
- A Metal shader (`.colorEffect`) for the liquid surface
- iPad layout with a sidebar
- Snapshot tests for the key screens

## Notes

This code was written without access to Xcode, so it has not been compiled or run yet. Expect to fix a small compiler nit or two on first build. The logic is covered by the unit tests in `FlowTests/`.
