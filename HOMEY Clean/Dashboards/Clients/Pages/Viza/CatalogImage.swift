//
//  CatalogImage.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

import SwiftUI

struct CatalogImage: View {
    let name: String
    var body: some View {
        if UIImage(named: name) != nil {
            Image(name).resizable().scaledToFill()
        } else {
            Image(systemName: "photo")
                .resizable().scaledToFit().padding(24)
                .foregroundStyle(.secondary)
                .background(.ultraThinMaterial)
        }
    }
}
