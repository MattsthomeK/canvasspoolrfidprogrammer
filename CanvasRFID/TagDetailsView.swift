//
//  TagDetailsView.swift
//  Spool Programmer
//
//  Detailed tag information display
//

import SwiftUI

struct TagDetailsView: View {
    let details: TagDetails
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack(spacing: 8) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 20))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(details.tagType)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    // Decoded Filament Data Card
                    if let filamentType = details.filamentType {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Decoded Filament Data", systemImage: "thermometer")
                                .font(.headline)

                            HStack {
                                Text("Type")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(filamentType)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }

                            if let filamentSubtype = details.filamentSubtype {
                                HStack {
                                    Text("Subtype")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(filamentSubtype)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }

                            if let extruderMin = details.extruderMin, let extruderMax = details.extruderMax {
                                HStack {
                                    Text("Extruder")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(extruderMin)–\(extruderMax)°C")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }

                            if let filamentColor = details.filamentColor {
                                HStack {
                                    Text("Color")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(filamentColor)
                                        .frame(width: 44, height: 24)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Data Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tag Contents", systemImage: "doc.text")
                            .font(.headline)

                        if details.hasData, let dataType = details.dataType {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(dataType)
                                    .font(.subheadline)
                            }
                        } else {
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                Text("No filament data detected")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("Read \(details.formattedReadDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // UID
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tag UID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(details.uid)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                    // Memory Usage Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Memory Usage", systemImage: "internaldrive")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.0f%%", details.memoryUsagePercent))
                                .font(.headline)
                                .foregroundColor(memoryUsageColor)
                        }

                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.tertiarySystemBackground))
                                    .frame(height: 8)
                                    .cornerRadius(4)

                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [.blue, memoryUsageColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: geometry.size.width * CGFloat(details.memoryUsagePercent / 100.0), height: 8)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)

                        Text(details.memoryUsageText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tag Details")
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
    
    private var memoryUsageColor: Color {
        let percent = details.memoryUsagePercent
        if percent > 90 {
            return .red
        } else if percent > 70 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    TagDetailsView(details: TagDetails(
        uid: "04:A1:B2:C3:D4:E5:F6",
        tagType: "NTAG215",
        memoryUsed: 144,
        memoryTotal: 504,
        readDate: Date(),
        hasData: true,
        dataType: "PLA Filament",
        filamentType: "PLA",
        filamentSubtype: "PLA+",
        extruderMin: 190,
        extruderMax: 230,
        filamentColor: .blue
    ))
}
