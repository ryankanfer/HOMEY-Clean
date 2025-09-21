//
//  OnboardingScreens.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/12/25.
//

import PhotosUI
import SwiftUI

// MARK: - Screen 1: Welcome & Referral

struct WelcomeReferralView: View {
    @Binding var data: OnboardingData
    @State private var error: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Let’s create your smart home profile.")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.top, 16)

            CardSection(title: "Referral / Agent Code") {
                TextField("Enter HOMEY123 if you don’t have one", text: $data.referralCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .padding(12)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(10)
                Text("Client codes begin with CL-, agent codes begin with RE-")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Spacer()

            PrimaryButton(title: "Continue") {
                let code = data.referralCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                guard !code.isEmpty else {
                    error = "Code is required."
                    return
                }
                error = nil
                // Rudimentary parse
                if code.hasPrefix("RE-") {
                    data.agentModeEnabled = true
                } else {
                    data.agentModeEnabled = false
                }
                // In your real app you might prefill email via code lookup; here we just move on.
                NotificationManager.shared.requestPermission()
            }
        }
        .padding(16)
    }
}

// MARK: - Screen 2: Role Selection

struct RoleSelectionView: View {
    @Binding var data: OnboardingData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Which best describes your journey?")
                .font(.title2.weight(.bold))

            VStack(spacing: 10) {
                roleRow(.renter)
                roleRow(.buyer)

                if data.agentModeEnabled {
                    roleRow(.landlord)
                    roleRow(.seller)
                } else {
                    roleRowDisabled(title: "Landlord (coming soon)")
                    roleRowDisabled(title: "Seller (coming soon)")
                }
            }

            Spacer()
        }
        .padding(16)
    }

    @ViewBuilder
    private func roleRow(_ role: UserRole) -> some View {
        Button {
            data.role = role
        } label: {
            HStack {
                Text(role.rawValue).font(.headline)
                Spacer()
                if data.role == role {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.accent)
                } else {
                    Image(systemName: "circle").foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private func roleRowDisabled(title: String) -> some View {
        HStack {
            Text(title).font(.headline).foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "lock.fill").foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Screen 3: Profile + First Property Details

struct ProfilePropertyView: View {
    @Binding var data: OnboardingData

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardSection(title: "Profile") {
                    TextField("Full Name", text: $data.fullName)
                        .textContentType(.name)
                        .padding(12).background(Color.secondary.opacity(0.08)).cornerRadius(10)

                    TextField("Email", text: $data.email)
                        .textContentType(.emailAddress).keyboardType(.emailAddress)
                        .padding(12).background(Color.secondary.opacity(0.08)).cornerRadius(10)

                    TextField("Phone", text: $data.phone)
                        .textContentType(.telephoneNumber).keyboardType(.phonePad)
                        .padding(12).background(Color.secondary.opacity(0.08)).cornerRadius(10)

                    AvatarPhotoPicker(selectedItem: $data.selectedPhoto, imageData: $data.selectedImageData)

                    Divider().opacity(0.2)

                    Text("Preferred contact method").font(.subheadline.weight(.semibold))
                    ContactMethodPicker(methods: $data.contactMethods)
                }

                CardSection(title: "Property Basics") {
                    Picker("City", selection: $data.city) {
                        ForEach(["New York City", "Los Angeles", "Chicago", "Miami"], id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }
                    .pickerStyle(.menu)

                    Text("Neighborhoods")
                        .font(.subheadline.weight(.semibold))
                    NeighborhoodSelector(
                        allNeighborhoods: neighborhoodsByCity[data.city] ?? [],
                        selected: $data.neighborhoods
                    )

                    Text("Property Type")
                        .font(.subheadline.weight(.semibold))
                    FlowWrap(data: cityPropertyTypes[data.city] ?? []) { item in
                        Chip(label: item, isSelected: data.propertyTypes.contains(item)) {
                            if data.propertyTypes.contains(item) { data.propertyTypes.remove(item) }
                            else { data.propertyTypes.insert(item) }
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

// Simple wrapping layout for chips
struct FlowWrap<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let content: (Data.Element) -> Content
    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        let lastElement = data.last

        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { element in
                content(element)
                    .padding(.trailing, 8)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > g.size.width {
                            width = 0
                            height -= d.height + 8
                        }
                        let result = width
                        if element == lastElement {
                            width = 0
                        } else {
                            width -= d.width + 8
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if element == lastElement {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async { binding.wrappedValue = geo.size.height }
            return Color.clear
        }
    }
}
