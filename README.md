# Zendesk World Clock

A macOS menu bar app that displays current times across all Zendesk office locations worldwide.

## Features

### Phase 1 (Completed)
- **Menu bar integration**: Lightweight app that lives in your menu bar (no Dock icon)
- **25 Zendesk office cities**: Automatically sorted from west to east by timezone
- **Work hours indicators**: Color-coded status for each city
  - 🟢 Green: Core work hours (8am - 6pm)
  - 🟠 Orange: Edge hours (7-8am, 6-7pm)
  - 🔴 Red: Outside work hours
- **Real-time updates**: Clock refreshes every second
- **12/24-hour format**: Toggle between time formats in settings
- **Persistent settings**: Your preferences are saved between app launches
- **Clean macOS design**: Matches native system styling

### Cities Included
Honolulu, San Francisco, Austin, Madison, Montréal, Mexico City, São Paulo, Amsterdam, Berlin, Copenhagen, Dublin, Kraków, Lisbon, London, Milan, Novi Sad, Paris, Tallinn, Bengaluru, Melbourne, Pune, Seoul, Singapore, Taguig, Tokyo

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later

## Building the App

### Using Xcode
1. Open the project:
   ```bash
   open ZendeskWorldClock.xcodeproj
   ```

2. Build and run with `⌘R` or from Product → Run

### Using Command Line
1. Build the app:
   ```bash
   xcodebuild -project ZendeskWorldClock.xcodeproj \
              -scheme ZendeskWorldClock \
              -configuration Debug \
              build
   ```

2. Run the app:
   ```bash
   open ~/Library/Developer/Xcode/DerivedData/ZendeskWorldClock-*/Build/Products/Debug/ZendeskWorldClock.app
   ```

## Using the App

1. **Launch**: Run the app - a globe icon (🌍) appears in your menu bar
2. **View times**: Click the globe icon to see the dropdown with all cities
3. **Settings**: Click the gear icon (⚙️) in the dropdown header to access settings
4. **Format toggle**: Switch between 12-hour (with AM/PM) and 24-hour time formats

## Project Structure

```
ZendeskWorldClock/
├── ZendeskWorldClockApp.swift    # App entry point and AppDelegate
├── MenuBarController.swift       # Menu bar integration and popover management
├── ContentView.swift             # Main UI with city list
├── SettingsView.swift            # Settings panel
├── City.swift                    # City model and timezone logic
├── Assets.xcassets/              # App icon and assets
└── Info.plist                    # App configuration

ZendeskWorldClock.xcodeproj/      # Xcode project file
REQS.md                           # Requirements and roadmap
```

## Development Notes

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **AppKit**: For menu bar integration (`NSStatusBar`, `NSPopover`)
- **Foundation**: For timezone calculations and date formatting

### Clean Build
If you encounter build issues:
```bash
# Clean build folder
xcodebuild -project ZendeskWorldClock.xcodeproj clean

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/ZendeskWorldClock-*

# Rebuild
xcodebuild -project ZendeskWorldClock.xcodeproj \
           -scheme ZendeskWorldClock \
           -configuration Debug \
           build
```

### Quit the App
Since the app has no Dock icon:
```bash
# Find and kill the process
pkill -f ZendeskWorldClock

# Or use Activity Monitor to quit
```

## Roadmap

### Phase 2 (Planned)
- Hide/show individual cities
- Eye icon on each row to toggle visibility
- Settings page enhancements to manage hidden cities

## License

Internal Zendesk tool.
