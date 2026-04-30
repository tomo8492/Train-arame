import SwiftUI
import StoreKit
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var alarmStore: AlarmStore
    @AppStorage("defaultRadius") private var defaultRadiusRaw: Int = AlarmRadius.medium.rawValue
    @AppStorage("defaultTwoStage") private var defaultTwoStage: Bool = true
    @AppStorage("hapticIntensity") private var hapticIntensityRaw: String = HapticIntensity.strong.rawValue
    @AppStorage("hapticDuration") private var hapticDurationRaw: Int = HapticDuration.sec120.rawValue
    @AppStorage("iphoneVibrationEnabled") private var iphoneVibrationEnabled: Bool = true
    @Environment(\.requestReview) private var requestReview
    @State private var showClearRecentsConfirm = false

    private var defaultRadius: Binding<AlarmRadius> {
        Binding(
            get: { AlarmRadius(rawValue: defaultRadiusRaw) ?? .medium },
            set: { defaultRadiusRaw = $0.rawValue }
        )
    }

    private var hapticIntensity: Binding<HapticIntensity> {
        Binding(
            get: { HapticIntensity(rawValue: hapticIntensityRaw) ?? .strong },
            set: { hapticIntensityRaw = $0.rawValue }
        )
    }

    private var hapticDuration: Binding<HapticDuration> {
        Binding(
            get: { HapticDuration(rawValue: hapticDurationRaw) ?? .sec120 },
            set: { hapticDurationRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("通知のデフォルト") {
                    Picker("通知半径", selection: defaultRadius) {
                        ForEach(AlarmRadius.allCases) { r in
                            Text(r.label).tag(r)
                        }
                    }
                    Toggle("2駅前で予告通知", isOn: $defaultTwoStage)
                }

                Section {
                    Picker("Watchバイブの強さ", selection: hapticIntensity) {
                        ForEach(HapticIntensity.allCases) { i in
                            Text(i.label).tag(i)
                        }
                    }
                    Picker("バイブ継続時間", selection: hapticDuration) {
                        ForEach(HapticDuration.allCases) { d in
                            Text(d.label).tag(d)
                        }
                    }
                    Toggle("iPhone本体でもバイブする", isOn: $iphoneVibrationEnabled)
                } header: {
                    Text("バイブレーション")
                } footer: {
                    Text("iPhoneの振動強度はOSの仕様で変更できません。Watchは強さで間隔(0.7〜1.5秒)が変わります。")
                        .font(.caption2)
                }

                Section("位置情報") {
                    HStack {
                        Text("権限")
                        Spacer()
                        Text(authorizationText)
                            .foregroundStyle(.secondary)
                    }
                    if locationManager.authorizationStatus != .authorizedAlways {
                        Button("常に許可をリクエスト") {
                            locationManager.requestAlwaysAuthorization()
                        }
                    }
                }

                Section("データ") {
                    Button(role: .destructive) {
                        showClearRecentsConfirm = true
                    } label: {
                        Text("最近使った駅をクリア")
                    }
                    .disabled(alarmStore.recents.isEmpty)
                }

                Section("フィードバック") {
                    Button("アプリを評価する") { requestReview() }
                    if let url = contactURL {
                        Link("お問い合わせ", destination: url)
                    }
                }

                Section("このアプリについて") {
                    if let url = privacyPolicyURL {
                        Link("プライバシーポリシー", destination: url)
                    }
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("データ出典") {
                    Text("駅データ: 国土交通省「国土数値情報（鉄道データ N02-24）」")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("設定")
            .confirmationDialog(
                "最近使った駅を全て削除しますか？",
                isPresented: $showClearRecentsConfirm,
                titleVisibility: .visible
            ) {
                Button("削除", role: .destructive) {
                    alarmStore.clearRecents()
                }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }

    private var contactURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "support@example.com"
        components.queryItems = [URLQueryItem(name: "subject", value: "駅ウェイク")]
        return components.url
    }

    private var privacyPolicyURL: URL? {
        URL(string: "https://example.com/privacy")
    }

    private var authorizationText: String {
        switch locationManager.authorizationStatus {
        case .authorizedAlways: return "常に許可"
        case .authorizedWhenInUse: return "使用中のみ"
        case .denied: return "拒否"
        case .restricted: return "制限中"
        case .notDetermined: return "未設定"
        @unknown default: return "-"
        }
    }
}
