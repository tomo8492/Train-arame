import Foundation
import WatchConnectivity
import WatchKit

@MainActor
final class WatchArrivalReceiver: NSObject, ObservableObject {
    @Published var currentStationName: String?
    @Published var currentLineName: String?
    @Published var isAlerting: Bool = false

    private var hapticTimer: Timer?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func acknowledge() {
        isAlerting = false
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    private func startStrongHaptics() {
        guard !isAlerting else { return }
        isAlerting = true
        WKInterfaceDevice.current().play(.notification)
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            Task { @MainActor in
                WKInterfaceDevice.current().play(.failure)
            }
        }
        // Auto-stop after 2 minutes if user never acknowledges (safety guard)
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) { [weak self] in
            Task { @MainActor in
                self?.acknowledge()
            }
        }
    }

    private func handle(payload: [String: Any]) {
        guard let type = payload["type"] as? String, type == "arrival" else { return }
        currentStationName = payload["stationName"] as? String
        currentLineName = payload["lineName"] as? String
        startStrongHaptics()
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
