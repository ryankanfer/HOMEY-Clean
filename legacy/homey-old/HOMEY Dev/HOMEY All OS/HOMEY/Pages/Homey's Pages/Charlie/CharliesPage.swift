//
//  CharliesPage.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/10/25.
//

import SwiftUI

struct CharliesPage: View {
    let stations: [String]
    let currentIndex: Int
    let openChat: () -> Void

    var body: some View {
        CharliesCorner(
            openChat: { /* open chat */ }
        )
    }
}
