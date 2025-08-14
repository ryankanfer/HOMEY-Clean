//
//  DocCategory.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//


import Foundation

enum DocCategory: String, CaseIterable, Codable, Sendable {
    case w2            = "W-2"
    case taxReturn     = "1040 / Tax Return"
    case bankStatement = "Bank Statement"
    case reference     = "Reference Letter"
    case payStubs      = "Pay Stubs"
    case id            = "Government ID"
    case lease         = "Lease / Contract"
    case other         = "Other"
}

protocol DocClassifier: Sendable {
    func classify(text: String) async -> DocCategory
}