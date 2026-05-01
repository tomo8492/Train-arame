import SwiftUI

struct HistoryView: View {
    @State private var store: HistoryStore
    private let gate: ProFeatureGate
    @State private var showPaywall = false

    init(store: HistoryStore, gate: ProFeatureGate) {
        _store = State(initialValue: store)
        self.gate = gate
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                modePicker
                    .padding(.horizontal)
                    .padding(.top, 8)
                switch store.displayMode {
                case .list: listContent
                case .calendar: calendarContent
                }
            }
            .navigationTitle(String(localized: "history.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        HistoryChartsView(weeklyData: store.weeklyVolume, gate: gate)
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(gate: gate, feature: .unlimitedHistory)
            }
        }
    }

    private var modePicker: some View {
        Picker("", selection: $store.displayMode) {
            Text(String(localized: "history.mode.list")).tag(HistoryStore.DisplayMode.list)
            Text(String(localized: "history.mode.calendar")).tag(HistoryStore.DisplayMode.calendar)
        }
        .pickerStyle(.segmented)
    }

    private var listContent: some View {
        Group {
            if store.visibleSessions.isEmpty {
                ContentUnavailableView(
                    String(localized: "history.empty"),
                    systemImage: "calendar.badge.clock"
                )
            } else {
                List {
                    ForEach(store.sessionsByWeek, id: \.weekStart) { group in
                        Section(header: weekHeader(group.weekStart)) {
                            ForEach(group.sessions) { session in
                                sessionRow(session)
                            }
                        }
                    }
                    if store.needsPaywall { paywallRow }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    private func weekHeader(_ weekStart: Date) -> some View {
        Text(weekStart, format: .dateTime.month().day())
            .font(.subheadline.weight(.semibold))
    }

    private func sessionRow(_ session: WorkoutSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.startedAt, format: .dateTime.month().day().hour().minute())
                    .font(.subheadline)
                Text("\(session.completedSets) セット完了")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let finishedAt = session.finishedAt {
                let duration = finishedAt.timeIntervalSince(session.startedAt)
                Text(Duration.seconds(duration), format: .time(pattern: .minuteSecond))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var paywallRow: some View {
        Button {
            showPaywall = true
        } label: {
            HStack {
                Image(systemName: "lock.fill").foregroundStyle(.secondary)
                Text(String(localized: "history.unlock.cta")).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary).font(.caption)
            }
        }
    }

    private var calendarContent: some View {
        VStack(spacing: 16) {
            DatePicker("", selection: $store.selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)
            let dayStart = Calendar.current.startOfDay(for: store.selectedDate)
            let sessionsOnDay = store.visibleSessions.filter {
                Calendar.current.startOfDay(for: $0.startedAt) == dayStart
            }
            if sessionsOnDay.isEmpty {
                Text(String(localized: "history.empty"))
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                List(sessionsOnDay) { session in
                    sessionRow(session)
                }
                .listStyle(.insetGrouped)
                .frame(maxHeight: 300)
            }
            Spacer()
        }
    }
}
