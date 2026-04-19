import Foundation
import UserNotifications
import AudioToolbox

enum NotificationCategory {
    static let arrival = "arrival.arrival"
    static let preAlert = "arrival.preAlert"
}

enum NotificationAction {
    static let stop = "STOP_ARRIVAL"
}

final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private init() {}

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        await registerCategories()
    }

    private func registerCategories() async {
        let stopAction = UNNotificationAction(
            identifier: NotificationAction.stop,
            title: "停止",
            options: [.destructive, .foreground]
        )
        let arrival = UNNotificationCategory(
            identifier: NotificationCategory.arrival,
            actions: [stopAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        let pre = UNNotificationCategory(
            identifier: NotificationCategory.preAlert,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([arrival, pre])
    }

    func fire(alarm: Alarm, stage: AlarmStage) {
        let content = UNMutableNotificationContent()
        content.title = stage.title
        content.body = "\(alarm.station.name)（\(alarm.station.linesSummary)）"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = stage == .arrival
            ? NotificationCategory.arrival
            : NotificationCategory.preAlert
        content.userInfo = ["alarmId": alarm.id.uuidString, "stage": stage.rawValue]

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
