import SwiftUI
import AppKit
import CoreLocation

struct WorldMapView: View {
    let cities: [City]
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var locationManager = LocationManager.shared
    @State private var hoveredCity: String? = nil
    @State private var selectedOriginCity: City? = nil
    @State private var zoomScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var lastPanOffset: CGSize = .zero
    @State private var adjustedPositions: [String: CGPoint]? = nil

    // Map dimensions
    private let mapWidth: CGFloat = 700
    private let mapHeight: CGFloat = 400
    private let minZoom: CGFloat = 1.0
    private let maxZoom: CGFloat = 3.0
    private let minNodeDistance: CGFloat = 100

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "map")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text("Zendesk Office Locations")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close map")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Zoom controls
            HStack {
                Button(action: { zoomOut() }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .disabled(zoomScale <= minZoom)

                Text("\(Int(zoomScale * 100))%")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 40)

                Button(action: { zoomIn() }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .disabled(zoomScale >= maxZoom)

                Button(action: { resetZoom() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .help("Reset zoom")

                Spacer()

                Text("Scroll to zoom, drag to pan")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)

            // Map
            GeometryReader { geometry in
                ZStack {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.3))

                // World outline (simplified)
                WorldOutlineShape()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    .padding(20)

                // Grid lines
                GridLinesView()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 0.5)
                    .padding(20)

                // Connection lines from selected city or user location
                if let originCity = selectedOriginCity {
                    // Draw from selected city
                    let originPoint = getPosition(for: originCity)
                    ForEach(cities) { city in
                        if city.name != originCity.name {
                            let cityPoint = getPosition(for: city)

                            // Draw the line
                            Path { path in
                                path.move(to: originPoint)
                                path.addLine(to: cityPoint)
                            }
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)

                            // Distance label at midpoint
                            let midPoint = CGPoint(
                                x: (originPoint.x + cityPoint.x) / 2,
                                y: (originPoint.y + cityPoint.y) / 2
                            )
                            let distanceMiles = originCity.distanceTo(city) / 1609.34
                            Text(String(format: "%.0f mi", distanceMiles))
                                .font(.system(size: 8))
                                .foregroundColor(.orange.opacity(0.9))
                                .padding(.horizontal, 3)
                                .padding(.vertical, 1)
                                .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
                                .cornerRadius(2)
                                .position(midPoint)
                        }
                    }
                } else if let userLocation = locationManager.currentLocation {
                    // Draw from user location
                    ForEach(cities) { city in
                        let userPoint = coordinateToPoint(
                            lat: userLocation.coordinate.latitude,
                            lon: userLocation.coordinate.longitude
                        )
                        let cityPoint = getPosition(for: city)

                        // Draw the line
                        Path { path in
                            path.move(to: userPoint)
                            path.addLine(to: cityPoint)
                        }
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)

                        // Distance label at midpoint
                        let midPoint = CGPoint(
                            x: (userPoint.x + cityPoint.x) / 2,
                            y: (userPoint.y + cityPoint.y) / 2
                        )
                        let distanceMiles = city.distance(from: userLocation) / 1609.34
                        Text(String(format: "%.0f mi", distanceMiles))
                            .font(.system(size: 8))
                            .foregroundColor(.accentColor.opacity(0.8))
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
                            .cornerRadius(2)
                            .position(midPoint)
                    }
                }

                // User location marker
                if let userLocation = locationManager.currentLocation {
                    let point = coordinateToPoint(
                        lat: userLocation.coordinate.latitude,
                        lon: userLocation.coordinate.longitude
                    )

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                        .position(point)

                    Circle()
                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                        .frame(width: 18, height: 18)
                        .position(point)
                }

                // City markers
                ForEach(cities) { city in
                    let point = getPosition(for: city)
                    let isSelected = selectedOriginCity?.name == city.name

                    VStack(spacing: 2) {
                        ZStack {
                            if isSelected {
                                Circle()
                                    .stroke(Color.orange, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                            Circle()
                                .fill(isSelected ? Color.orange : Color(city.workHoursStatus.color))
                                .frame(width: 8, height: 8)
                        }

                        if hoveredCity == city.name {
                            VStack(spacing: 1) {
                                Text(city.name)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.primary)

                                if let originCity = selectedOriginCity, originCity.name != city.name {
                                    let distanceMiles = originCity.distanceTo(city) / 1609.34
                                    Text(String(format: "%.0f mi from %@", distanceMiles, originCity.name))
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                } else if let userLocation = locationManager.currentLocation {
                                    Text(city.formattedDistance(from: userLocation))
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }

                                Text("Click to show distances")
                                    .font(.system(size: 8))
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(NSColor.controlBackgroundColor).opacity(0.95))
                            .cornerRadius(4)
                            .shadow(radius: 2)
                        }
                    }
                    .position(point)
                    .onHover { isHovered in
                        hoveredCity = isHovered ? city.name : nil
                    }
                    .onTapGesture {
                        if selectedOriginCity?.name == city.name {
                            selectedOriginCity = nil  // Deselect if already selected
                        } else {
                            selectedOriginCity = city
                        }
                    }
                }

                // City labels (always visible, small)
                ForEach(cities) { city in
                    let point = getPosition(for: city)

                    if hoveredCity != city.name {
                        Text(city.name)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                            .position(x: point.x, y: point.y + 12)
                    }
                }
                }
                .scaleEffect(zoomScale)
                .offset(panOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let maxPan = (zoomScale - 1) * 200
                            let newWidth = lastPanOffset.width + value.translation.width
                            let newHeight = lastPanOffset.height + value.translation.height
                            panOffset = CGSize(
                                width: max(-maxPan, min(maxPan, newWidth)),
                                height: max(-maxPan, min(maxPan, newHeight))
                            )
                        }
                        .onEnded { _ in
                            lastPanOffset = panOffset
                        }
                )
                .onScrollWheel { delta in
                    // Use smaller multiplier to prevent rapid zoom
                    let zoomDelta = delta.y * 0.005
                    let newScale = max(minZoom, min(maxZoom, zoomScale + zoomDelta))
                    if newScale.isFinite {
                        zoomScale = newScale
                    }
                }
            }
            .frame(width: mapWidth, height: mapHeight)
            .clipped()
            .padding(16)

            Divider()

            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(NSColor.systemGreen))
                        .frame(width: 8, height: 8)
                    Text("Core hours (8am-6pm)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(NSColor.systemOrange))
                        .frame(width: 8, height: 8)
                    Text("Edge hours (7am, 6pm)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(NSColor.systemRed))
                        .frame(width: 8, height: 8)
                    Text("Outside hours")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let origin = selectedOriginCity {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("From: \(origin.name)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Button(action: { selectedOriginCity = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Clear selection")
                    }
                } else if locationManager.currentLocation != nil {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text("Your location")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            calculateAdjustedPositions()
            centerOnNearestCity()
        }
    }

    private func centerOnNearestCity() {
        guard let userLocation = locationManager.currentLocation else { return }

        // Find nearest city
        let nearest = cities.min(by: { city1, city2 in
            city1.distance(from: userLocation) < city2.distance(from: userLocation)
        })

        guard let nearestCity = nearest else { return }

        // Get the ORIGINAL position of the nearest city (not adjusted)
        let cityPoint = coordinateToPoint(
            lat: nearestCity.coordinate.latitude,
            lon: nearestCity.coordinate.longitude
        )

        // Calculate offset to center this city
        let centerX = mapWidth / 2
        let centerY = mapHeight / 2

        let offsetX = centerX - cityPoint.x
        let offsetY = centerY - cityPoint.y

        panOffset = CGSize(width: offsetX, height: offsetY)
        lastPanOffset = panOffset
    }

    // Convert lat/long to view coordinates using equirectangular projection
    private func coordinateToPoint(lat: Double, lon: Double) -> CGPoint {
        let padding: CGFloat = 20
        let effectiveWidth = mapWidth - (padding * 2)
        let effectiveHeight = mapHeight - (padding * 2)

        // Longitude: -180 to 180 -> 0 to width
        let x = padding + ((lon + 180) / 360) * effectiveWidth

        // Latitude: 90 to -90 -> 0 to height (inverted because y increases downward)
        let y = padding + ((90 - lat) / 180) * effectiveHeight

        return CGPoint(x: x, y: y)
    }

    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomScale = min(maxZoom, zoomScale + 0.5)
        }
    }

    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomScale = max(minZoom, zoomScale - 0.5)
        }
    }

    private func resetZoom() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomScale = 1.0
            panOffset = .zero
            lastPanOffset = .zero
        }
    }

    // Calculate adjusted positions to prevent overlapping (called once)
    private func calculateAdjustedPositions() {
        // Only calculate once
        guard adjustedPositions == nil else { return }

        var positions: [String: CGPoint] = [:]
        var originalPositions: [String: CGPoint] = [:]

        // Initialize with original positions
        for city in cities {
            let point = coordinateToPoint(
                lat: city.coordinate.latitude,
                lon: city.coordinate.longitude
            )
            positions[city.name] = point
            originalPositions[city.name] = point
        }

        // Maximum distance a city can move from its original position
        let maxDisplacement: CGFloat = 60

        // Apply repulsion iterations to spread out overlapping nodes
        let iterations = 20
        for _ in 0..<iterations {
            for i in 0..<cities.count {
                let city1 = cities[i]
                guard var pos1 = positions[city1.name],
                      let orig1 = originalPositions[city1.name] else { continue }

                for j in (i+1)..<cities.count {
                    let city2 = cities[j]
                    guard var pos2 = positions[city2.name],
                          let orig2 = originalPositions[city2.name] else { continue }

                    let dx = pos1.x - pos2.x
                    let dy = pos1.y - pos2.y
                    let distance = sqrt(dx * dx + dy * dy)

                    if distance < minNodeDistance && distance > 0.1 {
                        // Push both apart equally
                        let overlap = (minNodeDistance - distance) / 2
                        let pushX = (dx / distance) * overlap
                        let pushY = (dy / distance) * overlap

                        pos1.x += pushX
                        pos1.y += pushY
                        pos2.x -= pushX
                        pos2.y -= pushY

                        // Constrain to max displacement from original
                        let disp1 = sqrt(pow(pos1.x - orig1.x, 2) + pow(pos1.y - orig1.y, 2))
                        if disp1 > maxDisplacement {
                            let scale = maxDisplacement / disp1
                            pos1.x = orig1.x + (pos1.x - orig1.x) * scale
                            pos1.y = orig1.y + (pos1.y - orig1.y) * scale
                        }

                        let disp2 = sqrt(pow(pos2.x - orig2.x, 2) + pow(pos2.y - orig2.y, 2))
                        if disp2 > maxDisplacement {
                            let scale = maxDisplacement / disp2
                            pos2.x = orig2.x + (pos2.x - orig2.x) * scale
                            pos2.y = orig2.y + (pos2.y - orig2.y) * scale
                        }

                        positions[city1.name] = pos1
                        positions[city2.name] = pos2
                    }
                }
            }
        }

        adjustedPositions = positions
    }

    private func getPosition(for city: City) -> CGPoint {
        if let positions = adjustedPositions, let adjusted = positions[city.name] {
            return adjusted
        }
        return coordinateToPoint(
            lat: city.coordinate.latitude,
            lon: city.coordinate.longitude
        )
    }
}

