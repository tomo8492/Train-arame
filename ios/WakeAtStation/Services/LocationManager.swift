import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var monitoredAlarm: Alarm?
    @Published var firedStages: Set<AlarmStage> = []

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
        stopMonitoring()
        monitoredAlarm = alarm
        firedStages.removeAll()

        manager.startUpdatingLocation()

        let inner = CLCircularRegion(
            center: alarm.station.coordinate,
            radius: alarm.innerRadiusMeters,
            identifier: alarm.regionIdentifier(for: .arrival)
        )
        inner.notifyOnEntry = true
        inner.notifyOnExit = false
        manager.startMonitoring(for: inner)

        if alarm.enableTwoStage {
            let outer = CLCircularRegion(
                center: alarm.station.coordinate,
                radius: alarm.outerRadiusMeters,
                identifier: alarm.regionIdentifier(for: .preAlert)
            )
            outer.notifyOnEntry = true
            outer.notifyOnExit = false
            manager.startMonitoring(for: outer)
        }
    }

    func stopMonitoring() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        manager.stopUpdatingLocation()
        monitoredAlarm = nil
        firedStages.removeAll()
    }

    func distanceToMonitoredStation() -> CLLocationDistance? {
        guard let alarm = monitoredAlarm, let current = currentLocation else { return nil }
        let target = CLLocation(latitude: alarm.station.latitude, longitude: alarm.station.longitude)
        return current.distance(from: target)
    }

    fileprivate func handleRegionEntry(identifier: String) {
        guard let alarm = monitoredAlarm else { return }
        let stage: AlarmStage
        if identifier == alarm.regionIdentifier(for: .arrival) {
            stage = .arrival
        } else if identifier == alarm.regionIdentifier(for: .preAlert) {
            stage = .preAlert
        } else {
            return
        }

        guard !firedStages.contains(stage) else { return }
        firedStages.insert(stage)
        NotificationScheduler.shared.fire(alarm: alarm, stage: stage)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = latest
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let identifier = region.identifier
        Task { @MainActor in
            self.handleRegionEntry(identifier: identifier)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
        print("LocationManager error: \(error)")
        #endif
    }
}
