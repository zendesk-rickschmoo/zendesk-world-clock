import Foundation
import CoreLocation
import Combine

enum LocationMode: String, CaseIterable {
    case automatic = "automatic"
    case manual = "manual"

    var displayName: String {
        switch self {
        case .automatic: return "Use Current Location"
        case .manual: return "Enter Manually"
        }
    }
}

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?

    var locationMode: LocationMode {
        get {
            let rawValue = UserDefaults.standard.string(forKey: "locationMode") ?? LocationMode.automatic.rawValue
            return LocationMode(rawValue: rawValue) ?? .automatic
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "locationMode")
            objectWillChange.send()
            if newValue == .automatic {
                requestLocation()
            } else {
                loadManualLocation()
            }
        }
    }

    var manualLatitude: String {
        get { UserDefaults.standard.string(forKey: "manualLatitude") ?? "" }
        set {
            UserDefaults.standard.set(newValue, forKey: "manualLatitude")
            if locationMode == .manual {
                loadManualLocation()
            }
        }
    }

    var manualLongitude: String {
        get { UserDefaults.standard.string(forKey: "manualLongitude") ?? "" }
        set {
            UserDefaults.standard.set(newValue, forKey: "manualLongitude")
            if locationMode == .manual {
                loadManualLocation()
            }
        }
    }

    var manualCityName: String {
        get { UserDefaults.standard.string(forKey: "manualCityName") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "manualCityName") }
    }

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

        authorizationStatus = locationManager.authorizationStatus

        if locationMode == .automatic {
            requestLocation()
        } else {
            loadManualLocation()
        }
    }

    func requestLocation() {
        locationError = nil

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Please enable in System Settings."
        @unknown default:
            locationError = "Unknown authorization status"
        }
    }

    func loadManualLocation() {
        guard let lat = Double(manualLatitude),
              let lon = Double(manualLongitude),
              lat >= -90 && lat <= 90,
              lon >= -180 && lon <= 180 else {
            if !manualLatitude.isEmpty || !manualLongitude.isEmpty {
                locationError = "Invalid coordinates"
            }
            currentLocation = nil
            return
        }

        locationError = nil
        currentLocation = CLLocation(latitude: lat, longitude: lon)
    }

    func geocodeCity(_ cityName: String, completion: @escaping (Bool) -> Void) {
        guard !cityName.isEmpty else {
            completion(false)
            return
        }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let location = placemarks?.first?.location {
                    self?.manualLatitude = String(format: "%.4f", location.coordinate.latitude)
                    self?.manualLongitude = String(format: "%.4f", location.coordinate.longitude)
                    self?.manualCityName = cityName
                    self?.locationError = nil
                    completion(true)
                } else {
                    self?.locationError = "Could not find location for '\(cityName)'"
                    completion(false)
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locationMode == .automatic else { return }
        if let location = locations.last {
            currentLocation = location
            locationError = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard locationMode == .automatic else { return }
        locationError = "Failed to get location: \(error.localizedDescription)"
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if locationMode == .automatic {
            switch authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            case .denied, .restricted:
                locationError = "Location access denied. Please enable in System Settings."
            default:
                break
            }
        }
    }
}
