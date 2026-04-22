import SwiftUI

struct StationSearchView: View {
    @EnvironmentObject var repository: StationRepository
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var query: String = ""
    @State private var selectedStation: Station?

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    if !alarmStore.favorites.isEmpty {
                        Section("お気に入り") {
                            ForEach(alarmStore.favorites) { station in
                                row(for: station)
                            }
                        }
                    }
                    if !alarmStore.recents.isEmpty {
                        Section("最近使った駅") {
                            ForEach(alarmStore.recents) { station in
                                row(for: station)
                            }
                        }
                    }
                    if alarmStore.favorites.isEmpty && alarmStore.recents.isEmpty {
                        Section {
                            Text("駅名・かな・路線名で検索できます\n例: 新宿 / しんじゅく / 山手線")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 8)
                        }
                    }
                } else {
                    let results = repository.search(query)
                    if results.isEmpty {
                        Section {
                            Text("該当する駅が見つかりません")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Section("検索結果 \(results.count)件") {
                            ForEach(results) { station in
                                row(for: station)
                            }
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "駅名・かな・路線名")
            .autocorrectionDisabled()
            .navigationTitle("駅を検索")
            .sheet(item: $selectedStation) { station in
                StationDetailSheet(station: station)
            }
        }
    }

    private func row(for station: Station) -> some View {
        Button {
            selectedStation = station
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(station.name).font(.headline).foregroundStyle(.primary)
                Text(station.linesSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
