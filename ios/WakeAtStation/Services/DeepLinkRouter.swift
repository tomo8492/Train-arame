import Foundation
import CoreLocation
import Combine

@MainActor
final class DeepLinkRouter: ObservableObject {
    @Published var pendingStation: Station?

    /// 受け付けるURL形式:
    ///   wakestation://goto?name=新宿
    ///   wakestation://goto?lat=35.6809&lng=139.7673
    ///   wakestation://goto?lat=35.6809&lng=139.7673&name=東京
    /// name一致 → 座標最近傍 の順で解決する。
    func handle(url: URL, repository: StationRepository) {
        guard url.scheme == "wakestation", url.host == "goto",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        let items = components.queryItems ?? []

        if let name = items.first(where: { $0.name == "name" })?.value,
           !name.isEmpty {
            let hits = repository.search(name, limit: 1)
            if let first = hits.first {
                pendingStation = first
                return
            }
        }

        if let latStr = items.first(where: { $0.name == "lat" })?.value,
           let lngStr = items.first(where: { $0.name == "lng" })?.value,
           let lat = Double(latStr), let lng = Double(lngStr) {
            let target = CLLocation(latitude: lat, longitude: lng)
            let nearest = repository.all.min { a, b in
                let la = CLLocation(latitude: a.latitude, longitude: a.longitude)
                let lb = CLLocation(latitude: b.latitude, longitude: b.longitude)
                return la.distance(from: target) < lb.distance(from: target)
            }
            pendingStation = nearest
        }
    }

    func consume() -> Station? {
        let s = pendingStation
        pendingStation = nil
        return s
    }
}
