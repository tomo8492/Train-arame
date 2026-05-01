import SwiftUI

struct ExerciseView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "種目",
                systemImage: "list.bullet.clipboard.fill",
                description: Text("登録済みの種目一覧と履歴がここに表示されます。")
            )
            .navigationTitle("種目")
        }
    }
}
