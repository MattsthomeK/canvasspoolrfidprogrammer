//
//  ContentView.swift
//  CanvasRFID
//
//  Modern UI/UX redesign following Apple Human Interface Guidelines
//

import SwiftUI

struct ContentView: View {
    @StateObject private var filamentDB = FilamentDatabase()
    @StateObject private var nfcManager = NFCManager()
    @StateObject private var settings = AppSettings.shared
    
    @State private var selectedProfile: FilamentProfile?
    @State private var selectedColor: Color = .blue
    @State private var selectedSpoolSize: SpoolSize = .kg1
    @State private var showingColorPicker = false
    @State private var showingAddFilament = false
    @State private var showingEditFilament = false
    @State private var showingLockStatus = false
    @State private var showingAbout = false
    @State private var showingSettings = false
    @State private var showingTagDetails = false
    @State private var currentTagDetails: TagDetails?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Section - Tag Status Card
                    TagStatusCard(nfcManager: nfcManager)
                    
                    // Main Content
                    VStack(spacing: 16) {
                        // Filament Selection Card
                        FilamentSelectionCard(
                            selectedProfile: $selectedProfile,
                            filamentDB: filamentDB,
                            showingAddFilament: $showingAddFilament,
                            showingEditFilament: $showingEditFilament
                        )
                        
                        // Spool Configuration Card
                        if selectedProfile != nil {
                            SpoolConfigCard(
                                selectedColor: $selectedColor,
                                selectedSpoolSize: $selectedSpoolSize,
                                showingColorPicker: $showingColorPicker
                            )
                        }
                        
                        // Action Buttons
                        ActionButtonsCard(
                            nfcManager: nfcManager,
                            selectedProfile: selectedProfile,
                            selectedColor: selectedColor,
                            selectedSpoolSize: selectedSpoolSize,
                            showingLockStatus: $showingLockStatus
                        )
                    }
                    .padding(.horizontal)
                    
                    // Footer
                    FooterView()
                        .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Canvas RFID")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        resetToDefaults()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        
                        Button {
                            showingAbout = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingColorPicker) {
                ColorPickerView(selectedColor: $selectedColor)
            }
            .sheet(isPresented: $showingAddFilament) {
                AddFilamentView(database: filamentDB)
            }
            .sheet(isPresented: $showingEditFilament) {
                if let profile = selectedProfile {
                    EditFilamentView(database: filamentDB, profile: profile) { updatedProfile in
                        selectedProfile = updatedProfile
                    }
                }
            }
            .sheet(isPresented: $showingLockStatus) {
                LockStatusView(lockStatus: nfcManager.tagLockStatus)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
            .sheet(isPresented: $showingTagDetails) {
                if let details = currentTagDetails {
                    TagDetailsView(details: details)
                }
            }
            .onChange(of: nfcManager.lastReadBytes) { oldValue, newBytes in
                if let bytes = newBytes, let tagData = RFIDTagData.fromBytes(bytes, database: filamentDB) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedProfile = tagData.profile
                        selectedColor = tagData.color
                        selectedSpoolSize = tagData.spoolSize
                        nfcManager.lastReadData = tagData
                    }
                    
                    // Show tag details
                    let memoryUsed = bytes.count
                    let tagDetails = TagDetails(
                        uid: nfcManager.tagUID,
                        tagType: nfcManager.tagType.isEmpty ? "NTAG215" : nfcManager.tagType,
                        memoryUsed: memoryUsed,
                        memoryTotal: 504,
                        readDate: Date(),
                        hasData: true,
                        dataType: "Filament: \(tagData.profile.name)"
                    )
                    currentTagDetails = tagDetails
                    showingTagDetails = true
                }
            }
        }
    }
    
    // MARK: - Reset to Defaults
    
    private func resetToDefaults() {
        withAnimation(.spring(response: 0.3)) {
            selectedProfile = nil
            selectedColor = .blue
            selectedSpoolSize = settings.defaultSpoolSize
            nfcManager.tagUID = ""
            nfcManager.tagType = ""
            nfcManager.lastReadData = nil
            nfcManager.lastReadBytes = nil
            nfcManager.tagLockStatus = ""
            nfcManager.statusMessage = ""
        }
    }
}

