import SwiftUI

@main
struct WakeAtStationApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var alarmStore = AlarmStore()
    @StateObject private var stationRepository = StationRepository()
    @StateObject private var deepLinkRouter = DeepLinkRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(locationManager)
                .environmentObject(alarmStore)
                .environmentObject(stationRepository)
                .environmentObject(deepLinkRouter)
                .onOpenURL { url in
                    deepLinkRouter.handle(url: url, repository: stationRepository)
                }
        }
    }
}
