//
//  PaigesPage.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/10/25.
//


import SwiftUI

struct PaigesPage: View {
    let openChat: () -> Void
    let openDocuments: () -> Void

    var body: some View {
        PaigesPlace(
            openChat: openChat,
            openDocuments: openDocuments
        )
       
    }
}
