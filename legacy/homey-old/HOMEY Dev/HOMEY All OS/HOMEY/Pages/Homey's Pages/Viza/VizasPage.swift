//
//  VizasPage.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/10/25.
//

import SwiftUI

struct VizasPage: View {
    let openChat: () -> Void
    let showAR: () -> Void
    let uploadPhoto: () -> Void

    var body: some View {
        VizasVision(
            openChat: openChat,
            showAR: showAR,
            uploadPhoto: uploadPhoto
        )
    }
}
