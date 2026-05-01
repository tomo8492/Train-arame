import SwiftUI

struct TimeStepView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Text("\(Int(store.minutesAvailable))分")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.tint)
                        .frame(maxWidth: .infinity)

                    Slider(
                        value: $store.minutesAvailable,
                        in: 15...90,
                        step: 5
                    )

                    HStack {
                        Text(String(localized: "time.min", defaultValue: "15分"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(localized: "time.max", defaultValue: "90分"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text(String(localized: "builder.step.time"))
            }

            Section {
                Toggle(
                    String(localized: "time.include.warmup", defaultValue: "ウォームアップを含める"),
                    isOn: $store.includeWarmup
                )

                Toggle(
                    String(localized: "time.include.cooldown", defaultValue: "クールダウンを含める"),
                    isOn: $store.includeCooldown
                )
            } header: {
                Text(String(localized: "time.options.header", defaultValue: "オプション"))
            } footer: {
                Text(String(localized: "time.options.footer",
                            defaultValue: "ウォームアップ・クールダウンはそれぞれ約5分です。"))
                    .font(.caption)
            }
        }
    }
}
