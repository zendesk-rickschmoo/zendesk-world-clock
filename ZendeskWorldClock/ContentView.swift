import SwiftUI

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showingSettings = false
    @AppStorage("use12HourFormat") private var use12HourFormat = false
    @State private var hiddenCities: Set<String>
    @ObservedObject private var locationManager = LocationManager.shared

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
        if let data = UserDefaults.standard.data(forKey: "hiddenCities"),
           let cities = try? JSONDecoder().decode(Set<String>.self, from: data) {
            _hiddenCities = State(initialValue: cities)
        } else {
            _hiddenCities = State(initialValue: [])
        }
    }

    private var visibleCities: [City] {
        City.zendeskCities.filter { !hiddenCities.contains($0.name) }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(visibleCities) { city in
                        cityRow(for: city)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(width: 380, height: 400)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(hiddenCities: $hiddenCities)
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "globe")
                .font(.system(size: 16))
                .foregroundColor(.secondary)

            Text("Zendesk World Clock")
                .font(.headline)

            Spacer()

            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private func cityRow(for city: City) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(city.workHoursStatus.color))
                .frame(width: 8, height: 8)

            Text(city.name)
                .font(.system(size: 13))
                .frame(width: 100, alignment: .leading)

            Text("(\(city.timeZoneAbbreviation))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(width: 45, alignment: .leading)

            Spacer()

            Text(formatTime(for: city))
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.primary)
                .frame(width: 70, alignment: .trailing)

            Text(city.formattedDistance(from: locationManager.currentLocation))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(width: 55, alignment: .trailing)

            Button(action: {
                hideCity(city.name)
            }) {
                Image(systemName: "eye.slash")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Hide \(city.name)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    private func formatTime(for city: City) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = city.timeZone
        // Force the format string to be interpreted literally, ignoring system locale preferences
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use12HourFormat ? "h:mm a" : "HH:mm"
        return formatter.string(from: currentTime)
    }

    private func hideCity(_ name: String) {
        hiddenCities.insert(name)
        saveHiddenCities()
    }

    private func saveHiddenCities() {
        if let data = try? JSONEncoder().encode(hiddenCities) {
            UserDefaults.standard.set(data, forKey: "hiddenCities")
        }
    }
}

#Preview {
    ContentView()
}
