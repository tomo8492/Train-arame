import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(ProFeatureGate.self) private var gate
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("ホーム", systemImage: "chart.bar.fill") }
            WorkoutView()
                .tabItem { Label("ワークアウト", systemImage: "dumbbell.fill") }
            ExerciseView()
                .tabItem { Label("種目", systemImage: "list.bullet.clipboard.fill") }
            historyTab
            ProfileView()
                .tabItem { Label("プロフィール", systemImage: "person.fill") }
        }
    }

    @ViewBuilder
    private var historyTab: some View {
        let store = HistoryStore(sessions: sessions, gate: gate)
        HistoryView(store: store, gate: gate)
            .tabItem {
                Label(String(localized: "history.title"), systemImage: "clock.arrow.circlepath")
            }
    }
}
