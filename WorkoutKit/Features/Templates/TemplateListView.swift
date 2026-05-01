import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Environment(\.modelContext) private var context
    @Environment(ProFeatureGate.self) private var gate
    @State private var store: TemplateStore?
    @State private var showCreate = false
    @State private var showPaywallAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if let store {
                    templateList(store: store)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(String(localized: "templates.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if gate.check(.customTemplates) {
                            showCreate = true
                        } else {
                            showPaywallAlert = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                if let store {
                    TemplateEditView(store: store)
                }
            }
            .alert(String(localized: "templates.pro.required"), isPresented: $showPaywallAlert) {
                Button("OK") {}
            }
        }
        .onAppear {
            if store == nil {
                store = TemplateStore(context: context, gate: gate)
            }
        }
    }

    @ViewBuilder
    private func templateList(store: TemplateStore) -> some View {
        if store.templates.isEmpty {
            ContentUnavailableView(
                String(localized: "templates.empty"),
                systemImage: "doc.text"
            )
        } else {
            List {
                ForEach(store.templates) { template in
                    TemplateRow(template: template, store: store)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

private struct TemplateRow: View {
    let template: WorkoutTemplate
    let store: TemplateStore
    @State private var showEdit = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(template.name).font(.headline)
                    if template.isPreset {
                        Text(String(localized: "templates.badge.preset"))
                            .font(.caption2.bold())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
                Text(String(localized: "templates.exercises.count \(template.exerciseSlugs.count)"))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if !template.isPreset {
                Button { showEdit = true } label: {
                    Image(systemName: "pencil").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !template.isPreset {
                Button(role: .destructive) {
                    store.delete(template)
                } label: {
                    Label(String(localized: "templates.delete"), systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            TemplateEditView(store: store, existing: template)
        }
    }
}

struct TemplateEditView: View {
    let store: TemplateStore
    let existing: WorkoutTemplate?
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var slugsText: String

    init(store: TemplateStore, existing: WorkoutTemplate? = nil) {
        self.store = store
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _slugsText = State(initialValue: existing?.exerciseSlugs.joined(separator: ", ") ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "templates.edit.name")) {
                    TextField(String(localized: "templates.edit.name.placeholder"), text: $name)
                }
                Section(String(localized: "templates.edit.exercises")) {
                    TextField(String(localized: "templates.edit.exercises.placeholder"), text: $slugsText, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(existing == nil ? String(localized: "templates.create") : String(localized: "templates.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "templates.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "templates.save")) {
                        let slugs = slugsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        if let existing {
                            store.update(existing, name: name, exerciseSlugs: slugs)
                        } else {
                            store.create(name: name, exerciseSlugs: slugs)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
