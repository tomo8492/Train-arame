import SwiftUI
import SwiftData

struct ManualEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var store = ManualEntryStore()

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "manual.section.date")) {
                    DatePicker(
                        String(localized: "manual.date"),
                        selection: $store.date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section(String(localized: "manual.section.sets")) {
                    ForEach($store.setEntries) { $entry in
                        SetEntryRow(entry: $entry)
                    }
                    .onDelete { store.removeSetEntry(at: $0) }

                    Button {
                        store.addSetEntry()
                    } label: {
                        Label(String(localized: "manual.add.set"), systemImage: "plus")
                    }
                }
            }
            .navigationTitle(String(localized: "manual.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "manual.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "manual.save")) {
                        store.save(context: context)
                        dismiss()
                    }
                    .disabled(!store.isValid)
                }
            }
        }
    }
}

private struct SetEntryRow: View {
    @Binding var entry: SetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(String(localized: "manual.exercise.name"), text: $entry.exerciseName)
            HStack {
                Stepper(value: $entry.reps, in: 0...100) {
                    Text(String(localized: "manual.reps \(entry.reps)"))
                }
                Spacer()
                TextField("0.0", value: $entry.weightKg, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                Text("kg").foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
