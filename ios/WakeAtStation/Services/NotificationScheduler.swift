import Foundation
import UserNotifications
import AudioToolbox

final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private init() {}

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
    }

    func fireArrivalAlert(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "まもなく\(alarm.station.name)"
        content.body = "起きて！降車駅に近づいています"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "arrival"

        let request = UNNotificationRequest(
            identifier: "arrival-\(alarm.id.uuidString)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)

        WatchBridge.shared.sendArrival(alarm: alarm)
        triggerDeviceHaptics()
    }

    private func triggerDeviceHaptics() {
        for delay in stride(from: 0.0, to: 30.0, by: 1.2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
}
