import XCTest
import CoreLocation
@testable import ZendeskWorldClock

final class TimeFormatTests: XCTestCase {

    // Helper to create a test city with dummy coordinates
    private func makeTestCity(name: String = "Test City", timeZone: TimeZone) -> City {
        City(name: name, timeZone: timeZone, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), airportCode: "TST")
    }

    // MARK: - City.formattedTime Tests

    func testFormattedTime_12HourFormat_ShowsAMPM() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)
        let result = city.formattedTime(use12Hour: true)

        // 12-hour format should contain AM or PM
        XCTAssertTrue(
            result.contains("AM") || result.contains("PM"),
            "12-hour format should contain AM or PM, got: \(result)"
        )
    }

    func testFormattedTime_24HourFormat_NoAMPM() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)
        let result = city.formattedTime(use12Hour: false)

        // 24-hour format should NOT contain AM or PM
        XCTAssertFalse(
            result.contains("AM") || result.contains("PM"),
            "24-hour format should not contain AM or PM, got: \(result)"
        )
    }

    func testFormattedTime_12HourFormat_MatchesExpectedPattern() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)
        let result = city.formattedTime(use12Hour: true)

        // Pattern: h:mm AM/PM (e.g., "2:30 PM" or "12:05 AM")
        let pattern = #"^1?\d:\d{2} [AP]M$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(result.startIndex..., in: result)

        XCTAssertNotNil(
            regex.firstMatch(in: result, range: range),
            "12-hour format should match pattern 'h:mm AM/PM', got: \(result)"
        )
    }

    func testFormattedTime_24HourFormat_MatchesExpectedPattern() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)
        let result = city.formattedTime(use12Hour: false)

        // Pattern: HH:mm (e.g., "14:30" or "02:05")
        let pattern = #"^\d{2}:\d{2}$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(result.startIndex..., in: result)

        XCTAssertNotNil(
            regex.firstMatch(in: result, range: range),
            "24-hour format should match pattern 'HH:mm', got: \(result)"
        )
    }

    // MARK: - Format Consistency Tests with Known Times

    func testFormattedTime_AtSpecificTime_12HourFormat() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)

        // Create a specific date: 14:30 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.timeZone = TimeZone(identifier: "UTC")

        let specificDate = Calendar.current.date(from: components)!
        let result = formatTime(for: city, date: specificDate, use12Hour: true)

        XCTAssertEqual(result, "2:30 PM", "14:30 UTC should be 2:30 PM in 12-hour format")
    }

    func testFormattedTime_AtSpecificTime_24HourFormat() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)

        // Create a specific date: 14:30 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.timeZone = TimeZone(identifier: "UTC")

        let specificDate = Calendar.current.date(from: components)!
        let result = formatTime(for: city, date: specificDate, use12Hour: false)

        XCTAssertEqual(result, "14:30", "14:30 UTC should be 14:30 in 24-hour format")
    }

    func testFormattedTime_MidnightHour_12HourFormat() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)

        // Create a specific date: 00:15 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 0
        components.minute = 15
        components.timeZone = TimeZone(identifier: "UTC")

        let specificDate = Calendar.current.date(from: components)!
        let result = formatTime(for: city, date: specificDate, use12Hour: true)

        XCTAssertEqual(result, "12:15 AM", "00:15 UTC should be 12:15 AM in 12-hour format")
    }

    func testFormattedTime_MidnightHour_24HourFormat() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)

        // Create a specific date: 00:15 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 0
        components.minute = 15
        components.timeZone = TimeZone(identifier: "UTC")

        let specificDate = Calendar.current.date(from: components)!
        let result = formatTime(for: city, date: specificDate, use12Hour: false)

        XCTAssertEqual(result, "00:15", "00:15 UTC should be 00:15 in 24-hour format")
    }

    func testFormattedTime_NoonHour_12HourFormat() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)

        // Create a specific date: 12:00 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 12
        components.minute = 0
        components.timeZone = TimeZone(identifier: "UTC")

        let specificDate = Calendar.current.date(from: components)!
        let result = formatTime(for: city, date: specificDate, use12Hour: true)

        XCTAssertEqual(result, "12:00 PM", "12:00 UTC should be 12:00 PM in 12-hour format")
    }

    // MARK: - Timezone Conversion Tests

    func testFormattedTime_DifferentTimezone_12HourFormat() {
        // Tokyo is UTC+9
        let tokyoCity = makeTestCity(name: "Tokyo", timeZone: TimeZone(identifier: "Asia/Tokyo")!)

        // Create a specific date: 14:30 UTC = 23:30 Tokyo
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.timeZone = TimeZone(identifier: "UTC")

        let specificDate = Calendar.current.date(from: components)!
        let result = formatTime(for: tokyoCity, date: specificDate, use12Hour: true)

        XCTAssertEqual(result, "11:30 PM", "14:30 UTC should be 11:30 PM in Tokyo (12-hour)")
    }

    func testFormattedTime_DifferentTimezone_24HourFormat() {
        // Tokyo is UTC+9
        let tokyoCity = makeTestCity(name: "Tokyo", timeZone: TimeZone(identifier: "Asia/Tokyo")!)

        // Create a specific date: 14:30 UTC = 23:30 Tokyo
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.timeZone = TimeZone(identifier: "UTC")

        let specificDate = Calendar.current.date(from: components)!
        let result = formatTime(for: tokyoCity, date: specificDate, use12Hour: false)

        XCTAssertEqual(result, "23:30", "14:30 UTC should be 23:30 in Tokyo (24-hour)")
    }

    // MARK: - Helper Method

    /// Helper to format time for a specific date (mirrors the app's formatting logic)
    private func formatTime(for city: City, date: Date, use12Hour: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = city.timeZone
        // Use the same locale as the app to ensure format strings are interpreted literally
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use12Hour ? "h:mm a" : "HH:mm"
        return formatter.string(from: date)
    }
}