// MARK: - Tag Status Card

struct TagStatusCard: View {
    @ObservedObject var nfcManager: NFCManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: nfcManager.tagUID.isEmpty ? 
                            [Color.gray.opacity(0.3), Color.gray.opacity(0.1)] :
                            [Color.blue, Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: nfcManager.tagUID.isEmpty ? "wave.3.right" : "checkmark.circle.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.top, 8)
            
            // Status
            VStack(spacing: 4) {
                Text(nfcManager.tagUID.isEmpty ? "No Tag Detected" : "Tag Connected")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !nfcManager.tagUID.isEmpty {
                    Text(nfcManager.tagType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(nfcManager.tagUID)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            
            // Status Message
            if !nfcManager.statusMessage.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: nfcManager.statusMessage.contains("success") || 
                                      nfcManager.statusMessage.contains("✅") ? 
                                      "checkmark.circle.fill" : "info.circle.fill")
                        .foregroundColor(nfcManager.statusMessage.contains("success") || 
                                        nfcManager.statusMessage.contains("✅") ? 
                                        .green : .orange)
                    
                    Text(nfcManager.statusMessage)
                        .font(.callout)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
        )
        .padding(.horizontal)
    }
}

// MARK: - Filament Selection Card

struct FilamentSelectionCard: View {
    @Binding var selectedProfile: FilamentProfile?
    @ObservedObject var filamentDB: FilamentDatabase
    @Binding var showingAddFilament: Bool
    @Binding var showingEditFilament: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Filament Profile", systemImage: "cube.fill")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddFilament = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            }
            
