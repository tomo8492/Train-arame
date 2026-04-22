import SwiftUI

struct StationDetailSheet: View {
    let station: Station
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var alarmStore: AlarmStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("defaultRadius") private var defaultRadiusRaw: Int = AlarmRadius.medium.rawValue
    @AppStorage("defaultTwoStage") private var defaultTwoStage: Bool = true

    @State private var radius: AlarmRadius = .medium
    @State private var twoStage: Bool = true
    @State private var hasAppliedDefaults: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.name).font(.title.bold())
                        if let kana = station.nameKana {
                            Text(kana).font(.caption).foregroundStyle(.secondary)
                        }
                        Text(station.linesSummary)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                }

                Section("通知設定") {
                    Picker("通知半径", selection: $radius) {
                        ForEach(AlarmRadius.allCases) { r in
                            Text(r.label).tag(r)
                        }
                    }
                    Toggle("2駅前で予告通知（弱バイブ）", isOn: $twoStage)
                }

                Section {
                    Button {
                        start()
                    } label: {
                        Label("ここで起こしてもらう", systemImage: "alarm.fill")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .navigationTitle("目的地")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                guard !hasAppliedDefaults else { return }
                radius = AlarmRadius(rawValue: defaultRadiusRaw) ?? .medium
                twoStage = defaultTwoStage
                hasAppliedDefaults = true
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        alarmStore.toggleFavorite(station)
                    } label: {
                        Image(systemName: alarmStore.isFavorite(station) ? "star.fill" : "star")
                    }
                }
            }
        }
    }

    private func start() {
        let alarm = Alarm(station: station, radius: radius, enableTwoStage: twoStage)
        locationManager.startMonitoring(alarm)
        alarmStore.pushRecent(station)
        if locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        dismiss()
    }
}
