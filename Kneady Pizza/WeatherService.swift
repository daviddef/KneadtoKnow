import Foundation
import CoreLocation

/// Fetches the current room/outdoor temperature for a coordinate using the
/// free Open-Meteo API (no API key required).
enum WeatherService {
    struct Response: Decodable {
        struct Current: Decodable { let temperature_2m: Double }
        let current: Current
    }

    static func currentTemperature(at coordinate: CLLocationCoordinate2D) async throws -> Double {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            .init(name: "latitude", value: String(coordinate.latitude)),
            .init(name: "longitude", value: String(coordinate.longitude)),
            .init(name: "current", value: "temperature_2m"),
        ]
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.current.temperature_2m
    }
}
