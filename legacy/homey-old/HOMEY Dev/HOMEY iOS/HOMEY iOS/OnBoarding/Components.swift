//
//  Components.swift
//

import PhotosUI
import SwiftUI

// MARK: - Shared Button

struct PrimaryButton: View {
    let title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(12)
        }
    }
}

// MARK: - Form Section container

struct CardSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Contact Methods control

struct ContactMethodPicker: View {
    @Binding var methods: ContactMethod
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Text", isOn: Binding(
                get: { methods.contains(.text) },
                set: { isOn in if isOn { methods.insert(.text) } else { methods.remove(.text) } }
            ))
            Toggle("Call", isOn: Binding(
                get: { methods.contains(.call) },
                set: { isOn in if isOn { methods.insert(.call) } else { methods.remove(.call) } }
            ))
            Toggle("Email", isOn: Binding(
                get: { methods.contains(.email) },
                set: { isOn in if isOn { methods.insert(.email) } else { methods.remove(.email) } }
            ))
            Toggle("In-app", isOn: Binding(
                get: { methods.contains(.inApp) },
                set: { isOn in if isOn { methods.insert(.inApp) } else { methods.remove(.inApp) } }
            ))
        }
    }
}

// MARK: - Chips

struct Chip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(label)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(16)
            .onTapGesture { onTap() }
    }
}

struct NeighborhoodSelector: View {
    let allNeighborhoods: [String]
    @Binding var selected: Set<String>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(allNeighborhoods, id: \.self) { n in
                    Chip(label: n, isSelected: selected.contains(n)) {
                        if selected.contains(n) {
                            selected.remove(n)
                        } else {
                            selected.insert(n)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Photo Picker

struct AvatarPhotoPicker: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var imageData: Data?

    var body: some View {
        HStack(spacing: 12) {
            if let data = imageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.secondary, lineWidth: 1))
            } else {
                Circle().fill(Color.secondary.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
            }
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Upload a photo (optional)")
            }
            .onChange(of: selectedItem) { newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self) {
                        await MainActor.run { imageData = data }
                        // Async avatar generation would happen server-side; this is just the preview.
                    }
                }
            }
        }
    }
}

//
//  Components.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/12/25.
//
