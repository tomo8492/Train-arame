import SwiftUI
import StoreKit
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var alarmStore: AlarmStore
    @AppStorage("defaultRadius") private var defaultRadiusRaw: Int = AlarmRadius.medium.rawValue
    @AppStorage("defaultTwoStage") private var defaultTwoStage: Bool = true
    @Environment(\.requestReview) private var requestReview
    @State private var showClearRecentsConfirm = false

    private var defaultRadius: Binding<AlarmRadius> {
        Binding(
            get: { AlarmRadius(rawValue: defaultRadiusRaw) ?? .medium },
            set: { defaultRadiusRaw = $0.rawValue }
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
                    Link("お問い合わせ",
                         destination: URL(string: "mailto:support@example.com?subject=駅ウェイク")!)
                }

                Section("このアプリについて") {
                    Link("プライバシーポリシー", destination: URL(string: "https://example.com/privacy")!)
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
