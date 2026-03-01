import Foundation
import AppKit

struct City: Identifiable {
    let id = UUID()
    let name: String
    let timeZone: TimeZone

    var currentTime: Date {
        Date()
    }

    func formattedTime(use12Hour: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        // Force the format string to be interpreted literally, ignoring system locale preferences
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use12Hour ? "h:mm a" : "HH:mm"
        return formatter.string(from: currentTime)
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
        let cityData: [(String, String)] = [
            ("Honolulu", "Pacific/Honolulu"),
            ("San Francisco", "America/Los_Angeles"),
            ("Austin", "America/Chicago"),
            ("Madison", "America/Chicago"),
            ("Mexico City", "America/Mexico_City"),
            ("Montréal", "America/Toronto"),
            ("São Paulo", "America/Sao_Paulo"),
            ("Dublin", "Europe/Dublin"),
            ("London", "Europe/London"),
            ("Lisbon", "Europe/Lisbon"),
            ("Paris", "Europe/Paris"),
            ("Amsterdam", "Europe/Amsterdam"),
            ("Berlin", "Europe/Berlin"),
            ("Copenhagen", "Europe/Copenhagen"),
            ("Milan", "Europe/Rome"),
            ("Kraków", "Europe/Warsaw"),
            ("Tallinn", "Europe/Tallinn"),
            ("Novi Sad", "Europe/Belgrade"),
            ("Bengaluru", "Asia/Kolkata"),
            ("Pune", "Asia/Kolkata"),
            ("Singapore", "Asia/Singapore"),
            ("Seoul", "Asia/Seoul"),
            ("Tokyo", "Asia/Tokyo"),
            ("Taguig", "Asia/Manila"),
            ("Melbourne", "Australia/Melbourne")
        ]

        let cities = cityData.compactMap { name, identifier -> City? in
            guard let timeZone = TimeZone(identifier: identifier) else { return nil }
            return City(name: name, timeZone: timeZone)
        }

        return cities.sorted { city1, city2 in
            let offset1 = city1.timeZone.secondsFromGMT(for: Date())
            let offset2 = city2.timeZone.secondsFromGMT(for: Date())
            return offset1 < offset2
        }
    }()
}
