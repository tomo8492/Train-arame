import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DataIOView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @State private var showImportPicker = false
    @State private var showShareSheet = false
    @State private var exportData: Data?
    @State private var alertMessage: String?
    @State private var showAlert = false
    @State private var exportFormat: ExportFormat = .json

    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
    }

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "dataio.section.export")) {
                    Picker(String(localized: "dataio.format"), selection: $exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button {
                        exportHistory()
                    } label: {
                        Label(String(localized: "dataio.export"), systemImage: "square.and.arrow.up")
                    }
                }

                Section(String(localized: "dataio.section.import")) {
                    Button {
                        showImportPicker = true
                    } label: {
                        Label(String(localized: "dataio.import.csv"), systemImage: "square.and.arrow.down")
                    }
                }
            }
            .navigationTitle(String(localized: "dataio.title"))
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [.commaSeparatedText, .json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = exportData {
                    ShareSheetView(data: data, format: exportFormat)
                }
            }
            .alert(alertMessage ?? "", isPresented: $showAlert) {
                Button("OK") {}
            }
        }
    }

    private func exportHistory() {
        do {
            switch exportFormat {
            case .json:
                exportData = try HistoryExporter.exportJSON(sessions: sessions)
            case .csv:
                exportData = HistoryExporter.exportCSV(sessions: sessions).data(using: .utf8)
            }
            showShareSheet = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            let data = try Data(contentsOf: url)

            if url.pathExtension.lowercased() == "json" {
                let sessions = try JSONImporter.parse(jsonData: data)
                for session in sessions { context.insert(session) }
                alertMessage = String(localized: "dataio.import.success \(sessions.count)")
            } else {
                let csvString = String(data: data, encoding: .utf8) ?? ""
                let rows = try CSVImporter.parse(csvString: csvString)
                let grouped = Dictionary(grouping: rows, by: \.date)
                for (_, _) in grouped {
                    let session = WorkoutSession(startedAt: .now)
                    session.totalSets = 0
                    session.completedSets = 0
                    context.insert(session)
                }
                alertMessage = String(localized: "dataio.import.success \(grouped.count)")
            }
            showAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}

private struct ShareSheetView: UIViewControllerRepresentable {
    let data: Data
    let format: DataIOView.ExportFormat

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let ext = format == .json ? "json" : "csv"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("workoutkit_export.\(ext)")
        try? data.write(to: url)
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
