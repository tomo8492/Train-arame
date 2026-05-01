import Foundation

enum JSONImporter {
    enum ImportError: Error {
        case invalidFormat
        case versionMismatch
    }

    static func parse(jsonData: Data) throws -> [WorkoutSession] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(HistoryExporter.ExportPayload.self, from: jsonData)
        return payload.sessions.map { dto in
            let session = WorkoutSession(startedAt: dto.startedAt)
            session.finishedAt = dto.finishedAt
            session.totalSets = dto.totalSets
            session.completedSets = dto.completedSets
            return session
        }
    }
}
