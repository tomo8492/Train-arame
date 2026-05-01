import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let gate: ProFeatureGate
    let feature: ProFeature

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "star.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.yellow)
            Text(String(localized: "paywall.title"))
                .font(.title.bold())
            Text(featureDescription)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Button(String(localized: "paywall.unlock.demo")) {
                gate.unlock()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            Button(String(localized: "paywall.dismiss")) {
                dismiss()
            }
            .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
    }

    private var featureDescription: String {
        switch feature {
        case .unlimitedHistory:
            return String(localized: "paywall.desc.unlimited_history")
        case .advancedCharts:
            return String(localized: "paywall.desc.advanced_charts")
        default:
            return String(localized: "paywall.desc.generic")
        }
    }
}
