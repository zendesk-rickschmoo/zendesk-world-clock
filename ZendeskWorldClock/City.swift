import Foundation
import AppKit
import CoreLocation

struct Airport {
    let code: String
    let name: String
    let coordinate: CLLocationCoordinate2D

    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func distance(from location: CLLocation) -> CLLocationDistance {
        location.distance(from: self.location)
    }

    // Major international airports for origin lookup
    static let majorAirports: [Airport] = [
        // North America
        Airport(code: "JFK", name: "New York JFK", coordinate: CLLocationCoordinate2D(latitude: 40.6413, longitude: -73.7781)),
        Airport(code: "LAX", name: "Los Angeles", coordinate: CLLocationCoordinate2D(latitude: 33.9425, longitude: -118.4081)),
        Airport(code: "ORD", name: "Chicago O'Hare", coordinate: CLLocationCoordinate2D(latitude: 41.9742, longitude: -87.9073)),
        Airport(code: "SFO", name: "San Francisco", coordinate: CLLocationCoordinate2D(latitude: 37.6213, longitude: -122.3790)),
        Airport(code: "DFW", name: "Dallas", coordinate: CLLocationCoordinate2D(latitude: 32.8998, longitude: -97.0403)),
        Airport(code: "MIA", name: "Miami", coordinate: CLLocationCoordinate2D(latitude: 25.7959, longitude: -80.2870)),
        Airport(code: "SEA", name: "Seattle", coordinate: CLLocationCoordinate2D(latitude: 47.4502, longitude: -122.3088)),
        Airport(code: "BOS", name: "Boston", coordinate: CLLocationCoordinate2D(latitude: 42.3656, longitude: -71.0096)),
        Airport(code: "ATL", name: "Atlanta", coordinate: CLLocationCoordinate2D(latitude: 33.6407, longitude: -84.4277)),
        Airport(code: "DEN", name: "Denver", coordinate: CLLocationCoordinate2D(latitude: 39.8561, longitude: -104.6737)),
        Airport(code: "YYZ", name: "Toronto", coordinate: CLLocationCoordinate2D(latitude: 43.6777, longitude: -79.6248)),
        Airport(code: "YUL", name: "Montreal", coordinate: CLLocationCoordinate2D(latitude: 45.4706, longitude: -73.7408)),
        Airport(code: "YVR", name: "Vancouver", coordinate: CLLocationCoordinate2D(latitude: 49.1947, longitude: -123.1792)),
        Airport(code: "MEX", name: "Mexico City", coordinate: CLLocationCoordinate2D(latitude: 19.4363, longitude: -99.0721)),
        Airport(code: "HNL", name: "Honolulu", coordinate: CLLocationCoordinate2D(latitude: 21.3245, longitude: -157.9251)),

        // Europe
        Airport(code: "LHR", name: "London Heathrow", coordinate: CLLocationCoordinate2D(latitude: 51.4700, longitude: -0.4543)),
        Airport(code: "LGW", name: "London Gatwick", coordinate: CLLocationCoordinate2D(latitude: 51.1537, longitude: -0.1821)),
        Airport(code: "CDG", name: "Paris CDG", coordinate: CLLocationCoordinate2D(latitude: 49.0097, longitude: 2.5479)),
        Airport(code: "AMS", name: "Amsterdam", coordinate: CLLocationCoordinate2D(latitude: 52.3105, longitude: 4.7683)),
        Airport(code: "FRA", name: "Frankfurt", coordinate: CLLocationCoordinate2D(latitude: 50.0379, longitude: 8.5622)),
        Airport(code: "MUC", name: "Munich", coordinate: CLLocationCoordinate2D(latitude: 48.3537, longitude: 11.7750)),
        Airport(code: "BCN", name: "Barcelona", coordinate: CLLocationCoordinate2D(latitude: 41.2974, longitude: 2.0833)),
        Airport(code: "MAD", name: "Madrid", coordinate: CLLocationCoordinate2D(latitude: 40.4983, longitude: -3.5676)),
        Airport(code: "FCO", name: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.8003, longitude: 12.2389)),
        Airport(code: "MXP", name: "Milan Malpensa", coordinate: CLLocationCoordinate2D(latitude: 45.6306, longitude: 8.7281)),
        Airport(code: "DUB", name: "Dublin", coordinate: CLLocationCoordinate2D(latitude: 53.4264, longitude: -6.2499)),
        Airport(code: "ZRH", name: "Zurich", coordinate: CLLocationCoordinate2D(latitude: 47.4647, longitude: 8.5492)),
        Airport(code: "VIE", name: "Vienna", coordinate: CLLocationCoordinate2D(latitude: 48.1103, longitude: 16.5697)),
        Airport(code: "CPH", name: "Copenhagen", coordinate: CLLocationCoordinate2D(latitude: 55.6180, longitude: 12.6508)),
        Airport(code: "ARN", name: "Stockholm", coordinate: CLLocationCoordinate2D(latitude: 59.6498, longitude: 17.9238)),
        Airport(code: "OSL", name: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 60.1976, longitude: 11.1004)),
        Airport(code: "HEL", name: "Helsinki", coordinate: CLLocationCoordinate2D(latitude: 60.3172, longitude: 24.9633)),
        Airport(code: "LIS", name: "Lisbon", coordinate: CLLocationCoordinate2D(latitude: 38.7742, longitude: -9.1342)),
        Airport(code: "BER", name: "Berlin", coordinate: CLLocationCoordinate2D(latitude: 52.3667, longitude: 13.5033)),
        Airport(code: "WAW", name: "Warsaw", coordinate: CLLocationCoordinate2D(latitude: 52.1657, longitude: 20.9671)),
        Airport(code: "PRG", name: "Prague", coordinate: CLLocationCoordinate2D(latitude: 50.1008, longitude: 14.2632)),
        Airport(code: "BUD", name: "Budapest", coordinate: CLLocationCoordinate2D(latitude: 47.4369, longitude: 19.2556)),
        Airport(code: "TLL", name: "Tallinn", coordinate: CLLocationCoordinate2D(latitude: 59.4133, longitude: 24.8328)),
        Airport(code: "BEG", name: "Belgrade", coordinate: CLLocationCoordinate2D(latitude: 44.8184, longitude: 20.3091)),
        Airport(code: "KRK", name: "Krakow", coordinate: CLLocationCoordinate2D(latitude: 50.0777, longitude: 19.7848)),
        Airport(code: "MAN", name: "Manchester", coordinate: CLLocationCoordinate2D(latitude: 53.3537, longitude: -2.2750)),
        Airport(code: "EDI", name: "Edinburgh", coordinate: CLLocationCoordinate2D(latitude: 55.9508, longitude: -3.3615)),
        Airport(code: "BHX", name: "Birmingham", coordinate: CLLocationCoordinate2D(latitude: 52.4539, longitude: -1.7480)),
        Airport(code: "BRS", name: "Bristol", coordinate: CLLocationCoordinate2D(latitude: 51.3827, longitude: -2.7190)),

        // Asia
        Airport(code: "NRT", name: "Tokyo Narita", coordinate: CLLocationCoordinate2D(latitude: 35.7720, longitude: 140.3929)),
        Airport(code: "HND", name: "Tokyo Haneda", coordinate: CLLocationCoordinate2D(latitude: 35.5494, longitude: 139.7798)),
        Airport(code: "ICN", name: "Seoul Incheon", coordinate: CLLocationCoordinate2D(latitude: 37.4602, longitude: 126.4407)),
        Airport(code: "PEK", name: "Beijing", coordinate: CLLocationCoordinate2D(latitude: 40.0799, longitude: 116.6031)),
        Airport(code: "PVG", name: "Shanghai", coordinate: CLLocationCoordinate2D(latitude: 31.1443, longitude: 121.8083)),
        Airport(code: "HKG", name: "Hong Kong", coordinate: CLLocationCoordinate2D(latitude: 22.3080, longitude: 113.9185)),
        Airport(code: "SIN", name: "Singapore", coordinate: CLLocationCoordinate2D(latitude: 1.3644, longitude: 103.9915)),
        Airport(code: "BKK", name: "Bangkok", coordinate: CLLocationCoordinate2D(latitude: 13.6900, longitude: 100.7501)),
        Airport(code: "KUL", name: "Kuala Lumpur", coordinate: CLLocationCoordinate2D(latitude: 2.7456, longitude: 101.7072)),
        Airport(code: "DEL", name: "Delhi", coordinate: CLLocationCoordinate2D(latitude: 28.5562, longitude: 77.1000)),
        Airport(code: "BOM", name: "Mumbai", coordinate: CLLocationCoordinate2D(latitude: 19.0896, longitude: 72.8656)),
        Airport(code: "BLR", name: "Bengaluru", coordinate: CLLocationCoordinate2D(latitude: 13.1986, longitude: 77.7066)),
        Airport(code: "MNL", name: "Manila", coordinate: CLLocationCoordinate2D(latitude: 14.5086, longitude: 121.0194)),
        Airport(code: "CGK", name: "Jakarta", coordinate: CLLocationCoordinate2D(latitude: -6.1256, longitude: 106.6559)),

        // Oceania
        Airport(code: "SYD", name: "Sydney", coordinate: CLLocationCoordinate2D(latitude: -33.9399, longitude: 151.1753)),
        Airport(code: "MEL", name: "Melbourne", coordinate: CLLocationCoordinate2D(latitude: -37.6690, longitude: 144.8410)),
        Airport(code: "AKL", name: "Auckland", coordinate: CLLocationCoordinate2D(latitude: -37.0082, longitude: 174.7850)),
        Airport(code: "BNE", name: "Brisbane", coordinate: CLLocationCoordinate2D(latitude: -27.3942, longitude: 153.1218)),
        Airport(code: "PER", name: "Perth", coordinate: CLLocationCoordinate2D(latitude: -31.9385, longitude: 115.9672)),

        // South America
        Airport(code: "GRU", name: "São Paulo", coordinate: CLLocationCoordinate2D(latitude: -23.4356, longitude: -46.4731)),
        Airport(code: "EZE", name: "Buenos Aires", coordinate: CLLocationCoordinate2D(latitude: -34.8222, longitude: -58.5358)),
        Airport(code: "SCL", name: "Santiago", coordinate: CLLocationCoordinate2D(latitude: -33.3930, longitude: -70.7858)),
        Airport(code: "BOG", name: "Bogota", coordinate: CLLocationCoordinate2D(latitude: 4.7016, longitude: -74.1469)),
        Airport(code: "LIM", name: "Lima", coordinate: CLLocationCoordinate2D(latitude: -12.0219, longitude: -77.1143)),

        // Middle East & Africa
        Airport(code: "DXB", name: "Dubai", coordinate: CLLocationCoordinate2D(latitude: 25.2532, longitude: 55.3657)),
        Airport(code: "DOH", name: "Doha", coordinate: CLLocationCoordinate2D(latitude: 25.2609, longitude: 51.6138)),
        Airport(code: "AUH", name: "Abu Dhabi", coordinate: CLLocationCoordinate2D(latitude: 24.4330, longitude: 54.6511)),
        Airport(code: "TLV", name: "Tel Aviv", coordinate: CLLocationCoordinate2D(latitude: 32.0055, longitude: 34.8854)),
        Airport(code: "JNB", name: "Johannesburg", coordinate: CLLocationCoordinate2D(latitude: -26.1367, longitude: 28.2411)),
        Airport(code: "CPT", name: "Cape Town", coordinate: CLLocationCoordinate2D(latitude: -33.9715, longitude: 18.6021)),
        Airport(code: "CAI", name: "Cairo", coordinate: CLLocationCoordinate2D(latitude: 30.1219, longitude: 31.4056)),
        Airport(code: "IST", name: "Istanbul", coordinate: CLLocationCoordinate2D(latitude: 41.2753, longitude: 28.7519)),
    ]

    static func nearest(to location: CLLocation) -> Airport? {
        majorAirports.min { $0.distance(from: location) < $1.distance(from: location) }
    }
}

