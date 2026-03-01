import Foundation
import AppKit
import CoreLocation

struct City: Identifiable {
    let id = UUID()
    let name: String
    let timeZone: TimeZone
    let coordinate: CLLocationCoordinate2D

    var currentTime: Date {
        Date()
    }

    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func formattedTime(use12Hour: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        // Force the format string to be interpreted literally, ignoring system locale preferences
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use12Hour ? "h:mm a" : "HH:mm"
        return formatter.string(from: currentTime)
    }

    func distance(from userLocation: CLLocation) -> CLLocationDistance {
        userLocation.distance(from: location)
    }

    func formattedDistance(from userLocation: CLLocation?) -> String {
        guard let userLocation = userLocation else { return "—" }
        let distanceMeters = distance(from: userLocation)
        let distanceKm = distanceMeters / 1000

        if distanceKm < 100 {
            return String(format: "%.0f km", distanceKm)
        } else if distanceKm < 1000 {
            return String(format: "%.0f km", distanceKm)
        } else {
            return String(format: "%.1fk km", distanceKm / 1000)
        }
    }

    var timeZoneAbbreviation: String {
        timeZone.abbreviation(for: currentTime) ?? ""
    }

    var workHoursStatus: WorkHoursStatus {
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: timeZone, from: currentTime)
        guard let hour = components.hour else { return .outside }

        if hour >= 8 && hour < 18 {
            return .core
        } else if (hour == 7) || (hour == 18) {
            return .edge
        } else {
            return .outside
        }
    }

    enum WorkHoursStatus {
        case core
        case edge
        case outside

        var color: NSColor {
            switch self {
            case .core: return .systemGreen
            case .edge: return .systemOrange
            case .outside: return .systemRed
            }
        }
    }
}

extension City {
    static let zendeskCities: [City] = {
        // City data: (name, timezone, latitude, longitude)
        let cityData: [(String, String, Double, Double)] = [
            ("Honolulu", "Pacific/Honolulu", 21.3069, -157.8583),
            ("San Francisco", "America/Los_Angeles", 37.7749, -122.4194),
            ("Austin", "America/Chicago", 30.2672, -97.7431),
            ("Madison", "America/Chicago", 43.0731, -89.4012),
            ("Mexico City", "America/Mexico_City", 19.4326, -99.1332),
            ("Montréal", "America/Toronto", 45.5017, -73.5673),
            ("São Paulo", "America/Sao_Paulo", -23.5505, -46.6333),
            ("Dublin", "Europe/Dublin", 53.3498, -6.2603),
            ("London", "Europe/London", 51.5074, -0.1278),
            ("Lisbon", "Europe/Lisbon", 38.7223, -9.1393),
            ("Paris", "Europe/Paris", 48.8566, 2.3522),
            ("Amsterdam", "Europe/Amsterdam", 52.3676, 4.9041),
            ("Berlin", "Europe/Berlin", 52.5200, 13.4050),
            ("Copenhagen", "Europe/Copenhagen", 55.6761, 12.5683),
            ("Milan", "Europe/Rome", 45.4642, 9.1900),
            ("Kraków", "Europe/Warsaw", 50.0647, 19.9450),
            ("Tallinn", "Europe/Tallinn", 59.4370, 24.7536),
            ("Novi Sad", "Europe/Belgrade", 45.2671, 19.8335),
            ("Bengaluru", "Asia/Kolkata", 12.9716, 77.5946),
            ("Pune", "Asia/Kolkata", 18.5204, 73.8567),
            ("Singapore", "Asia/Singapore", 1.3521, 103.8198),
            ("Seoul", "Asia/Seoul", 37.5665, 126.9780),
            ("Tokyo", "Asia/Tokyo", 35.6762, 139.6503),
            ("Taguig", "Asia/Manila", 14.5176, 121.0509),
            ("Melbourne", "Australia/Melbourne", -37.8136, 144.9631)
        ]

        let cities = cityData.compactMap { name, identifier, lat, lon -> City? in
            guard let timeZone = TimeZone(identifier: identifier) else { return nil }
            return City(
                name: name,
                timeZone: timeZone,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
            )
        }

        return cities.sorted { city1, city2 in
            let offset1 = city1.timeZone.secondsFromGMT(for: Date())
            let offset2 = city2.timeZone.secondsFromGMT(for: Date())
            return offset1 < offset2
        }
    }()
}
