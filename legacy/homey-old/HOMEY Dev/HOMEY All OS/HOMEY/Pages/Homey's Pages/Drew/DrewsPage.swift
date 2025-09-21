//
//  DrewsPage.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/10/25.
//

import SwiftUI

struct DrewsPage: View {
    let openChat: () -> Void

    var body: some View {
        DrewsDirectory(openChat: openChat)
    }
}
