import SwiftUI
import SwiftData

@main
struct FlowApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Habit.self, FocusSession.self])
    }
}
