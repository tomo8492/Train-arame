import SwiftUI

@main
struct WakeAtStationWatchApp: App {
    @StateObject private var receiver = WatchArrivalReceiver()

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(receiver)
        }
    }
}
