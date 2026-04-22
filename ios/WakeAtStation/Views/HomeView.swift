import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var alarmStore: AlarmStore
    @EnvironmentObject var deepLinkRouter: DeepLinkRouter
    @State private var selectedStation: Station?

    var body: some View {
        NavigationStack {
            List {
                if let alarm = locationManager.monitoredAlarm {
                    Section("監視中") {
                        ActiveAlarmCard(alarm: alarm)
                    }
                }

                if !alarmStore.favorites.isEmpty {
                    Section("お気に入り") {
                        ForEach(alarmStore.favorites) { station in
                            StationRowButton(station: station) { selectedStation = station }
                        }
                        .onDelete { offsets in
                            for i in offsets {
                                alarmStore.toggleFavorite(alarmStore.favorites[i])
                            }
                        }
                    }
                }

                if !alarmStore.recents.isEmpty {
                    Section("最近使った駅") {
                        ForEach(alarmStore.recents) { station in
                            StationRowButton(station: station) { selectedStation = station }
                        }
                    }
                }

                if locationManager.monitoredAlarm == nil
                    && alarmStore.favorites.isEmpty
                    && alarmStore.recents.isEmpty {
                    EmptyStateView()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("駅ウェイク")
            .sheet(item: $selectedStation) { station in
                StationDetailSheet(station: station)
            }
            .onReceive(deepLinkRouter.$pendingStation.compactMap { $0 }) { station in
                selectedStation = station
                deepLinkRouter.pendingStation = nil
            }
        }
    }
}

private struct StationRowButton: View {
    let station: Station
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(station.name).font(.headline).foregroundStyle(.primary)
                Text(station.linesSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct ActiveAlarmCard: View {
    @EnvironmentObject var locationManager: LocationManager
    let alarm: Alarm

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.circle.fill").foregroundStyle(.tint)
                Text(alarm.station.name).font(.title2.bold())
            }
            Text(alarm.station.linesSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if let distance = locationManager.distanceToMonitoredStation() {
                Text("現在地から \(formatDistance(distance))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Text("通知半径 \(alarm.radius.label)\(alarm.enableTwoStage ? " ・ 予告ON" : "")")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Button(role: .destructive) {
                locationManager.stopMonitoring()
            } label: {
                Label("監視を停止", systemImage: "stop.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }

    private func formatDistance(_ m: Double) -> String {
        if m >= 1000 {
            return String(format: "%.1f km", m / 1000)
        }
        return "\(Int(m)) m"
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("降車駅を設定しよう")
                .font(.headline)
            Text("「駅検索」タブから目的地を選ぶと、\n接近時にバイブで起こします。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
