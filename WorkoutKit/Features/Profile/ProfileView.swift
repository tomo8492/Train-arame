import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "プロフィール",
                systemImage: "person.fill",
                description: Text("設定・プロフィール情報がここに表示されます。")
            )
            .navigationTitle("プロフィール")
        }
    }
}
