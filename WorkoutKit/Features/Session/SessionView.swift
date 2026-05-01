import SwiftUI

struct SessionView: View {

    // MARK: - Dependencies

    let store: SessionStore

    // MARK: - Local state

    @Environment(\.dismiss) private var dismiss
    @SceneStorage("session.currentIndex") private var savedIndex: Int = 0
    @State private var showFinishConfirm: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar

                ScrollViewReader { proxy in
                    List {
                        warmupSection
                        mainSection
                        cooldownSection
                    }
                    .listStyle(.insetGrouped)
                    .onChange(of: store.currentIndex) { _, _ in
                        if let id = store.currentSet?.id {
                            withAnimation { proxy.scrollTo(id, anchor: .center) }
                        }
                        savedIndex = store.currentIndex
                    }
                    .onAppear {
                        if let id = store.currentSet?.id {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }

                bottomBar
            }
            .navigationTitle(String(localized: "session.progress"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "session.finish"), role: .destructive) {
                        showFinishConfirm = true
                    }
                    .foregroundStyle(.red)
                }
            }
            .confirmationDialog(
                String(localized: "session.finish.confirm"),
                isPresented: $showFinishConfirm,
                titleVisibility: .visible
            ) {
                Button(String(localized: "session.finish"), role: .destructive) {
                    store.finish()
                    dismiss()
                }
                Button(String(localized: "builder.back"), role: .cancel) {}
            }
        }
        .disableIdleTimer(true)
        .onAppear {
            // Restore SceneStorage index — only if store hasn't progressed further
            if savedIndex < store.sets.count && savedIndex > store.currentIndex {
                // The store manages its own currentIndex; savedIndex is only for scrolling hint
            }
        }
        .onDisappear {
            store.cancelRestTimer()
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var warmupSection: some View {
        let warmupSets = store.sets.filter { $0.section == .warmup }
        if !warmupSets.isEmpty {
            Section(String(localized: "session.section.warmup")) {
                ForEach(warmupSets) { set in
                    setRow(for: set)
                }
            }
        }
    }

    @ViewBuilder
    private var mainSection: some View {
        let mainSets = store.sets.filter { $0.section == .main }
        if !mainSets.isEmpty {
            Section(String(localized: "session.section.main")) {
                ForEach(mainSets) { set in
                    setRow(for: set)
                }
            }
        }
    }

    @ViewBuilder
    private var cooldownSection: some View {
        let cooldownSets = store.sets.filter { $0.section == .cooldown }
        if !cooldownSets.isEmpty {
            Section(String(localized: "session.section.cooldown")) {
                ForEach(cooldownSets) { set in
                    setRow(for: set)
                }
            }
        }
    }

    // MARK: - Set Row

    @ViewBuilder
    private func setRow(for set: ExerciseSet) -> some View {
        if let idx = store.sets.firstIndex(where: { $0.id == set.id }),
           idx == store.currentIndex && !set.isCompleted {
            ActiveSetRow(set: set, onComplete: { reps, weightKg, rpe in
                store.completeCurrentSet(reps: reps, weightKg: weightKg, rpe: rpe)
            })
            .id(set.id)
            .listRowBackground(Color.accentColor.opacity(0.08))
        } else {
            CompactSetRow(set: set)
                .id(set.id)
        }
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemFill))
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: geo.size.width * store.progress)
                    .animation(.easeInOut, value: store.progress)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 8) {
            if store.isResting {
                restTimerRow
            }
            HStack {
                Button(String(localized: "session.skip")) {
                    store.skipCurrentSet()
                }
                .buttonStyle(.bordered)
                .disabled(store.isFinished)

                Spacer()

                if store.isResting {
                    Button(String(localized: "builder.back")) {
                        store.cancelRestTimer()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(.bar)
    }

    private var restTimerRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .foregroundStyle(.secondary)
            Text(String(localized: "session.rest.label"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(timeString(from: store.secondsRemaining))
                .font(.title3.monospacedDigit())
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.horizontal)
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Active Set Row

private struct ActiveSetRow: View {
    let set: ExerciseSet
    let onComplete: (Int, Double, Int?) -> Void

    @State private var reps: Int
    @State private var weightKg: Double
    @State private var rpe: Int = 0  // 0 = not set

    init(set: ExerciseSet, onComplete: @escaping (Int, Double, Int?) -> Void) {
        self.set = set
        self.onComplete = onComplete
        _reps = State(initialValue: set.reps)
        _weightKg = State(initialValue: set.weightKg)
        _rpe = State(initialValue: set.rpe ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(set.exerciseName)
                    .font(.headline)
                Text(set.exerciseNameEn)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Reps stepper
            HStack {
                Text("Reps")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Stepper("\(reps)", value: $reps, in: 1...100)
                    .fixedSize()
            }

            // Weight field
            HStack {
                Text("kg")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                TextField("0", value: $weightKg, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
            }

            // RPE picker (optional)
            HStack {
                Text(String(localized: "session.rpe.label"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("", selection: $rpe) {
                    Text("-").tag(0)
                    ForEach(1...10, id: \.self) { val in
                        Text("\(val)").tag(val)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 70)
            }

            Button(String(localized: "session.complete.set")) {
                onComplete(reps, weightKg, rpe == 0 ? nil : rpe)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Compact Set Row

private struct CompactSetRow: View {
    let set: ExerciseSet

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(set.exerciseName)
                    .font(.body)
                    .foregroundStyle(set.isCompleted ? .secondary : .primary)
                    .strikethrough(set.isCompleted)
                Text(set.exerciseNameEn)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(set.isCompleted ? .green : .secondary)
        }
        .padding(.vertical, 2)
    }
}
