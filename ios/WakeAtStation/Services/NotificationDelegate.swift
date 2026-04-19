import Foundation
import UserNotifications

@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    weak var locationManager: LocationManager?

    func register(locationManager: LocationManager) {
        self.locationManager = locationManager
        UNUserNotificationCenter.current().delegate = self
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionId = response.actionIdentifier
        let dismissed = actionId == UNNotificationDismissActionIdentifier
        let stop = actionId == NotificationAction.stop
        Task { @MainActor in
            if stop || dismissed {
                self.locationManager?.stopMonitoring()
            }
            completionHandler()
        }
    }
}
