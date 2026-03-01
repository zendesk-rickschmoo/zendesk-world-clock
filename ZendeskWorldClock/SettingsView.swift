import SwiftUI
import CoreLocation

struct SettingsView: View {
    @AppStorage("use12HourFormat") private var use12HourFormat = false
    @Binding var hiddenCities: Set<String>
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var locationManager = LocationManager.shared

    @State private var citySearchText = ""
    @State private var isGeocoding = false
    @State private var manualLat = ""
    @State private var manualLon = ""

    private var hiddenCitiesSorted: [String] {
        hiddenCities.sorted()
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.headline)

            Toggle("Use 12-hour format", isOn: $use12HourFormat)

            Divider()

            locationSection

            Divider()

            hiddenCitiesSection

            Spacer()

            Button("Done") {
                dismiss()
            }
        }
        .padding()
        .frame(width: 320, height: 420)
        .onAppear {
            manualLat = locationManager.manualLatitude
            manualLon = locationManager.manualLongitude
            citySearchText = locationManager.manualCityName
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Location")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Picker("", selection: Binding(
                get: { locationManager.locationMode },
                set: { locationManager.locationMode = $0 }
            )) {
                ForEach(LocationMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if locationManager.locationMode == .automatic {
                automaticLocationView
            } else {
                manualLocationView
            }

            if let error = locationManager.locationError {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
            }
        }
    }

    private var automaticLocationView: some View {
        Group {
            if let location = locationManager.currentLocation {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text(String(format: "%.2f, %.2f", location.coordinate.latitude, location.coordinate.longitude))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Refresh") {
                        locationManager.requestLocation()
                    }
                    .font(.system(size: 11))
                }
            } else if locationManager.authorizationStatus == .notDetermined {
                Button("Enable Location Services") {
                    locationManager.requestLocation()
                }
                .font(.system(size: 12))
            } else {
                HStack {
                    Image(systemName: "location.slash")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                    Text("Location unavailable")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Retry") {
                        locationManager.requestLocation()
                    }
                    .font(.system(size: 11))
                }
            }
        }
    }

    private var manualLocationView: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("City name", text: $citySearchText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))

                Button(action: lookupCity) {
                    if isGeocoding {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 50)
                    } else {
                        Text("Lookup")
                    }
                }
                .disabled(citySearchText.isEmpty || isGeocoding)
                .font(.system(size: 11))
                .frame(width: 55)
            }

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("Lat:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    TextField("", text: $manualLat)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                        .frame(width: 70)
                        .onChange(of: manualLat) { _, newValue in
                            locationManager.manualLatitude = newValue
                        }
                }

                HStack(spacing: 4) {
                    Text("Lon:")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    TextField("", text: $manualLon)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                        .frame(width: 70)
                        .onChange(of: manualLon) { _, newValue in
                            locationManager.manualLongitude = newValue
                        }
                }
            }

            if locationManager.currentLocation != nil && locationManager.locationMode == .manual {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("Location set")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }

    private var hiddenCitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hidden Cities")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if hiddenCitiesSorted.isEmpty {
                Text("No hidden cities")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(hiddenCitiesSorted, id: \.self) { cityName in
                            HStack {
                                Text(cityName)
                                    .font(.system(size: 13))

                                Spacer()

                                Button(action: {
                                    hiddenCities.remove(cityName)
                                    saveHiddenCities()
                                }) {
                                    Image(systemName: "eye")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .help("Show \(cityName)")
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(maxHeight: 80)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func lookupCity() {
        isGeocoding = true
        locationManager.geocodeCity(citySearchText) { success in
            isGeocoding = false
            if success {
                manualLat = locationManager.manualLatitude
                manualLon = locationManager.manualLongitude
            }
        }
    }

    private func saveHiddenCities() {
        if let data = try? JSONEncoder().encode(hiddenCities) {
            UserDefaults.standard.set(data, forKey: "hiddenCities")
        }
    }
}

#Preview {
    SettingsView(hiddenCities: .constant([]))
}
