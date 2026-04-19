import SwiftUI

@main
struct WakeAtStationApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var alarmStore = AlarmStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(locationManager)
                .environmentObject(alarmStore)
        }
    }
}
