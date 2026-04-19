import Foundation
import UserNotifications
import AudioToolbox

final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private init() {}

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func fire(alarm: Alarm, stage: AlarmStage) {
        let content = UNMutableNotificationContent()
        content.title = stage.title
        content.body = "\(alarm.station.name)（\(alarm.station.lineName)）"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "arrival.\(stage.rawValue)"

        let request = UNNotificationRequest(
            identifier: "\(alarm.id.uuidString)-\(stage.rawValue)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)

        WatchBridge.shared.sendArrival(alarm: alarm, stage: stage)
        triggerDeviceHaptics(stage: stage)
    }

    private func triggerDeviceHaptics(stage: AlarmStage) {
        let duration: TimeInterval = (stage == .arrival) ? 30 : 4
        let interval: TimeInterval = (stage == .arrival) ? 1.2 : 1.6
        for delay in stride(from: 0.0, to: duration, by: interval) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
}
