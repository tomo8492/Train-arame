import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var alarmStore: AlarmStore

    var body: some View {
        NavigationStack {
            List {
                if let alarm = locationManager.monitoredAlarm {
                    Section("監視中") {
                        ActiveAlarmCard(alarm: alarm)
                    }
                }

                Section("登録済みアラーム") {
                    if alarmStore.alarms.isEmpty {
                        Text("駅を検索してアラームを設定してください")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(alarmStore.alarms) { alarm in
                            AlarmRow(alarm: alarm)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                alarmStore.remove(alarmStore.alarms[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("WakeAtStation")
        }
    }
}

private struct ActiveAlarmCard: View {
    @EnvironmentObject var locationManager: LocationManager
    let alarm: Alarm

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(alarm.station.name)
                .font(.title2.bold())
            Text(alarm.station.linesSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if let distance = locationManager.distanceToMonitoredStation() {
                Text("現在 \(Int(distance)) m")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Button(role: .destructive) {
                locationManager.stopMonitoring()
            } label: {
                Label("監視を停止", systemImage: "stop.circle")
            }
        }
        .padding(.vertical, 4)
    }
}

private struct AlarmRow: View {
    @EnvironmentObject var locationManager: LocationManager
    let alarm: Alarm

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(alarm.station.name).font(.headline)
                Text("\(alarm.station.linesSummary) ・ \(alarm.radius.label)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button("開始") {
                locationManager.startMonitoring(alarm)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