struct City: Identifiable {
    let id = UUID()
    let name: String
    let timeZone: TimeZone
    let coordinate: CLLocationCoordinate2D
    let airportCode: String

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

    var googleMapsURL: URL? {
        let urlString = "https://www.google.com/maps/search/?api=1&query=\(coordinate.latitude),\(coordinate.longitude)"
        return URL(string: urlString)
    }

    func flightsURL(from userLocation: CLLocation?) -> URL? {
        guard let userLocation = userLocation,
              let originAirport = Airport.nearest(to: userLocation) else {
            return nil
        }

        let dateString = City.nextBusinessDayForURL()

        // Use Skyscanner with airport codes
        // Format: https://www.skyscanner.com/transport/flights/[from]/[to]/[yymmdd]/
        let urlString = "https://www.skyscanner.com/transport/flights/\(originAirport.code.lowercased())/\(airportCode.lowercased())/\(dateString)/"

        return URL(string: urlString)
    }

    static func nextBusinessDay() -> Date {
        let calendar = Calendar.current
        var date = Date()

        // Move to tomorrow first
        date = calendar.date(byAdding: .day, value: 1, to: date) ?? date

        // Skip weekends
        while true {
            let weekday = calendar.component(.weekday, from: date)
            // 1 = Sunday, 7 = Saturday
            if weekday != 1 && weekday != 7 {
                break
            }
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }

        return date
    }

