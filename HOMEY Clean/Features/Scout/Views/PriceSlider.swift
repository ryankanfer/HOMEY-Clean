//
//  PriceSlider.swift
//  HOMEY Clean
//
//  A price range slider component for filtering listings
//

import SwiftUI

struct PriceSlider: View {
    @Binding var range: ClosedRange<Double>

    private let minPrice: Double = 0
    private let maxPrice: Double = 15000

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Price Range")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("$\(Int(range.lowerBound)) - $\(Int(range.upperBound))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            // Custom range slider implementation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)

                    // Active range
                    Rectangle()
                        .fill(Color.white)
                        .frame(
                            width: geometry.size
                                .width * CGFloat((range.upperBound - range.lowerBound) / (maxPrice - minPrice)),
                            height: 4
                        )
                        .cornerRadius(2)
                        .offset(x: geometry.size.width * CGFloat((range.lowerBound - minPrice) / (maxPrice - minPrice)))

                    // Lower bound thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(x: geometry.size
                            .width * CGFloat((range.lowerBound - minPrice) / (maxPrice - minPrice)) - 10
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newValue = minPrice + (maxPrice - minPrice) *
                                        Double(value.location.x / geometry.size.width)
                                    let clampedValue = max(minPrice, min(range.upperBound - 100, newValue))
                                    range = clampedValue ... range.upperBound
                                }
                        )

                    // Upper bound thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(x: geometry.size
                            .width * CGFloat((range.upperBound - minPrice) / (maxPrice - minPrice)) - 10
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newValue = minPrice + (maxPrice - minPrice) *
                                        Double(value.location.x / geometry.size.width)
                                    let clampedValue = max(range.lowerBound + 100, min(maxPrice, newValue))
                                    range = range.lowerBound ... clampedValue
                                }
                        )
                }
            }
            .frame(height: 20)

            // Price labels
            HStack {
                Text("$\(Int(minPrice))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Text("$\(Int(maxPrice))+")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

#Preview {
    PriceSlider(range: .constant(2000 ... 8000))
        .padding()
        .background(Color.blue)
}
