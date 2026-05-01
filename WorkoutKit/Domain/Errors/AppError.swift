import Foundation

enum AppError: LocalizedError {
    case generatorEmpty
    case dataCorruption
    case importFailed
    case mediaMissing
    case purchaseFailed
    case proRequired

    var errorDescription: String? {
        switch self {
        case .generatorEmpty:   return String(localized: "error.generator.empty")
        case .dataCorruption:   return String(localized: "error.data.corruption")
        case .importFailed:     return String(localized: "error.import.failed")
        case .mediaMissing:     return String(localized: "error.media.missing")
        case .purchaseFailed:   return String(localized: "error.purchase.failed")
        case .proRequired:      return String(localized: "error.pro.required")
        }
    }
}
