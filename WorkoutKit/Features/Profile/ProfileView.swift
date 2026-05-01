import SwiftUI

struct ProfileView: View {
    @Environment(ProFeatureGate.self) private var gate
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(gate.isPremium
                                 ? String(localized: "profile.pro.active")
                                 : String(localized: "profile.pro.cta"))
                                .font(.headline)
                            if !gate.isPremium {
                                Text(String(localized: "profile.pro.subtitle"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if gate.isPremium {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.yellow)
                                .font(.title2)
                        } else {
                            Button(String(localized: "profile.pro.button")) {
                                showPaywall = true
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(String(localized: "profile.title"))
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}
