//
//  FilamentModel.swift
//  ACE RFID iOS
//
//  Data models for filament management
//

import Foundation
import SwiftUI

// MARK: - Debug Helper
private func debugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}

// MARK: - Filament Subtype
struct FilamentSubtype: Codable, Hashable {
    var id: UInt8
    var name: String
    var extruderMin: Int
    var extruderMax: Int
}

// MARK: - Filament Material Types
enum FilamentType: String, CaseIterable, Codable {
    case pla = "PLA"
    case petg = "PETG"
    case abs = "ABS"
    case tpu = "TPU"
    case pa = "PA"
    case cpe = "CPE"
    case pc = "PC"
    case pva = "PVA"
    case asa = "ASA"
    case bvoh = "BVOH"
    case eva = "EVA"
    case hips = "HIPS"
    case pp = "PP"
    case ppa = "PPA"
    case pps = "PPS"

    // Position in allCases doubles as the Elegoo tag's typeIndex byte
    var typeIndex: UInt8 {
        UInt8(FilamentType.allCases.firstIndex(of: self) ?? 0)
    }

    init?(typeIndex: UInt8) {
        let cases = FilamentType.allCases
        guard typeIndex < cases.count else { return nil }
        self = cases[Int(typeIndex)]
    }

    var subtypes: [FilamentSubtype] {
        FilamentType.subtypeTable[self] ?? []
    }

    func subtype(id: UInt8) -> FilamentSubtype? {
        subtypes.first { $0.id == id }
    }

    static let subtypeTable: [FilamentType: [FilamentSubtype]] = [
        .pla: [
            FilamentSubtype(id: 0, name: "PLA", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 1, name: "PLA+", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 2, name: "PLA PRO", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 3, name: "PLA Silk", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 4, name: "PLA-CF", extruderMin: 210, extruderMax: 240),
            FilamentSubtype(id: 6, name: "PLA Matte", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 8, name: "PLA Wood", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 9, name: "PLA Basic", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 10, name: "RAPID PLA+", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 11, name: "PLA Marble", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 12, name: "PLA Galaxy", extruderMin: 190, extruderMax: 230),
            FilamentSubtype(id: 13, name: "PLA Red Copper", extruderMin: 190, extruderMax: 230),
        ],
        .petg: [
            FilamentSubtype(id: 0, name: "PETG", extruderMin: 230, extruderMax: 260),
            FilamentSubtype(id: 1, name: "PETG-CF", extruderMin: 240, extruderMax: 270),
            FilamentSubtype(id: 2, name: "PETG-GF", extruderMin: 240, extruderMax: 270),
            FilamentSubtype(id: 3, name: "PETG PRO", extruderMin: 230, extruderMax: 260),
            FilamentSubtype(id: 4, name: "PETG Translucent", extruderMin: 230, extruderMax: 260),
            FilamentSubtype(id: 5, name: "RAPID PETG", extruderMin: 230, extruderMax: 260),
        ],
        .abs: [
            FilamentSubtype(id: 0, name: "ABS", extruderMin: 240, extruderMax: 280),
        ],
        .tpu: [
            FilamentSubtype(id: 1, name: "TPU 95A", extruderMin: 220, extruderMax: 240),
            FilamentSubtype(id: 2, name: "RAPID TPU 95A", extruderMin: 220, extruderMax: 240),
        ],
        .pa: [
            FilamentSubtype(id: 0, name: "PAHT-CF", extruderMin: 280, extruderMax: 320),
        ],
        .cpe: [
            FilamentSubtype(id: 0, name: "CPE", extruderMin: 250, extruderMax: 250),
        ],
        .pc: [
            FilamentSubtype(id: 0, name: "PC", extruderMin: 260, extruderMax: 290),
            FilamentSubtype(id: 2, name: "PC-FR", extruderMin: 260, extruderMax: 290),
        ],
        .pva: [
            FilamentSubtype(id: 0, name: "PVA", extruderMin: 210, extruderMax: 210),
        ],
        .asa: [
            FilamentSubtype(id: 0, name: "ASA", extruderMin: 240, extruderMax: 280),
        ],
        .bvoh: [
            FilamentSubtype(id: 0, name: "BVOH", extruderMin: 210, extruderMax: 210),
        ],
        .eva: [
            FilamentSubtype(id: 0, name: "EVA", extruderMin: 220, extruderMax: 220),
        ],
        .hips: [
            FilamentSubtype(id: 0, name: "HIPS", extruderMin: 250, extruderMax: 250),
        ],
        .pp: [
            FilamentSubtype(id: 0, name: "PP", extruderMin: 260, extruderMax: 260),
        ],
        .ppa: [
            FilamentSubtype(id: 0, name: "PPA", extruderMin: 310, extruderMax: 310),
        ],
        .pps: [
            FilamentSubtype(id: 0, name: "PPS", extruderMin: 350, extruderMax: 350),
        ],
    ]
}

