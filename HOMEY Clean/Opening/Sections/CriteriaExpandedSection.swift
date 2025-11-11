import SwiftUI

struct CriteriaExpandedSection: View {
    @Binding var filters: LocalSearchFilters
    @Binding var query: String
    var onCollapse: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search criteria")
                .font(.headline)

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    criteriaField(title: "Bedrooms", placeholder: "2", text: Binding(
                        get: { filters.minBeds.map(String.init) ?? "" },
                        set: { filters.minBeds = Int($0) }
                    ))
                    criteriaField(title: "Bathrooms", placeholder: "1", text: Binding(
                        get: { filters.minBaths.map(String.init) ?? "" },
                        set: { filters.minBaths = Int($0) }
                    ))
                }

                HStack(spacing: 12) {
                    criteriaField(title: "Min price", placeholder: "$1M", text: Binding(
                        get: { filters.minPrice.map(SearchBrief.k) ?? "" },
                        set: { filters.minPrice = SearchBrief.parseMoneyToken($0) }
                    ))
                    criteriaField(title: "Max price", placeholder: "$2M", text: Binding(
                        get: { filters.maxPrice.map(SearchBrief.k) ?? "" },
                        set: { filters.maxPrice = SearchBrief.parseMoneyToken($0) }
                    ))
                }

                criteriaField(title: "Neighborhoods", placeholder: "SoHo, Williamsburg…", text: Binding(
                    get: { filters.neighborhood ?? "" },
                    set: { filters.neighborhood = $0.isEmpty ? nil : $0 }
                ))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Market")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("Market", selection: Binding<Int>(
                        get: { filters.isRent == nil ? -1 : (filters.isRent! ? 1 : 0) },
                        set: { v in
                            if v == -1 { filters.isRent = nil } else { filters.isRent = (v == 1) }
                        }
                    )) {
                        Text("Auto").tag(-1)
                        Text("Rent").tag(1)
                        Text("Buy").tag(0)
                    }
                    .pickerStyle(.segmented)
                    Text("Auto chooses Rent/Buy based on price.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Amenities")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(filters.amenities).sorted(), id: \.self) { a in
                                AIPrefButton(text: a) {
                                    _ = filters.amenities.remove(a)
                                }
                            }
                            let suggestions = SearchBrief.suggestedAmenities(from: query, existing: filters.amenities)
                            ForEach(suggestions, id: \.self) { a in
                                AIPrefButton(text: a) {
                                    filters.amenities.insert(a)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.2)))

            Button {
                onCollapse()
            } label: {
                HStack(spacing: 8) {
                    Text("Collapse")
                    Image(systemName: "chevron.up")
                        .font(.footnote.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.primaryAction.opacity(0.35))
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.primaryAction)
        }
    }

    private func criteriaField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2)))
                .keyboardType(.numbersAndPunctuation)
        }
        .frame(maxWidth: .infinity)
    }
}