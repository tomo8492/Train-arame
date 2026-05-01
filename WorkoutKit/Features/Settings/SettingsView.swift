import SwiftUI

struct SettingsView: View {
    @Environment(ProFeatureGate.self) private var gate
    @State private var preferences = UserPreferences()
    @State private var isRestoring = false
    @State private var restoreMessage: String?
    @State private var showRestoreAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Units section
                Section(String(localized: "settings.section.units")) {
                    Picker(String(localized: "settings.weight.unit"), selection: $preferences.weightUnit) {
                        ForEach(WeightUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                }

                // Appearance section
                Section(String(localized: "settings.section.appearance")) {
                    Picker(String(localized: "settings.theme"), selection: $preferences.colorSchemePreference) {
                        Text(String(localized: "settings.theme.system")).tag("system")
                        Text(String(localized: "settings.theme.light")).tag("light")
                        Text(String(localized: "settings.theme.dark")).tag("dark")
                    }
                }

                Section(String(localized: "settings.section.pro")) {
                    if !gate.isPremium {
                        NavigationLink(String(localized: "settings.upgrade")) {
                            Text(String(localized: "settings.upgrade"))
                                .padding()
                        }
                    }
                    Button {
                        restorePurchases()
                    } label: {
                        HStack {
                            Text(String(localized: "settings.restore.purchase"))
                            if isRestoring {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRestoring)
                }

                Section(String(localized: "settings.section.about")) {
                    NavigationLink(String(localized: "settings.about")) {
                        AboutView()
                    }
                }

                Section {
                    HStack {
                        Text(String(localized: "settings.version"))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(String(localized: "settings.title"))
            .alert(restoreMessage ?? "", isPresented: $showRestoreAlert) {
                Button("OK") {}
            }
        }
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                isRestoring = false
                restoreMessage = String(localized: "settings.restore.success")
                showRestoreAlert = true
            }
        }
    }
}
