//
//  CTAButton.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/8/25.
//

import SwiftUI

struct CTAButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    init(_ title: String, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
        }
        .buttonStyle(.borderedProminent)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
