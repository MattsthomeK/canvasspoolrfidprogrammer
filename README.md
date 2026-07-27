# Canvas Spool Programmer

An iOS application for programming RFID tags (NTAG213/215/216) for Elegoo Canvas
filament spools on the Centauri Carbon and Centauri Carbon 2 3D printers.

## Features

- ✅ **Read/Write RFID Tags**: Read and write filament data to NFC RFID tags
- ✅ **Filament Database**: Pre-loaded with Elegoo-compatible filament profiles and support for custom materials
- ✅ **Color Picker**: Advanced color picker with gradient selector, RGB sliders, and preset colors
- ✅ **Temperature Settings**: Configure extruder temperatures for each material and subtype
- ✅ **Multiple Spool Weights**: Support for 250G to 1KG spools
- ✅ **Auto-Read Mode**: Automatically read tags when detected

## Requirements

- iOS 16.0 or later
- iPhone with NFC capability (iPhone 7 or later)
- NTAG213, NTAG215, or NTAG216 compatible RFID tags
- Apple Developer Program membership (required for NFC entitlement)

## Compatible Printers

- Elegoo Centauri Carbon (with Canvas upgrade)
- Elegoo Centauri Carbon 2

## Tag Format

This app writes the verified Elegoo Canvas RFID format as reverse-engineered
by the community. Data is written as raw page data starting at page 16:

- **Pages 4–15**: Zeroed
- **Page 16**: Header (0x36) + Manufacturer code (0xEEEEEEEE)
- **Page 17**: Manufacturer code end
- **Page 18**: Material type (4-byte encoded)
- **Page 19**: Type index + Subtype ID
- **Page 20**: Color (RGB + 0xFF)
- **Page 21**: Extruder temp min/max (big-endian)
- **Page 22**: Reserved (zeros)
- **Page 23**: Diameter (175) + Weight in grams (big-endian)
- **Page 24**: Production date constant
- **Pages 25–31**: Reserved (zeros)

## Installation

### Using Xcode

1. Open `ACE_RFID_iOS.xcodeproj` in Xcode
2. Connect your iPhone
3. Select your development team in Signing & Capabilities
4. Build and run on your device (NFC does not work in the simulator)

## Usage

### Writing a Tag

1. Select a material type and subtype
2. Choose a color using the color picker
3. Select the spool weight
4. Tap "Write Tag"
5. Hold your iPhone near the RFID tag
6. Wait for the success beep/confirmation

### Reading a Tag

1. Tap "Read Tag"
2. Hold your iPhone near the RFID tag
3. The app will display the stored filament information

### Formatting a Tag

If a tag fails to write, format it first:
1. Tap "Format Tag"
2. Hold your iPhone near the RFID tag
3. Then retry writing

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **Core NFC**: Native iOS NFC tag reading/writing via NFCMiFareTag
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data management

### Key Files

- `ContentView.swift`: Main UI and coordination
- `NFCManager.swift`: NFC tag reading/writing logic
- `FilamentModel.swift`: Elegoo format encoder/decoder and filament database
- `ColorPickerView.swift`: Advanced color picker interface

### NFC Tag Commands

- **READ (0x30)**: Read 4 pages (16 bytes) at once
- **WRITE (0xA2)**: Write 1 page (4 bytes) at a time

## Known Limitations

- NFC only works on physical devices, not in the simulator
- Requires paid Apple Developer Program membership for NFC entitlement
- Some tags may require formatting before first use

## Troubleshooting

### "NFC is not available"
- Ensure you're running on a physical iPhone 7 or later
- NFC does not work in the simulator

### "Failed to write tag"
- Try formatting the tag first
- Ensure the tag is NTAG213, 215, or 216 compatible
- Hold the iPhone steady near the tag during the entire write operation

### Tag not recognized by Canvas
- Ensure the tag was written with this app, not a generic NFC tool
- The Canvas reads pages 4–44 and validates the 0x36 header at page 16

## Contributing

Pull requests and issues welcome. If you have access to a Canvas unit and can
verify tag compatibility, that feedback is especially valuable.

## License

**MIT License** — See [LICENSE](LICENSE) file for details.

## Credits

- **Original iOS NFC infrastructure**: [martinbogo/rfidspoolprogrammer](https://github.com/martinbogo/rfidspoolprogrammer) (MIT License)
- **Elegoo tag format reverse engineering**: [DnG-Crafts/ELG-RFID](https://github.com/DnG-Crafts/ELG-RFID)
- **Elegoo RFID specification**: [ELEGOO-3D/ELEGOO-RFID-Tag-Guide](https://github.com/ELEGOO-3D/ELEGOO-RFID-Tag-Guide)
- **Canvas format conversion and iOS adaptation**: Matt Steuer, 2026
