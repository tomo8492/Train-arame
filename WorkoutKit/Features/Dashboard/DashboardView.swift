import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "ダッシュボード",
                systemImage: "chart.bar.fill",
                description: Text("直近のトレーニングログがここに表示されます。")
            )
            .navigationTitle("ホーム")
        }
    }
}
