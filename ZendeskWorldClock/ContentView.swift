import SwiftUI
import AppKit

enum SortColumn: String, CaseIterable {
    case city = "city"
    case timezone = "timezone"
    case time = "time"
    case distance = "distance"
}

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showingSettings = false
    @AppStorage("use12HourFormat") private var use12HourFormat = false
    @AppStorage("sortColumn") private var sortColumn: String = SortColumn.timezone.rawValue
    @AppStorage("sortAscending") private var sortAscending = true
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

    private var currentSortColumn: SortColumn {
        SortColumn(rawValue: sortColumn) ?? .timezone
    }

    private var sortedCities: [City] {
        let filtered = City.zendeskCities.filter { !hiddenCities.contains($0.name) }

        let sorted: [City]
        switch currentSortColumn {
        case .city:
            sorted = filtered.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .timezone:
            sorted = filtered.sorted {
                $0.timeZone.secondsFromGMT(for: currentTime) < $1.timeZone.secondsFromGMT(for: currentTime)
            }
        case .time:
            sorted = filtered.sorted {
                let cal = Calendar.current
                let comp1 = cal.dateComponents(in: $0.timeZone, from: currentTime)
                let comp2 = cal.dateComponents(in: $1.timeZone, from: currentTime)
                let mins1 = (comp1.hour ?? 0) * 60 + (comp1.minute ?? 0)
                let mins2 = (comp2.hour ?? 0) * 60 + (comp2.minute ?? 0)
                return mins1 < mins2
            }
        case .distance:
            if let userLocation = locationManager.currentLocation {
                sorted = filtered.sorted {
                    $0.distance(from: userLocation) < $1.distance(from: userLocation)
                }
            } else {
                sorted = filtered
            }
        }

        return sortAscending ? sorted : sorted.reversed()
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            Divider()

            columnHeadersView

            Divider()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(sortedCities) { city in
                        cityRow(for: city)
                    }
                }
            }
            .frame(width: 380, height: 370)
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

    private var columnHeadersView: some View {
        HStack(spacing: 8) {
            // Spacer for status indicator
            Color.clear.frame(width: 8, height: 8)

            sortableHeader("City", column: .city, width: 100, alignment: .leading)

            sortableHeader("TZ", column: .timezone, width: 45, alignment: .leading)

            Text("Airport")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)

            Spacer()

            sortableHeader("Time", column: .time, width: 70, alignment: .trailing)

            sortableHeader("Dist", column: .distance, width: 55, alignment: .trailing)

            // Spacer for hide button
            Color.clear.frame(width: 20)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }

    private func sortableHeader(_ title: String, column: SortColumn, width: CGFloat, alignment: Alignment) -> some View {
        Button(action: {
            if currentSortColumn == column {
                sortAscending.toggle()
            } else {
                sortColumn = column.rawValue
                sortAscending = true
            }
        }) {
            HStack(spacing: 2) {
                if alignment == .trailing {
                    Spacer(minLength: 0)
                }

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)

                if currentSortColumn == column {
                    Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.accentColor)
                }

                if alignment == .leading {
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: width, alignment: alignment)
        .help("Sort by \(title.lowercased())")
    }

    private func cityRow(for city: City) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(city.workHoursStatus.color))
                .frame(width: 8, height: 8)

            Button(action: {
                openInMaps(city)
            }) {
                Text(city.name)
                    .font(.system(size: 13))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .help("Open \(city.name) in Google Maps")
            .frame(width: 100, alignment: .leading)

            Text("(\(city.timeZoneAbbreviation))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(width: 45, alignment: .leading)

            Button(action: {
                openAirportInMaps(city.airportCode)
            }) {
                Text(city.airportCode)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .help("Open \(city.airportCode) airport in Google Maps")
            .frame(width: 40, alignment: .leading)

            Spacer()

            Text(formatTime(for: city))
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.primary)
                .frame(width: 70, alignment: .trailing)

            Button(action: {
                openFlights(to: city)
            }) {
                Text(city.formattedDistance(from: locationManager.currentLocation))
                    .font(.system(size: 11))
                    .foregroundColor(locationManager.currentLocation != nil ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .disabled(locationManager.currentLocation == nil)
            .help(locationManager.currentLocation != nil ? "Search flights to \(city.name)" : "Set your location to search flights")
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

    private func openInMaps(_ city: City) {
        if let url = city.googleMapsURL {
            NSWorkspace.shared.open(url)
        }
    }

    private func openAirportInMaps(_ airportCode: String) {
        // Find the airport coordinates from our database
        if let airport = Airport.majorAirports.first(where: { $0.code == airportCode }) {
            // Use coordinates with satellite view (t=k) and zoom level 14
            let urlString = "https://www.google.com/maps?q=\(airport.coordinate.latitude),\(airport.coordinate.longitude)&t=k&z=14"
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        } else {
            // Fallback to search if airport not in database
            let urlString = "https://www.google.com/maps/search/\(airportCode)+airport"
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func openFlights(to city: City) {
        if let url = city.flightsURL(from: locationManager.currentLocation) {
            NSWorkspace.shared.open(url)
        }
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
