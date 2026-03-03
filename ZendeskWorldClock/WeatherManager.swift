import Foundation
import CoreLocation

struct WeatherData: Codable {
    let temperature: Double
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature"
        case weatherCode = "weathercode"
    }

    var temperatureString: String {
        String(format: "%.0f°", temperature)
    }

    var conditionSymbol: String {
        // WMO Weather interpretation codes
        // https://open-meteo.com/en/docs
        switch weatherCode {
        case 0:
            return "☀️"  // Clear sky
        case 1, 2, 3:
            return "⛅"  // Partly cloudy
        case 45, 48:
            return "🌫️"  // Fog
        case 51, 53, 55, 56, 57:
            return "🌧️"  // Drizzle
        case 61, 63, 65, 66, 67:
            return "🌧️"  // Rain
        case 71, 73, 75, 77:
            return "❄️"  // Snow
        case 80, 81, 82:
            return "🌧️"  // Rain showers
        case 85, 86:
            return "❄️"  // Snow showers
        case 95, 96, 99:
            return "⛈️"  // Thunderstorm
        default:
            return "🌡️"
        }
    }
}

struct OpenMeteoResponse: Codable {
    let currentWeather: WeatherData

    enum CodingKeys: String, CodingKey {
        case currentWeather = "current_weather"
    }
}

@MainActor
class WeatherManager: ObservableObject {
    static let shared = WeatherManager()

    @Published var weatherData: [String: WeatherData] = [:]
    @Published var isLoading = false

    private var lastFetchTime: Date?
    private let cacheMinutes: TimeInterval = 15

    private init() {}

    func fetchWeatherForAllCities() {
        // Only fetch if cache is stale
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheMinutes * 60 {
            return
        }

        isLoading = true

        Task {
            for city in City.zendeskCities {
                await fetchWeather(for: city)
            }
            lastFetchTime = Date()
            isLoading = false
        }
    }

    func fetchWeather(for city: City) async {
        let lat = city.coordinate.latitude
        let lon = city.coordinate.longitude
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true"

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            weatherData[city.name] = response.currentWeather
        } catch {
            print("Weather fetch error for \(city.name): \(error)")
        }
    }

    func weather(for cityName: String) -> WeatherData? {
        weatherData[cityName]
    }
}
