import XCTest
@testable import Flow

@MainActor
final class FocusTimerViewModelTests: XCTestCase {
    private let t0 = Date(timeIntervalSince1970: 1_000)

    func testPauseFreezesRemainingTime() {
        let vm = FocusTimerViewModel()
        vm.configure(minutes: 1)
        vm.start(now: t0)
        vm.pause(now: t0.addingTimeInterval(20))

        XCTAssertEqual(vm.state, .paused)
        // Wall-clock time passing while paused must not change anything.
        XCTAssertEqual(vm.remaining(at: t0.addingTimeInterval(500)), 40, accuracy: 0.001)
    }

    func testResumeContinuesFromPausedTime() {
        let vm = FocusTimerViewModel()
        vm.configure(minutes: 1)
        vm.start(now: t0)
        vm.pause(now: t0.addingTimeInterval(20))
        vm.start(now: t0.addingTimeInterval(100))

        XCTAssertEqual(vm.state, .running)
        XCTAssertEqual(vm.remaining(at: t0.addingTimeInterval(110)), 30, accuracy: 0.001)
        vm.reset(now: t0.addingTimeInterval(110))
    }

    func testProgressIsHalfwayAtHalfTime() {
        let vm = FocusTimerViewModel()
        vm.configure(minutes: 1)
        vm.start(now: t0)

        XCTAssertEqual(vm.progress(at: t0.addingTimeInterval(30)), 0.5, accuracy: 0.001)
        vm.reset(now: t0.addingTimeInterval(30))
    }

    func testResetReturnsElapsedSecondsAndGoesIdle() {
        let vm = FocusTimerViewModel()
        vm.configure(minutes: 1)
        vm.start(now: t0)
        let elapsed = vm.reset(now: t0.addingTimeInterval(15))

        XCTAssertEqual(elapsed, 15, accuracy: 0.001)
        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(vm.remaining(at: t0.addingTimeInterval(15)), 60, accuracy: 0.001)
    }
}
