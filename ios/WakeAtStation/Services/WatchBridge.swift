import Foundation
import WatchConnectivity

final class WatchBridge: NSObject, WCSessionDelegate {
    static let shared = WatchBridge()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func updateActiveAlarm(_ alarm: Alarm?) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        var payload: [String: Any] = ["type": "state"]
        if let alarm = alarm {
            payload["stationName"] = alarm.station.name
            payload["lines"] = alarm.station.lines
            payload["alarmId"] = alarm.id.uuidString
        } else {
            payload["cleared"] = true
        }
        try? session.updateApplicationContext(payload)
    }

    func sendArrival(alarm: Alarm, stage: AlarmStage,
                     intensity: HapticIntensity, duration: HapticDuration) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        let payload: [String: Any] = [
            "type": "arrival",
            "stage": stage.rawValue,
            "stationName": alarm.station.name,
            "lines": alarm.station.lines,
            "alarmId": alarm.id.uuidString,
            "hapticIntensity": intensity.rawValue,
            "hapticDuration": duration.rawValue
        ]

        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        } else {
            try? session.updateApplicationContext(payload)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
