//
//  EducationCenterStoreMock.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/11/25.
//


// EducationCenterStoreMock.swift  (DEBUG-only mock; rename from any duplicate “real” file)
#if DEBUG
import Foundation
import Combine

@MainActor
final class EducationCenterStoreMock: ObservableObject {
    @Published var items: [String] = ["Preview A", "Preview B"]
}
#endif