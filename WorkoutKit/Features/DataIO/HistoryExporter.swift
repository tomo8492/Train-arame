import Foundation

enum HistoryExporter {
    struct SessionDTO: Codable {
        var id: UUID
        var startedAt: Date
        var finishedAt: Date?
        var totalSets: Int
        var completedSets: Int
    }

    struct ExportPayload: Codable {
        var version: String
        var exportedAt: Date
        var sessions: [SessionDTO]
    }

    static func exportJSON(sessions: [WorkoutSession]) throws -> Data {
        let dtos = sessions.map { s in
            SessionDTO(
                id: s.id,
                startedAt: s.startedAt,
                finishedAt: s.finishedAt,
                totalSets: s.totalSets,
                completedSets: s.completedSets
            )
        }
        let payload = ExportPayload(version: "1.0", exportedAt: .now, sessions: dtos)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }

    static func exportCSV(sessions: [WorkoutSession]) -> String {
        var lines = ["date,started_at,finished_at,total_sets,completed_sets"]
        let fmt = ISO8601DateFormatter()
        for s in sessions {
            let finished = s.finishedAt.map { fmt.string(from: $0) } ?? ""
            lines.append("\(fmt.string(from: s.startedAt)),\(fmt.string(from: s.startedAt)),\(finished),\(s.totalSets),\(s.completedSets)")
        }
        return lines.joined(separator: "\n")
    }
}
