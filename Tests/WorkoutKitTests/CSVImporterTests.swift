import Testing
@testable import WorkoutKit

@Suite("CSVImporter")
struct CSVImporterTests {
    private let sampleCSV = """
date,exercise_name,set_number,reps,weight_kg,notes
2024-01-15,Bench Press,1,10,80,""
2024-01-15,Bench Press,2,8,85,""
2024-01-15,Squat,1,5,100,""
2024-01-16,Deadlift,1,3,120,""
"""

    @Test("サンプルCSVを正しくパースできる")
    func parseSampleCSV() throws {
        let rows = try CSVImporter.parse(csvString: sampleCSV)
        #expect(rows.count == 4)
    }

    @Test("日付でグループすると2セッション")
    func groupByDate() throws {
        let rows = try CSVImporter.parse(csvString: sampleCSV)
        let grouped = Dictionary(grouping: rows, by: \.date)
        #expect(grouped.count == 2)
    }

    @Test("空ファイルは emptyFile エラー")
    func emptyFileThrows() {
        #expect(throws: CSVImporter.ImportError.emptyFile) {
            try CSVImporter.parse(csvString: "")
        }
    }

    @Test("不正ヘッダーは invalidHeader エラー")
    func invalidHeaderThrows() {
        #expect(throws: CSVImporter.ImportError.invalidHeader) {
            try CSVImporter.parse(csvString: "foo,bar,baz\n1,2,3")
        }
    }

    @Test("クォート内のカンマを正しく処理")
    func quotedCommaHandling() {
        let line = "2024-01-15,\"Press, Bench\",1,10,80,\"\""
        let fields = CSVImporter.parseCSVLine(line)
        #expect(fields[1] == "Press, Bench")
    }

    @Test("JSONラウンドトリップ")
    func jsonRoundTrip() throws {
        let session = WorkoutSession(startedAt: .now)
        session.totalSets = 5
        session.completedSets = 5
        let data = try HistoryExporter.exportJSON(sessions: [session])
        let parsed = try JSONImporter.parse(jsonData: data)
        #expect(parsed.count == 1)
        #expect(parsed[0].totalSets == 5)
    }
}
