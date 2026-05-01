import Foundation

/// exercises_seed.json をバンドルから読み込む軽量ローダー。
enum ExerciseSeedLoader {
    static func load(from bundle: Bundle = .main) throws -> [Exercise] {
        guard let url = bundle.url(forResource: "exercises_seed", withExtension: "json") else {
            throw AppError.dataCorruption
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([Exercise].self, from: data)
    }
}
