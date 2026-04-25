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

    /// arrival 通知は 0s / 30s / 60s / 90s / 120s / 180s の 6 本を一気に仕込み、
    /// どれか1本でも気付いてもらえれば良い、という設計。停止時は全て一括取消。
    private let arrivalFollowupDelays: [TimeInterval] = [30, 60, 90, 120, 180]

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
        let prefs = UserDefaults.standard
        let intensity = HapticIntensity(rawValue: prefs.string(forKey: "hapticIntensity") ?? "")
            ?? .strong
        let duration = HapticDuration(rawValue: prefs.integer(forKey: "hapticDuration"))
            ?? .sec120
        let iphoneVibration = prefs.object(forKey: "iphoneVibrationEnabled") as? Bool ?? true

        schedule(alarm: alarm, stage: stage, delay: 0, index: 0)
        if stage == .arrival {
            for (i, delay) in arrivalFollowupDelays.enumerated() {
                schedule(alarm: alarm, stage: stage, delay: delay, index: i + 1)
            }
        }
        WatchBridge.shared.sendArrival(
            alarm: alarm, stage: stage,
            intensity: intensity, duration: duration
        )
        if iphoneVibration {
            triggerDeviceHaptics(stage: stage)
        }
    }

    private func schedule(alarm: Alarm, stage: AlarmStage, delay: TimeInterval, index: Int) {
        let content = UNMutableNotificationContent()
        content.title = stage.title
        content.body = "\(alarm.station.name)（\(alarm.station.linesSummary)）"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = stage == .arrival
            ? NotificationCategory.arrival
            : NotificationCategory.preAlert
        content.userInfo = [
            "alarmId": alarm.id.uuidString,
            "stage": stage.rawValue,
            "followupIndex": index
        ]

        let trigger: UNNotificationTrigger? = delay > 0
            ? UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            : nil

        let identifier = notificationIdentifier(alarmId: alarm.id, stage: stage, index: index)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelPending(for alarm: Alarm) {
        var ids: [String] = []
        for stage in [AlarmStage.preAlert, .arrival] {
            let count = stage == .arrival ? arrivalFollowupDelays.count + 1 : 1
            for i in 0..<count {
                ids.append(notificationIdentifier(alarmId: alarm.id, stage: stage, index: i))
            }
        }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    private func notificationIdentifier(alarmId: UUID, stage: AlarmStage, index: Int) -> String {
        "\(alarmId.uuidString)-\(stage.rawValue)-\(index)"
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
