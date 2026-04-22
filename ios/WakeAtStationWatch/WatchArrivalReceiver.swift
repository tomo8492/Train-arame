import Foundation
import WatchConnectivity
import WatchKit
import WidgetKit

@MainActor
final class WatchArrivalReceiver: NSObject, ObservableObject {
    @Published var currentStationName: String?
    @Published var currentLines: [String] = []
    @Published var isAlerting: Bool = false
    @Published var currentStage: String?

    var currentLinesSummary: String? {
        currentLines.isEmpty ? nil : currentLines.joined(separator: " / ")
    }

    private var hapticTimer: Timer?
    private var autoStopWorkItem: DispatchWorkItem?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        let state = SharedAppGroup.load()
        currentStationName = state.stationName
        currentLines = state.lines
    }

    func acknowledge() {
        isAlerting = false
        currentStage = nil
        hapticTimer?.invalidate()
        hapticTimer = nil
        autoStopWorkItem?.cancel()
        autoStopWorkItem = nil
    }

    private func startHaptics(isStrong: Bool) {
        hapticTimer?.invalidate()
        autoStopWorkItem?.cancel()
        isAlerting = true
        WKInterfaceDevice.current().play(isStrong ? .notification : .directionUp)

        let interval: TimeInterval = isStrong ? 0.8 : 2.0
        let type: WKHapticType = isStrong ? .failure : .click
        hapticTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor in
                WKInterfaceDevice.current().play(type)
            }
        }

        let timeout: TimeInterval = isStrong ? 120 : 15
        let work = DispatchWorkItem { [weak self] in
            Task { @MainActor in self?.acknowledge() }
        }
        autoStopWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: work)
    }

    private func handleArrival(payload: [String: Any]) {
        currentStationName = payload["stationName"] as? String
        currentLines = payload["lines"] as? [String] ?? []
        let stageRaw = payload["stage"] as? String ?? "arrival"
        currentStage = stageRaw
        startHaptics(isStrong: stageRaw == "arrival")
    }

    private func handleState(payload: [String: Any]) {
        let cleared = payload["cleared"] as? Bool ?? false
        if cleared {
            SharedAppGroup.save(.empty)
            currentStationName = nil
            currentLines = []
        } else if let name = payload["stationName"] as? String {
            let lines = payload["lines"] as? [String] ?? []
            SharedAppGroup.save(AlarmSharedState(
                stationName: name, lines: lines, isMonitoring: true))
            currentStationName = name
            currentLines = lines
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func handle(payload: [String: Any]) {
        switch payload["type"] as? String {
        case "arrival": handleArrival(payload: payload)
        case "state": handleState(payload: payload)
        default: break
        }
    }
}

extension WatchArrivalReceiver: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.handle(payload: message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.handle(payload: applicationContext)
        }
    }
}
