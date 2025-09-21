//
//  SmartDocClassifier.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//

import Foundation

struct SmartDocClassifier: DocClassifier {
    func classify(text: String) async -> DocCategory {
        let t = text.lowercased()

        // quick-n-dirty rules (you can swap for an LLM later)
        if t.contains(" w-2") || t.contains("w2") { return .w2 }
        if t.contains("1040") || t.contains("tax return") { return .taxReturn }
        if t.contains("bank statement") || t.contains("checking") || t.contains("savings") { return .bankStatement }
        if t.contains("reference") || t.contains("landlord reference") { return .reference }
        if t.contains("pay stub") || t.contains("paystub") { return .payStubs }
        if t.contains("driver") || t.contains("passport") || t.contains("id ") { return .id }
        if t.contains("lease") || t.contains("contract") || t.contains("rider") { return .lease }
        return .other
    }
}