// Scroll wheel support for zooming
extension View {
    func onScrollWheel(action: @escaping (CGPoint) -> Void) -> some View {
        self.background(ScrollWheelHandler(action: action))
    }
}

struct ScrollWheelHandler: NSViewRepresentable {
    let action: (CGPoint) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = ScrollWheelView()
        view.action = action
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? ScrollWheelView)?.action = action
    }
}

class ScrollWheelView: NSView {
    var action: ((CGPoint) -> Void)?
    private var lastScrollTime: Date = .distantPast

    override func scrollWheel(with event: NSEvent) {
        // Throttle scroll events
        let now = Date()
        guard now.timeIntervalSince(lastScrollTime) > 0.016 else { return } // ~60fps max
        lastScrollTime = now

        // Clamp delta to reasonable bounds
        let deltaY = max(-5, min(5, event.scrollingDeltaY))
        action?(CGPoint(x: event.scrollingDeltaX, y: deltaY))
    }
}

// Simplified world outline shape
struct WorldOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Just draw a rectangle for the world bounds
        path.addRect(rect)

        // Add equator
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))

        // Add prime meridian
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

// Grid lines for the map
struct GridLinesView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Vertical lines (longitude) every 30 degrees
        for i in 1..<12 {
            let x = rect.minX + (CGFloat(i) / 12.0) * rect.width
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        // Horizontal lines (latitude) every 30 degrees
        for i in 1..<6 {
            let y = rect.minY + (CGFloat(i) / 6.0) * rect.height
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        return path
    }
}

#Preview {
    WorldMapView(cities: City.zendeskCities)
}
