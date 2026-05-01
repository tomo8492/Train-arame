import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(ProFeatureGate.self) private var gate
    @Environment(StoreEnvironment.self) private var storeEnv
    @Environment(\.dismiss) private var dismiss
    @State private var store: PaywallStore?
    @State private var showRestoreAlert = false

    private let features: [(String, String)] = [
        ("clock.arrow.circlepath", String(localized: "paywall.feature.history")),
        ("chart.bar.fill", String(localized: "paywall.feature.charts")),
        ("square.and.pencil", String(localized: "paywall.feature.manual")),
        ("doc.text.fill", String(localized: "paywall.feature.templates"))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    priceSection
                    ctaSection
                    legalSection
                }
                .padding()
            }
            .navigationTitle(String(localized: "paywall.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "paywall.close")) { dismiss() }
                }
            }
            .alert(String(localized: "paywall.restore.alert"), isPresented: $showRestoreAlert) {
                Button("OK") {}
            }
        }
        .task {
            let s = PaywallStore(client: storeEnv.client, gate: gate)
            store = s
            await s.loadProducts()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
            Text(String(localized: "paywall.headline"))
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text(String(localized: "paywall.subheadline"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(features, id: \.0) { icon, label in
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.tint)
                        .frame(width: 32)
                    Text(label)
                        .font(.body)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(label)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var priceSection: some View {
        Group {
            if let store, let product = store.product {
                VStack(spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.displayPrice)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                    Text(String(localized: "paywall.one.time"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ProgressView()
            }
        }
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await store?.purchase() }
            } label: {
                Group {
                    if store?.isLoading == true {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(String(localized: "paywall.cta.purchase"))
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .disabled(store?.product == nil || store?.isLoading == true)
            .accessibilityHint(String(localized: "paywall.cta.purchase.hint", defaultValue: "プレミアムを一度購入すると永続的に利用できます"))

            Button(String(localized: "paywall.cta.restore")) {
                Task {
                    await store?.restore()
                    showRestoreAlert = true
                }
            }
            .font(.subheadline)
            .disabled(store?.isLoading == true)
            .accessibilityHint(String(localized: "paywall.cta.restore.hint", defaultValue: "過去の購入履歴を復元します"))

            if let error = store?.purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var legalSection: some View {
        HStack(spacing: 16) {
            Link(String(localized: "paywall.terms"),
                 destination: URL(string: "https://example.com/terms")!)
            Text("·").foregroundStyle(.secondary)
            Link(String(localized: "paywall.privacy"),
                 destination: URL(string: "https://example.com/privacy")!)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