// MARK: - Spool Sizes (by weight, matching Elegoo Canvas spools)
enum SpoolSize: String, CaseIterable, Codable {
    case kg1 = "1 KG"
    case g750 = "750 G"
    case g600 = "600 G"
    case g500 = "500 G"
    case g250 = "250 G"

    var weightInGrams: Int {
        switch self {
        case .kg1: return 1000
        case .g750: return 750
        case .g600: return 600
        case .g500: return 500
        case .g250: return 250
        }
    }

    init?(weightInGrams: Int) {
        guard let match = SpoolSize.allCases.first(where: { $0.weightInGrams == weightInGrams }) else { return nil }
        self = match
    }
}

// MARK: - Temperature Settings
struct TemperatureSettings: Codable, Hashable {
    var extruderMin: Int
    var extruderMax: Int

    static func defaultTemperatures(for type: FilamentType, subtypeId: UInt8) -> TemperatureSettings {
        if let subtype = type.subtype(id: subtypeId) {
            return TemperatureSettings(extruderMin: subtype.extruderMin, extruderMax: subtype.extruderMax)
        }
        let fallback = type.subtypes.first
        return TemperatureSettings(extruderMin: fallback?.extruderMin ?? 200, extruderMax: fallback?.extruderMax ?? 220)
    }
}

// MARK: - Filament Profile
struct FilamentProfile: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var type: FilamentType
    var subtypeId: UInt8
    var temperatures: TemperatureSettings
    var isCustom: Bool

    var subtype: FilamentSubtype? {
        type.subtype(id: subtypeId)
    }

    var subtypeName: String {
        subtype?.name ?? type.rawValue
    }

    var displayName: String {
        name.isEmpty ? subtypeName : name
    }
}

// MARK: - Filament Database Manager
class FilamentDatabase: ObservableObject {
    @Published var profiles: [FilamentProfile] = []

    init() {
        loadProfiles()
    }

    private func loadProfiles() {
        // Try to load saved profiles from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "allFilamentProfiles"),
           let savedProfiles = try? JSONDecoder().decode([FilamentProfile].self, from: data) {
            profiles = savedProfiles
        } else {
            // First launch - load default profiles and mark them all as custom (editable)
            profiles = createDefaultProfiles()
            saveProfiles()
        }
    }

    private func createDefaultProfiles() -> [FilamentProfile] {
        // One default profile per material type, using its base subtype (id 0 when available)
        FilamentType.allCases.compactMap { type -> FilamentProfile? in
            guard let subtype = type.subtype(id: 0) ?? type.subtypes.first else { return nil }
            return FilamentProfile(
                name: subtype.name,
                type: type,
                subtypeId: subtype.id,
                temperatures: TemperatureSettings(extruderMin: subtype.extruderMin, extruderMax: subtype.extruderMax),
                isCustom: true
            )
        }
    }

    func saveProfiles() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: "allFilamentProfiles")
        }
    }

    func addProfile(_ profile: FilamentProfile) {
        var newProfile = profile
        newProfile.isCustom = true
        profiles.append(newProfile)
        saveProfiles()
    }

    func updateProfile(_ profile: FilamentProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveProfiles()
        }
    }

    func deleteProfile(_ profile: FilamentProfile) {
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
    }
}

// MARK: - RFID Tag Data Structure
struct RFIDTagData {
    var profile: FilamentProfile
    var color: Color
    var spoolSize: SpoolSize

    // Encodes a material type string (e.g. "PLA") the way Elegoo's real hardware does:
    // each character's decimal ASCII value is read back as a hex byte, packed right-to-left
    // into 4 bytes (e.g. 'P'=80 -> 0x80). Verified against DnG-Crafts/ELG-RFID.
    static func encodeMaterial(_ material: String) -> [UInt8] {
        var result: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        let chars = Array(material.prefix(4))
        for i in 0..<chars.count {
            guard let ascii = chars[chars.count - 1 - i].asciiValue else { continue }
            let hexString = String(ascii)
            guard let byte = UInt8(hexString, radix: 16) else { continue }
            result[3 - i] = byte
        }
        return result
    }

    // Inverse of encodeMaterial: reads each byte as a hex string, interprets that string as
    // a decimal ASCII value, and reconstructs the original material characters.
    static func decodeMaterial(_ bytes: ArraySlice<UInt8>) -> String {
        let values = Array(bytes)
        var chars: [Character] = []
        for byte in values {
            guard byte != 0 else { continue }
            let hexString = String(format: "%02X", byte)
            guard let decimalValue = Int(hexString), let scalar = Unicode.Scalar(decimalValue) else { continue }
            chars.append(Character(scalar))
        }
        return String(chars)
    }

