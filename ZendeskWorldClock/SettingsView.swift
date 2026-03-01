import SwiftUI

struct SettingsView: View {
    @AppStorage("use12HourFormat") private var use12HourFormat = false
    @Binding var hiddenCities: Set<String>
    @Environment(\.dismiss) var dismiss

    private var hiddenCitiesSorted: [String] {
        hiddenCities.sorted()
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.headline)

            Toggle("Use 12-hour format", isOn: $use12HourFormat)

            Divider()

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
                    .frame(maxHeight: 120)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button("Done") {
                dismiss()
            }
        }
        .padding()
        .frame(width: 300, height: 300)
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
