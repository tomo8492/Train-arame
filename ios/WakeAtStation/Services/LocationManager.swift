import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var monitoredAlarm: Alarm?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
        authorizationStatus = manager.authorizationStatus
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    func startMonitoring(_ alarm: Alarm) {
        monitoredAlarm = alarm
        manager.startMonitoringSignificantLocationChanges()
        manager.startUpdatingLocation()

        let region = CLCircularRegion(
            center: alarm.station.coordinate,
            radius: CLLocationDistance(alarm.radius.rawValue),
            identifier: alarm.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        manager.startMonitoring(for: region)
    }

    func stopMonitoring() {
        if let alarm = monitoredAlarm {
            for region in manager.monitoredRegions where region.identifier == alarm.id.uuidString {
                manager.stopMonitoring(for: region)
            }
        }
        manager.stopMonitoringSignificantLocationChanges()
        manager.stopUpdatingLocation()
        monitoredAlarm = nil
    }

    func distanceToMonitoredStation() -> CLLocationDistance? {
        guard let alarm = monitoredAlarm, let current = currentLocation else { return nil }
        let target = CLLocation(latitude: alarm.station.latitude, longitude: alarm.station.longitude)
        return current.distance(from: target)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = latest
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Task { @MainActor in
            guard let alarm = self.monitoredAlarm, region.identifier == alarm.id.uuidString else { return }
            NotificationScheduler.shared.fireArrivalAlert(for: alarm)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        print("LocationManager error: \(error)")
        #endif
    }
}