    // Convert to byte array for writing to NTAG (pages 4-31, 112 bytes)
    func toBytes() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 112)

        // Pages 4-15 (bytes 0-47): reserved, all zeros

        // Page 16 (bytes 48-51): Elegoo tag signature
        bytes[48] = 0x36
        bytes[49] = 0xEE
        bytes[50] = 0xEE
        bytes[51] = 0xEE

        // Page 17 (bytes 52-55)
        bytes[52] = 0xEE
        bytes[53] = 0x00
        bytes[54] = 0x00
        bytes[55] = 0x00

        // Page 18 (bytes 56-59): encoded material type string
        let materialBytes = RFIDTagData.encodeMaterial(profile.type.rawValue)
        bytes.replaceSubrange(56..<60, with: materialBytes)

        // Page 19 (bytes 60-63): typeIndex, subtypeId
        bytes[60] = profile.type.typeIndex
        bytes[61] = profile.subtypeId
        bytes[62] = 0x00
        bytes[63] = 0x00

        // Page 20 (bytes 64-67): plain RGB color + alpha
        let colorComponents = UIColor(color).cgColor.components ?? [0, 0, 0, 1]
        bytes[64] = UInt8(max(0, min(1, colorComponents[0])) * 255)
        bytes[65] = UInt8(max(0, min(1, colorComponents[1])) * 255)
        bytes[66] = UInt8(max(0, min(1, colorComponents[2])) * 255)
        bytes[67] = 0xFF

        // Page 21 (bytes 68-71): extruder min/max, UInt16 big-endian
        let extMinBytes = withUnsafeBytes(of: UInt16(profile.temperatures.extruderMin).bigEndian) { Array($0) }
        let extMaxBytes = withUnsafeBytes(of: UInt16(profile.temperatures.extruderMax).bigEndian) { Array($0) }
        bytes[68] = extMinBytes[0]
        bytes[69] = extMinBytes[1]
        bytes[70] = extMaxBytes[0]
        bytes[71] = extMaxBytes[1]

        // Page 22 (bytes 72-75): bed temps unused, all zeros

        // Page 23 (bytes 76-79): diameter (1.75mm), spool weight in grams, UInt16 big-endian
        let diameterBytes = withUnsafeBytes(of: UInt16(175).bigEndian) { Array($0) }
        let weightBytes = withUnsafeBytes(of: UInt16(spoolSize.weightInGrams).bigEndian) { Array($0) }
        bytes[76] = diameterBytes[0]
        bytes[77] = diameterBytes[1]
        bytes[78] = weightBytes[0]
        bytes[79] = weightBytes[1]

        // Page 24 (bytes 80-83): constant
        bytes[80] = 0x00
        bytes[81] = 0x36
        bytes[82] = 0xC8
        bytes[83] = 0x00

        // Pages 25-31 (bytes 84-111): reserved, all zeros

        return bytes
    }

    // Parse from byte array read from NTAG
    static func fromBytes(_ bytes: [UInt8], database: FilamentDatabase) -> RFIDTagData? {
        guard bytes.count >= 112 else { return nil }
        guard bytes[48] == 0x36 else { return nil }  // Empty or non-Elegoo tag

        // Parse type + subtype
        let typeIndex = bytes[60]
        let subtypeId = bytes[61]
        let filamentType = FilamentType(typeIndex: typeIndex) ?? .pla

        // Parse color (plain RGB)
        let red = CGFloat(bytes[64]) / 255.0
        let green = CGFloat(bytes[65]) / 255.0
        let blue = CGFloat(bytes[66]) / 255.0
        let alpha = CGFloat(bytes[67]) / 255.0
        let color = Color(red: red, green: green, blue: blue, opacity: alpha)

        // Parse temperatures
        let extMin = Int(UInt16(bytes[69]) | (UInt16(bytes[68]) << 8))
        let extMax = Int(UInt16(bytes[71]) | (UInt16(bytes[70]) << 8))
        let temps = TemperatureSettings(extruderMin: extMin, extruderMax: extMax)

        // Parse spool weight
        let weight = Int(UInt16(bytes[79]) | (UInt16(bytes[78]) << 8))
        let spoolSize = SpoolSize(weightInGrams: weight) ?? .kg1

        // Find or create profile
        let subtypeName = filamentType.subtype(id: subtypeId)?.name ?? filamentType.rawValue

        var profile = database.profiles.first {
            $0.type == filamentType && $0.subtypeId == subtypeId
        }

        if profile == nil {
            // Create new profile and add to database
            // Mark as custom so user can delete it if needed
            let newProfile = FilamentProfile(
                name: subtypeName,
                type: filamentType,
                subtypeId: subtypeId,
                temperatures: temps,
                isCustom: true
            )
            database.addProfile(newProfile)  // Persist to UserDefaults
            profile = database.profiles.last  // Get the newly added profile
            debugLog("📌 Created new custom profile from tag: \(subtypeName)")
        } else {
            // Update temperatures from tag
            profile?.temperatures = temps
            debugLog("📌 Found existing profile: \(subtypeName)")
        }

        guard let finalProfile = profile else { return nil }

        return RFIDTagData(profile: finalProfile, color: color, spoolSize: spoolSize)
    }
}
