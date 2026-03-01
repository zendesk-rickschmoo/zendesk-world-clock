import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    var use12HourFormat: Bool {
        get { _use12HourFormat }
        set {
            _use12HourFormat = newValue
            UserDefaults.standard.set(newValue, forKey: "use12HourFormat")
            objectWillChange.send()
        }
    }
    private var _use12HourFormat: Bool

    var hiddenCities: Set<String> {
        get { _hiddenCities }
        set {
            _hiddenCities = newValue
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "hiddenCities")
            }
            objectWillChange.send()
        }
    }
    private var _hiddenCities: Set<String>

    private init() {
        _use12HourFormat = UserDefaults.standard.bool(forKey: "use12HourFormat")

        if let data = UserDefaults.standard.data(forKey: "hiddenCities"),
           let cities = try? JSONDecoder().decode(Set<String>.self, from: data) {
            _hiddenCities = cities
        } else {
            _hiddenCities = []
        }
    }
}
