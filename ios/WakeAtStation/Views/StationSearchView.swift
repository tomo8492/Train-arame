import SwiftUI

struct StationSearchView: View {
    @StateObject private var repository = StationRepository()
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var query: String = ""
    @State private var radius: AlarmRadius = .medium
    @State private var twoStage: Bool = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Picker("通知距離", selection: $radius) {
                    ForEach(AlarmRadius.allCases) { r in
                        Text(r.label).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Toggle("2駅前で予告通知（弱バイブ）", isOn: $twoStage)
                    .padding(.horizontal)

                List {
                    if query.isEmpty && !alarmStore.favorites.isEmpty {
                        Section("お気に入り") {
                            ForEach(alarmStore.favorites) { station in
                                row(for: station)
                            }
                        }
                    }
                    if !query.isEmpty {
                        Section("検索結果") {
                            ForEach(repository.search(query)) { station in
                                row(for: station)
                            }
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "駅名・路線名")
            .navigationTitle("駅を選ぶ")
        }
    }

    private func row(for station: Station) -> some View {
        Button {
            let alarm = Alarm(station: station, radius: radius, enableTwoStage: twoStage)
            alarmStore.add(alarm)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(station.name).font(.headline)
                    Text(station.linesSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Button {
                    alarmStore.toggleFavorite(station)
                } label: {
                    Image(systemName: alarmStore.favorites.contains(station) ? "star.fill" : "star")
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
