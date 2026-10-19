import Foundation
import Observation

/// Date-based timer: the source of truth is `endDate`, not a ticking counter,
/// so it stays accurate when the app is backgrounded and the UI can sample it
/// at any frame rate via TimelineView.
@MainActor
@Observable
final class FocusTimerViewModel {
    enum State {
        case idle, running, paused, finished
    }

    private(set) var state: State = .idle
    private(set) var total: TimeInterval = 25 * 60
    private(set) var completedCount = 0

    /// Called once when a session runs to completion, with its full length in seconds.
    @ObservationIgnored var onComplete: ((TimeInterval) -> Void)?

    private var endDate: Date?
    private var pausedRemaining: TimeInterval = 25 * 60
    @ObservationIgnored private var finishTask: Task<Void, Never>?

    // MARK: Intents

    func configure(minutes: Int) {
        guard state == .idle || state == .finished else { return }
        total = TimeInterval(minutes * 60)
        pausedRemaining = total
        state = .idle
    }

    func start(now: Date = .now) {
        guard state != .running else { return }
        if state == .finished || state == .idle {
            pausedRemaining = total
        }
        endDate = now.addingTimeInterval(pausedRemaining)
        state = .running
        scheduleFinish()
    }

    func pause(now: Date = .now) {
        guard state == .running, let endDate else { return }
        pausedRemaining = max(0, endDate.timeIntervalSince(now))
        finishTask?.cancel()
        self.endDate = nil
        state = .paused
    }

    /// Stops the session and returns how many seconds had elapsed.
    @discardableResult
    func reset(now: Date = .now) -> TimeInterval {
        let elapsed = total - remaining(at: now)
        finishTask?.cancel()
        endDate = nil
        pausedRemaining = total
        state = .idle
        return max(0, elapsed)
    }

    // MARK: Sampling (call from TimelineView)

    func remaining(at date: Date) -> TimeInterval {
        switch state {
        case .running:
            return max(0, (endDate ?? date).timeIntervalSince(date))
        case .paused:
            return pausedRemaining
        case .idle:
            return total
        case .finished:
            return 0
        }
    }

    func progress(at date: Date) -> Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, 1 - remaining(at: date) / total))
    }

    // MARK: Private

    private func scheduleFinish() {
        finishTask?.cancel()
        guard let endDate else { return }
        finishTask = Task { [weak self] in
            let delay = endDate.timeIntervalSinceNow
            if delay > 0 {
                try? await Task.sleep(for: .seconds(delay))
            }
            guard !Task.isCancelled else { return }
            self?.finish()
        }
    }

    private func finish() {
        guard state == .running else { return }
        state = .finished
        endDate = nil
        pausedRemaining = 0
        completedCount += 1
        onComplete?(total)
    }
}
