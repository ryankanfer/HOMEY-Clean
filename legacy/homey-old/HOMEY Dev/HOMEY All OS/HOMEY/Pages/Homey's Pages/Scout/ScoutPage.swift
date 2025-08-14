//
//  ScoutPage.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/10/25.
//


import SwiftUI

struct ScoutPage: View {
    let openMatches: () -> Void
    let openChat: () -> Void

    var body: some View {
        ScoutView(
            openMatches: openMatches,
            openChat: openChat
        )
       
    }
}
