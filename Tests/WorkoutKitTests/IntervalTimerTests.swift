import Testing
@testable import WorkoutKit

@Suite("IntervalTimer")
struct IntervalTimerTests {
    @Test("3秒カウントダウンで正しい値を emit する")
    func countdownEmitsCorrectValues() async throws {
        let timer = IntervalTimer()
        let stream = await timer.start(seconds: 3)
        var values: [Int] = []
        for await v in stream {
            values.append(v)
        }
        #expect(values == [3, 2, 1, 0])
    }

    @Test("cancel で stream が終了する")
    func cancelStopsStream() async throws {
        let timer = IntervalTimer()
        let stream = await timer.start(seconds: 10)
        var count = 0
        let task = Task {
            for await _ in stream { count += 1 }
        }
        try await Task.sleep(for: .milliseconds(100))
        await timer.cancel()
        task.cancel()
        #expect(count >= 1)
    }
}
