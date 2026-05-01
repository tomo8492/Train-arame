import SwiftUI

struct WorkoutView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "ワークアウト",
                systemImage: "dumbbell.fill",
                description: Text("トレーニングセッションをここで開始します。")
            )
            .navigationTitle("ワークアウト")
        }
    }
}
