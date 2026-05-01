import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("ホーム", systemImage: "chart.bar.fill")
                }

            WorkoutView()
                .tabItem {
                    Label("ワークアウト", systemImage: "dumbbell.fill")
                }

            TemplateListView()
                .tabItem {
                    Label(String(localized: "templates.title"), systemImage: "doc.text.fill")
                }

            ExerciseView()
                .tabItem {
                    Label("種目", systemImage: "list.bullet.clipboard.fill")
                }

            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "person.fill")
                }
        }
    }
}