    static func nextBusinessDayForURL() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: nextBusinessDay())
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
        // City data: (name, timezone, latitude, longitude, airportCode)
        // Coordinates are for actual Zendesk office locations where known
        let cityData: [(String, String, Double, Double, String)] = [
            // 1132 Bishop St, Honolulu, HI 96813
            ("Honolulu", "Pacific/Honolulu", 21.3073, -157.8631, "HNL"),
            // 181 Fremont St, San Francisco, CA 94105 (HQ)
            ("San Francisco", "America/Los_Angeles", 37.7901, -122.3972, "SFO"),
            // 600 Congress Ave, Austin, TX 78701
            ("Austin", "America/Chicago", 30.2686, -97.7436, "AUS"),
            // 1 S Pinckney St, Madison, WI 53703
            ("Madison", "America/Chicago", 43.0747, -89.3841, "MSN"),
            // Av. Paseo de la Reforma 250, Mexico City
            ("Mexico City", "America/Mexico_City", 19.4270, -99.1677, "MEX"),
            // 1751 Rue Richardson, Montréal, QC H3K 1G6
            ("Montréal", "America/Toronto", 45.4882, -73.5534, "YUL"),
            // Rua Funchal 418, São Paulo
            ("São Paulo", "America/Sao_Paulo", -23.5868, -46.6850, "GRU"),
            // 55 Charlemont Place, Dublin 2, D02 F985
            ("Dublin", "Europe/Dublin", 53.3318, -6.2591, "DUB"),
            // 45 Mortimer Street, London W1W 8HJ
            ("London", "Europe/London", 51.5180, -0.1407, "LHR"),
            // Praça Duque de Saldanha 1, Lisbon
            ("Lisbon", "Europe/Lisbon", 38.7350, -9.1452, "LIS"),
            // 40 Rue du Louvre, 75001 Paris
            ("Paris", "Europe/Paris", 48.8626, 2.3410, "CDG"),
            // Wibautstraat 131, 1091 GL Amsterdam
            ("Amsterdam", "Europe/Amsterdam", 52.3518, 4.9073, "AMS"),
            // Rheinsberger Str. 73, 10115 Berlin
            ("Berlin", "Europe/Berlin", 52.5359, 13.3989, "BER"),
            // Snaregade 12, 1205 København K
            ("Copenhagen", "Europe/Copenhagen", 55.6773, 12.5742, "CPH"),
            // Via Orefici 2, 20123 Milano
            ("Milan", "Europe/Rome", 45.4639, 9.1877, "MXP"),
            // Rynek Główny 6, 31-042 Kraków
            ("Kraków", "Europe/Warsaw", 50.0619, 19.9372, "KRK"),
            // Tornimäe 2, 10145 Tallinn
            ("Tallinn", "Europe/Tallinn", 59.4340, 24.7536, "TLL"),
            // Bulevar oslobođenja 127, Novi Sad
            ("Novi Sad", "Europe/Belgrade", 45.2461, 19.8494, "BEG"),
            // Embassy Golf Links, Bengaluru, Karnataka 560071
            ("Bengaluru", "Asia/Kolkata", 12.9611, 77.6472, "BLR"),
            // Panchshil Tech Park, Shivajinagar, Pune
            ("Pune", "Asia/Kolkata", 18.5380, 73.8353, "PNQ"),
            // 1 Raffles Place, Singapore 048616
            ("Singapore", "Asia/Singapore", 1.2840, 103.8510, "SIN"),
            // 507 Gangnam-daero, Seocho-gu, Seoul
            ("Seoul", "Asia/Seoul", 37.4979, 127.0276, "ICN"),
            // Shibuya Scramble Square, 2-24-12 Shibuya, Tokyo
            ("Tokyo", "Asia/Tokyo", 35.6580, 139.7016, "NRT"),
            // BGC Corporate Center, 30th Street, Taguig
            ("Taguig", "Asia/Manila", 14.5507, 121.0455, "MNL"),
            // 67 Queen St, Melbourne VIC 3000
            ("Melbourne", "Australia/Melbourne", -37.8170, 144.9600, "MEL")
        ]

        let cities = cityData.compactMap { name, identifier, lat, lon, airport -> City? in
            guard let timeZone = TimeZone(identifier: identifier) else { return nil }
            return City(
                name: name,
                timeZone: timeZone,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                airportCode: airport
            )
        }

        return cities.sorted { city1, city2 in
            let offset1 = city1.timeZone.secondsFromGMT(for: Date())
            let offset2 = city2.timeZone.secondsFromGMT(for: Date())
            return offset1 < offset2
        }
    }()
}
