import Foundation
import CoreLocation

struct Station: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameKana: String?
    let lineName: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
