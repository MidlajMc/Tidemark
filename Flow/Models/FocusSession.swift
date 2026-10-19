import Foundation
import SwiftData

/// A finished (or manually stopped) focus session.
@Model
final class FocusSession {
    var startedAt: Date
    /// Length in seconds.
    var duration: TimeInterval

    init(startedAt: Date, duration: TimeInterval) {
        self.startedAt = startedAt
        self.duration = duration
    }
}