            // Profile Picker
            Menu {
                ForEach(filamentDB.profiles) { profile in
                    Button(action: { 
                        withAnimation(.spring(response: 0.3)) {
                            selectedProfile = profile
                        }
                    }) {
                        HStack {
                            Text(profile.displayName)
                            if selectedProfile?.id == profile.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedProfile?.displayName ?? "Select Material")
                        .foregroundColor(selectedProfile == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
            
            // Profile Details
            if let profile = selectedProfile {
                VStack(spacing: 12) {
                    Divider()
                    
                    DetailRow(icon: "tag", label: "Type", value: profile.type.rawValue)
                    DetailRow(icon: "atom", label: "Subtype", value: profile.subtypeName)
                    
                    Divider()
                    
                    // Temperatures
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Temperature Settings", systemImage: "thermometer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            TemperatureBadge(
                                icon: "flame",
                                label: "Extruder",
                                range: "\(profile.temperatures.extruderMin)-\(profile.temperatures.extruderMax)°C"
                            )
                        }
                    }
                    
                    // Edit/Delete buttons for all profiles (users can manage their own list)
                    Divider()
                    
                    HStack(spacing: 12) {
                        Button(action: { showingEditFilament = true }) {
                            Label("Edit", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(role: .destructive, action: {
                            filamentDB.deleteProfile(profile)
                            selectedProfile = nil
                        }) {
                            Label("Delete", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Spool Configuration Card

struct SpoolConfigCard: View {
    @Binding var selectedColor: Color
    @Binding var selectedSpoolSize: SpoolSize
    @Binding var showingColorPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Spool Settings", systemImage: "gearshape.fill")
                .font(.headline)
            
            // Color and Spool Size Side by Side
            HStack(spacing: 12) {
                // Color Picker
                Button(action: { showingColorPicker = true }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "paintpalette")
                                .font(.caption)
                            Text("Color")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedColor)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                }
                .buttonStyle(.plain)
                
                // Spool Size Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "scalemass")
                            .font(.caption)
                        Text("Spool Size")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(SpoolSize.allCases, id: \.self) { size in
                            Button(action: {
                                withAnimation(.spring(response: 0.2)) {
                                    selectedSpoolSize = size
                                }
                            }) {
                                HStack {
                                    Text(size.rawValue)
                                    if selectedSpoolSize == size {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedSpoolSize.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.tertiarySystemGroupedBackground))
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Action Buttons Card

struct ActionButtonsCard: View {
    @ObservedObject var nfcManager: NFCManager
    let selectedProfile: FilamentProfile?
    let selectedColor: Color
    let selectedSpoolSize: SpoolSize
    @Binding var showingLockStatus: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Primary Action - Write
            Button(action: {
                guard let profile = selectedProfile else {
                    nfcManager.statusMessage = "⚠️ Please select a filament profile"
                    return
                }
                let tagData = RFIDTagData(
                    profile: profile,
                    color: selectedColor,
                    spoolSize: selectedSpoolSize
                )
                nfcManager.startWriteSession(data: tagData)
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title3)
                    Text("Write to Tag")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if selectedProfile == nil {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.3))
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                    }
                )
                .foregroundColor(.white)
            }
            .disabled(selectedProfile == nil || nfcManager.isScanning)
            .buttonStyle(.plain)
            
            // Secondary Actions
            HStack(spacing: 12) {
                ActionButton(
                    icon: "arrow.up.doc",
                    title: "Read",
                    color: .green,
                    disabled: nfcManager.isScanning
                ) {
                    nfcManager.startReadSession()
                }
                
                ActionButton(
                    icon: "lock.shield",
                    title: "Status",
                    color: .orange,
                    disabled: nfcManager.isScanning
                ) {
                    nfcManager.checkTagLockStatus()
                    showingLockStatus = true
                }
                
                ActionButton(
                    icon: "trash",
                    title: "Format",
                    color: .red,
                    disabled: nfcManager.isScanning
                ) {
                    nfcManager.startFormatSession()
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .foregroundColor(disabled ? .gray : color)
        }
        .disabled(disabled)
        .buttonStyle(.plain)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct TemperatureBadge: View {
    let icon: String
    let label: String
    let range: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            Text(range)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

struct FooterView: View {
    var body: some View {
        VStack(spacing: 16) {
            // App info
            VStack(spacing: 8) {
                Text("Canvas Spool Programmer")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("Write NFC tags to identify filament spools with the Elegoo Canvas RFID system")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Lock Status View

struct LockStatusView: View {
    let lockStatus: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if lockStatus.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "lock.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("No Lock Status")
                                .font(.headline)
                            
                            Text("Tap 'Status' button to check tag lock status")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        Text(lockStatus)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Lock Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Add/Edit Filament Views (unchanged - keeping existing functionality)

struct AddFilamentView: View {
    @ObservedObject var database: FilamentDatabase
    @Environment(\.dismiss) var dismiss

    @State private var type: FilamentType = .pla
    @State private var subtypeId: UInt8 = 0
    @State private var extruderMin = 200
    @State private var extruderMax = 220

    var body: some View {
        NavigationStack {
            Form {
                Section("Filament Information") {
                    Picker("Type", selection: $type) {
                        ForEach(FilamentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Picker("Subtype", selection: $subtypeId) {
                        ForEach(type.subtypes, id: \.id) { subtype in
                            Text(subtype.name).tag(subtype.id)
                        }
                    }
                }

                Section("Temperature Settings") {
                    Stepper("Extruder Min: \(extruderMin)°C", value: $extruderMin, in: 150...350, step: 5)
                    Stepper("Extruder Max: \(extruderMax)°C", value: $extruderMax, in: 150...350, step: 5)

                    Button("Load Defaults for \(type.rawValue)") {
                        let temps = TemperatureSettings.defaultTemperatures(for: type, subtypeId: subtypeId)
                        extruderMin = temps.extruderMin
                        extruderMax = temps.extruderMax
                    }
                }
            }
            .navigationTitle("Add Filament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let subtypeName = type.subtype(id: subtypeId)?.name ?? type.rawValue
                        let profile = FilamentProfile(
                            name: subtypeName,
                            type: type,
                            subtypeId: subtypeId,
                            temperatures: TemperatureSettings(
                                extruderMin: extruderMin,
                                extruderMax: extruderMax
                            ),
                            isCustom: true
                        )
                        database.addProfile(profile)
                        dismiss()
                    }
                    .bold()
                }
            }
            .onChange(of: type) { _, newType in
                subtypeId = newType.subtypes.first?.id ?? 0
                let temps = TemperatureSettings.defaultTemperatures(for: newType, subtypeId: subtypeId)
                extruderMin = temps.extruderMin
                extruderMax = temps.extruderMax
            }
            .onChange(of: subtypeId) { _, newSubtypeId in
                let temps = TemperatureSettings.defaultTemperatures(for: type, subtypeId: newSubtypeId)
                extruderMin = temps.extruderMin
                extruderMax = temps.extruderMax
            }
            .onAppear {
                subtypeId = type.subtypes.first?.id ?? 0
                let temps = TemperatureSettings.defaultTemperatures(for: type, subtypeId: subtypeId)
                extruderMin = temps.extruderMin
                extruderMax = temps.extruderMax
            }
        }
    }
}

struct EditFilamentView: View {
    @ObservedObject var database: FilamentDatabase
    let profile: FilamentProfile
    var onSave: (FilamentProfile) -> Void = { _ in }
    @Environment(\.dismiss) var dismiss

    @State private var type: FilamentType
    @State private var subtypeId: UInt8
    @State private var extruderMin: Int
    @State private var extruderMax: Int

    init(database: FilamentDatabase, profile: FilamentProfile, onSave: @escaping (FilamentProfile) -> Void = { _ in }) {
        self._database = ObservedObject(wrappedValue: database)
        self.profile = profile
        self.onSave = onSave
        _type = State(initialValue: profile.type)
        _subtypeId = State(initialValue: profile.subtypeId)
        _extruderMin = State(initialValue: profile.temperatures.extruderMin)
        _extruderMax = State(initialValue: profile.temperatures.extruderMax)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Filament Information") {
                    Picker("Type", selection: $type) {
                        ForEach(FilamentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    Picker("Subtype", selection: $subtypeId) {
                        ForEach(type.subtypes, id: \.id) { subtype in
                            Text(subtype.name).tag(subtype.id)
                        }
                    }
                }

                Section("Temperature Settings") {
                    Stepper("Extruder Min: \(extruderMin)°C", value: $extruderMin, in: 150...350, step: 5)
                    Stepper("Extruder Max: \(extruderMax)°C", value: $extruderMax, in: 150...350, step: 5)
                }
            }
            .navigationTitle("Edit Filament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedProfile = profile
                        updatedProfile.type = type
                        updatedProfile.subtypeId = subtypeId
                        updatedProfile.name = type.subtype(id: subtypeId)?.name ?? type.rawValue
                        updatedProfile.temperatures = TemperatureSettings(
                            extruderMin: extruderMin,
                            extruderMax: extruderMax
                        )
                        database.updateProfile(updatedProfile)
                        onSave(updatedProfile)
                        dismiss()
                    }
                    .bold()
                }
            }
            .onChange(of: type) { _, newType in
                let newSubtypeId = newType.subtype(id: subtypeId)?.id ?? (newType.subtypes.first?.id ?? 0)
                subtypeId = newSubtypeId
                if let subtype = newType.subtype(id: newSubtypeId) {
                    extruderMin = subtype.extruderMin
                    extruderMax = subtype.extruderMax
                }
            }
            .onChange(of: subtypeId) { _, newSubtypeId in
                if let subtype = type.subtype(id: newSubtypeId) {
                    extruderMin = subtype.extruderMin
                    extruderMax = subtype.extruderMax
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
