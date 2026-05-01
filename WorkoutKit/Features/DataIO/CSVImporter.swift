import Foundation

enum CSVImporter {
    struct CSVRow {
        var date: String
        var exerciseName: String
        var setNumber: Int
        var reps: Int
        var weightKg: Double
        var notes: String
    }

    enum ImportError: Error, Equatable {
        case emptyFile
        case invalidHeader
        case malformedRow(Int)
    }

    private static let requiredHeaders = ["date", "exercise_name", "set_number", "reps", "weight_kg"]

    static func parse(csvString: String) throws -> [CSVRow] {
        let trimmed = csvString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ImportError.emptyFile }

        var lines = trimmed.components(separatedBy: .newlines)
        let headerLine = lines.removeFirst()
        let headers = parseCSVLine(headerLine).map { $0.lowercased() }

        for required in requiredHeaders {
            guard headers.contains(required) else { throw ImportError.invalidHeader }
        }

        let dateIdx = headers.firstIndex(of: "date")!
        let nameIdx = headers.firstIndex(of: "exercise_name")!
        let setIdx = headers.firstIndex(of: "set_number")!
        let repsIdx = headers.firstIndex(of: "reps")!
        let weightIdx = headers.firstIndex(of: "weight_kg")!
        let notesIdx = headers.firstIndex(of: "notes")

        var rows: [CSVRow] = []
        for (lineNumber, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }
            let fields = parseCSVLine(trimmedLine)
            guard fields.count >= requiredHeaders.count else {
                throw ImportError.malformedRow(lineNumber + 2)
            }
            let row = CSVRow(
                date: fields[dateIdx],
                exerciseName: fields[nameIdx],
                setNumber: Int(fields[setIdx]) ?? 0,
                reps: Int(fields[repsIdx]) ?? 0,
                weightKg: Double(fields[weightIdx]) ?? 0,
                notes: notesIdx.flatMap { fields.indices.contains($0) ? fields[$0] : nil } ?? ""
            )
            rows.append(row)
        }
        return rows
    }

    static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var i = line.startIndex

        while i < line.endIndex {
            let c = line[i]
            if c == "\"" {
                if inQuotes && line.index(after: i) < line.endIndex && line[line.index(after: i)] == "\"" {
                    current.append("\"")
                    i = line.index(i, offsetBy: 2)
                    continue
                }
                inQuotes.toggle()
            } else if c == "," && !inQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(c)
            }
            i = line.index(after: i)
        }
        fields.append(current)
        return fields
    }
}
