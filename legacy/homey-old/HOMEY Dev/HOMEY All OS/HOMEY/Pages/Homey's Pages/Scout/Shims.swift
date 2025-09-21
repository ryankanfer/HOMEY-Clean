//
//  Shims.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//

import SwiftUI

// ——— Simple UI helpers so your Scout screen compiles. Replace with your real components later.

struct MenuIconRow: View {
    var bell: () -> Void = {}
    var gear: () -> Void = {}
    var more: () -> Void = {}
    var body: some View {
        HStack(spacing: 12) {
            Button(action: bell) { Image(systemName: "bell") }
            Button(action: gear) { Image(systemName: "gearshape") }
            Button(action: more) { Image(systemName: "ellipsis.circle") }
        }
    }
}

struct FooterHomeysBar: View {
    var selected: HomeyKind = .charlie
    var longPressChat: () -> Void = {}
    var body: some View {
        HStack { Spacer(); Text("Homeys").font(.footnote); Spacer() }
            .padding(.vertical, 10)
    }
}

struct AskCharlieButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Ask Charlie").fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
}
