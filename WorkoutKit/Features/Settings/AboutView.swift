import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text(String(localized: "about.version"))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                        .foregroundStyle(.secondary)
                }
            }

            Section(String(localized: "about.section.disclaimer")) {
                Text(String(localized: "about.disclaimer.text"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section(String(localized: "about.section.links")) {
                Link(String(localized: "about.privacy.policy"),
                     destination: URL(string: "https://example.com/privacy")!)
                Link(String(localized: "about.terms"),
                     destination: URL(string: "https://example.com/terms")!)
            }
        }
        .navigationTitle(String(localized: "settings.about"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
