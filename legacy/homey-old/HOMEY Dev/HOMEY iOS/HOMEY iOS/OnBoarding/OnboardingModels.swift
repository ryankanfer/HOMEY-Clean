//
//  OnboardingModels.swift
//  HOMEY
//
//  Created by Ryan Kanfer on 8/12/25.
//

import SwiftUI
import PhotosUI
import UserNotifications

// MARK: - Roles
enum UserRole: String, CaseIterable, Identifiable {
    case renter = "Renter"
    case buyer = "Buyer"
    case landlord = "Landlord"
    case seller = "Seller"
    var id: String { rawValue }
}

// MARK: - Contact Methods
struct ContactMethod: OptionSet {
    let rawValue: Int
    static let text  = ContactMethod(rawValue: 1 << 0)
    static let call  = ContactMethod(rawValue: 1 << 1)
    static let email = ContactMethod(rawValue: 1 << 2)
    static let inApp = ContactMethod(rawValue: 1 << 3)
}

// MARK: - Property Types by City (simple MVP map)
let cityPropertyTypes: [String: [String]] = [
    "New York City": ["Co-op", "Condo", "Townhouse", "Rental Building"],
    "Los Angeles":   ["Apartment", "House", "Townhouse", "Condo"],
    "Chicago":       ["Condo", "Apartment", "House", "Townhouse"],
    "Miami":         ["Condo", "Apartment", "House", "Townhouse"]
]

// MARK: - Neighborhood seeds (MVP; expand later)
let neighborhoodsByCity: [String: [String]] = [
    "New York City": ["Chelsea", "Tribeca", "Soho", "Upper East Side", "Brooklyn Heights", "West Village", "Astoria"],
    "Los Angeles":   ["Silver Lake", "Hollywood", "Venice", "Santa Monica", "Echo Park"],
    "Chicago":       ["Lincoln Park", "Wicker Park", "River North", "Gold Coast"],
    "Miami":         ["Brickell", "Wynwood", "South Beach", "Coconut Grove"]
]

// MARK: - Must-haves (MVP)
struct MustHaves: OptionSet {
    let rawValue: Int
    static let pets        = MustHaves(rawValue: 1 << 0)
    static let laundry     = MustHaves(rawValue: 1 << 1)
    static let outdoor     = MustHaves(rawValue: 1 << 2)
    static let elevator    = MustHaves(rawValue: 1 << 3)
    static let doorman     = MustHaves(rawValue: 1 << 4)
    static let walkUpOK    = MustHaves(rawValue: 1 << 5) // not a must-have, but tolerance flag
}

// MARK: - Onboarding Data
struct OnboardingData {
    // Screen 1
    var referralCode: String = ""

    // Screen 2
    var role: UserRole? = nil
    var agentModeEnabled: Bool = false // set true if referral is RE-

    // Screen 3
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var city: String = "New York City"
    var neighborhoods: Set<String> = []
    var propertyTypes: Set<String> = []
    var contactMethods: ContactMethod = [.text, .inApp]
    var selectedPhoto: PhotosPickerItem? = nil
    var selectedImageData: Data? = nil // used to show preview; avatar gen async later

    // Screen 4 (renters)
    var monthlyRentBudget: Int? = nil
    var renterAnnualIncome: Int? = nil
    var hasGuarantor: Bool = false
    var guarantorAnnualIncome: Int? = nil

    // Screen 4 (buyers)
    var totalBuyBudget: Int? = nil
    var isPreApproved: Bool? = nil
    var firstTimeBuyer: Bool? = nil

    // Screen 5
    var mustHaves: MustHaves = []
}

// MARK: - Notification Manager for 24h Charlie nudge
import UserNotifications

import UserNotifications

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()   // no 'nonisolated' needed

    private override init() { super.init() }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        UNUserNotificationCenter.current().delegate = self
    }

    func schedule24hNudge(name: String) {
        let content = UNMutableNotificationContent()
        content.title = "Charlie’s Corner"
        content.body = "Hey \(name.isEmpty ? "there" : name), we’re ready to unlock matches — add your timeline and must-haves to finish setup."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*60*24, repeats: false)
        let req = UNNotificationRequest(identifier: "charlie_24h_nudge", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }

    // This delegate requirement is **nonisolated**:
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
}

// MARK: - Lightweight Lottie stub (safe with or without library)
struct LottieCheck: View {
    var body: some View {
        ZStack {
            Circle().fill(.green.opacity(0.15))
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.green)
        }
        .frame(width: 160, height: 160)
        .accessibilityLabel("Completed")
        .transition(.scale.combined(with: .opacity))
    }
}
