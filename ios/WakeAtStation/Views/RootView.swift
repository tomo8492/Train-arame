import SwiftUI

struct RootView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var alarmStore: AlarmStore
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "alarm.fill") }
            StationSearchView()
                .tabItem { Label("駅検索", systemImage: "magnifyingglass") }
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
        .task {
            NotificationDelegate.shared.register(locationManager: locationManager)
            await NotificationScheduler.shared.requestAuthorization()
        }
        .sheet(isPresented: .constant(!hasSeenOnboarding)) {
            OnboardingView()
                .onDisappear { hasSeenOnboarding = true }
        }
    }
}
