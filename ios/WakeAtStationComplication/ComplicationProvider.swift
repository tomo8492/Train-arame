import WidgetKit
import Foundation

struct ComplicationEntry: TimelineEntry {
    let date: Date
    let stationName: String?
    let lines: [String]
    let isMonitoring: Bool

    static let placeholder = ComplicationEntry(
        date: .now,
        stationName: "東京",
        lines: ["JR山手線"],
        isMonitoring: true
    )
}

struct ComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplicationEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        let entry = currentEntry()
        let refresh = Date().addingTimeInterval(60 * 30)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func currentEntry() -> ComplicationEntry {
        let state = SharedAppGroup.load()
        return ComplicationEntry(
            date: .now,
            stationName: state.stationName,
            lines: state.lines,
            isMonitoring: state.isMonitoring
        )
    }
}
