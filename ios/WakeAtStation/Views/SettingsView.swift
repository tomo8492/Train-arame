import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationStack {
            Form {
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
                    Text("駅データ: 国土交通省「国土数値情報（鉄道データ N02）」")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("設定")
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
