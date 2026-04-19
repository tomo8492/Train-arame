import SwiftUI

struct StationSearchView: View {
    @StateObject private var repository = StationRepository()
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var query: String = ""
    @State private var radius: AlarmRadius = .medium

    var body: some View {
        NavigationStack {
            VStack {
                Picker("通知距離", selection: $radius) {
                    ForEach(AlarmRadius.allCases) { r in
                        Text(r.label).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List(results) { station in
                    Button {
                        alarmStore.add(Alarm(station: station, radius: radius))
                    } label: {
                        VStack(alignment: .leading) {
                            Text(station.name).font(.headline)
                            Text(station.lineName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "駅名・路線名")
            .navigationTitle("駅を選ぶ")
        }
    }

    private var results: [Station] {
        query.isEmpty ? alarmStore.favorites : repository.search(query)
    }
}
