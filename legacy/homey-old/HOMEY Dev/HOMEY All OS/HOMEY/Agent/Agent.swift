// Agent.swift
// Swift model matching backend's AgentWithStats

import Foundation

struct Agent: Identifiable, Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let referrer_code: String
    let profile_image_url: String?
    let custom_message: String?
    let company: String?
    let city: String?
    let state: String?
    let active: Bool
    let client_count: Int
    let total_invites: Int?
    let conversion_rate: Double?
}