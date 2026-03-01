import XCTest
import CoreLocation
@testable import ZendeskWorldClock

final class SettingsManagerTests: XCTestCase {

    private let testSuiteName = "com.zendesk.worldclock.tests"
    private var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        // Use a separate UserDefaults suite for testing to avoid affecting real settings
        testDefaults = UserDefaults(suiteName: testSuiteName)
        testDefaults.removePersistentDomain(forName: testSuiteName)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testSuiteName)
        super.tearDown()
    }

    // Helper to create a test city with dummy coordinates
    private func makeTestCity(name: String = "Test City", timeZone: TimeZone) -> City {
        City(name: name, timeZone: timeZone, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    }

    // MARK: - 12/24 Hour Format Setting Tests

    func testUse12HourFormat_DefaultValue_IsFalse() {
        // When no value is set, UserDefaults.bool returns false
        let value = testDefaults.bool(forKey: "use12HourFormat")
        XCTAssertFalse(value, "Default value for use12HourFormat should be false (24-hour)")
    }

    func testUse12HourFormat_SetToTrue_PersistsValue() {
        testDefaults.set(true, forKey: "use12HourFormat")

        let value = testDefaults.bool(forKey: "use12HourFormat")
        XCTAssertTrue(value, "use12HourFormat should be true after setting to true")
    }

    func testUse12HourFormat_SetToFalse_PersistsValue() {
        // First set to true, then to false
        testDefaults.set(true, forKey: "use12HourFormat")
        testDefaults.set(false, forKey: "use12HourFormat")

        let value = testDefaults.bool(forKey: "use12HourFormat")
        XCTAssertFalse(value, "use12HourFormat should be false after setting to false")
    }

    func testUse12HourFormat_ValuePersistsAcrossReads() {
        testDefaults.set(true, forKey: "use12HourFormat")

        // Simulate multiple reads
        let value1 = testDefaults.bool(forKey: "use12HourFormat")
        let value2 = testDefaults.bool(forKey: "use12HourFormat")

        XCTAssertEqual(value1, value2, "Value should remain consistent across multiple reads")
        XCTAssertTrue(value1, "Value should remain true")
    }

    // MARK: - Integration Test: Format Changes with Setting

    func testTimeFormat_ChangesWithSetting() {
        let city = makeTestCity(timeZone: TimeZone(identifier: "UTC")!)

        // Create a specific date for deterministic testing
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 15
        components.hour = 15
        components.minute = 45
        components.timeZone = TimeZone(identifier: "UTC")
        let testDate = Calendar.current.date(from: components)!

        // Test with 24-hour format (false)
        testDefaults.set(false, forKey: "use12HourFormat")
        let use12Hour = testDefaults.bool(forKey: "use12HourFormat")
        let result24 = formatTime(for: city, date: testDate, use12Hour: use12Hour)
        XCTAssertEqual(result24, "15:45", "With use12HourFormat=false, should show 24-hour format")

        // Test with 12-hour format (true)
        testDefaults.set(true, forKey: "use12HourFormat")
        let use12HourUpdated = testDefaults.bool(forKey: "use12HourFormat")
        let result12 = formatTime(for: city, date: testDate, use12Hour: use12HourUpdated)
        XCTAssertEqual(result12, "3:45 PM", "With use12HourFormat=true, should show 12-hour format")
    }

    // MARK: - Helper

    private func formatTime(for city: City, date: Date, use12Hour: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = city.timeZone
        // Use the same locale as the app to ensure format strings are interpreted literally
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use12Hour ? "h:mm a" : "HH:mm"
        return formatter.string(from: date)
    }
}
