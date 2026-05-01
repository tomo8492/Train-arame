import SwiftUI

struct ProfileView: View {
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showSettings = true
                    } label: {
                        Label(String(localized: "settings.title"), systemImage: "gearshape.fill")
                    }
                }
            }
            .navigationTitle("プロフィール")
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}
