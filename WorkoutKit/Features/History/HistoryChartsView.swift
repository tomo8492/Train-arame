import SwiftUI
import Charts

struct HistoryChartsView: View {
    let weeklyData: [(week: Date, sets: Int)]
    let gate: ProFeatureGate

    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                weeklyVolumeChart
                Divider()
                if gate.check(.advancedCharts) {
                    monthlyHeatmap
                } else {
                    lockedChartPlaceholder
                }
            }
            .padding()
        }
        .navigationTitle(String(localized: "history.charts.title"))
        .sheet(isPresented: $showPaywall) {
            PaywallView(gate: gate, feature: .advancedCharts)
        }
    }

    private var weeklyVolumeChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "history.weekly.label"))
                .font(.headline)
            if weeklyData.isEmpty {
                Text(String(localized: "history.empty"))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(weeklyData, id: \.week) { item in
                    BarMark(
                        x: .value("週", item.week, unit: .weekOfYear),
                        y: .value("セット数", item.sets)
                    )
                    .foregroundStyle(Color.accentColor)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .weekOfYear)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.month(.abbreviated).day())
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
        }
    }

    private var monthlyHeatmap: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("月次ヒートマップ")
                .font(.headline)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            let cells = heatmapCells()
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(cells, id: \.date) { cell in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(heatmapColor(for: cell.sets))
                        .frame(height: 28)
                        .overlay(
                            Text("\(Calendar.current.component(.day, from: cell.date))")
                                .font(.caption2)
                                .foregroundStyle(cell.sets > 0 ? .white : .secondary)
                        )
                }
            }
        }
    }

    private func heatmapCells() -> [(date: Date, sets: Int)] {
        let calendar = Calendar.current
        let now = Date.now
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start else { return [] }
        let range = calendar.range(of: .day, in: .month, for: now) ?? (1..<31)
        var setsByDay: [Date: Int] = [:]
        for item in weeklyData {
            let dayStart = calendar.startOfDay(for: item.week)
            setsByDay[dayStart] = item.sets
        }
        return range.compactMap { day -> (date: Date, sets: Int)? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { return nil }
            let dayStart = calendar.startOfDay(for: date)
            return (date: date, sets: setsByDay[dayStart] ?? 0)
        }
    }

    private func heatmapColor(for sets: Int) -> Color {
        switch sets {
        case 0:       return Color(.systemFill)
        case 1...10:  return .green.opacity(0.4)
        case 11...20: return .green.opacity(0.7)
        default:      return .green
        }
    }

    private var lockedChartPlaceholder: some View {
        ContentUnavailableView {
            Label("月次ヒートマップ", systemImage: "lock.fill")
        } description: {
            Text(String(localized: "paywall.desc.advanced_charts"))
        } actions: {
            Button("Pro にアップグレード") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(minHeight: 200)
    }
}
