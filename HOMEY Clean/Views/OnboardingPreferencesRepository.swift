import Foundation
#if canImport(Supabase)
import Supabase
#endif

/// A minimal repository used during onboarding to capture and persist early user preferences
/// without coupling the flow tightly to backend availability.
@MainActor
final class OnboardingPreferencesRepository {
    private let reference: AppSessionManager
    private let defaults = UserDefaults.standard
    private let geoKey = "onboarding_geographic_focus"

    #if canImport(Supabase)
    private let preferencesRepo: PreferencesRepository
    #endif

    /// Current geographic focus (e.g., selected city names)
    /// Setting this value persists it locally and attempts to sync to the backend when possible.
    var geographicFocus: [String] {
        didSet {
            persistLocally()
            Task { await syncRemoteIfPossible() }
        }
    }

    init(reference: AppSessionManager) {
        self.reference = reference
        self.geographicFocus = defaults.stringArray(forKey: geoKey) ?? []
        #if canImport(Supabase)
        // Initialize using the active Supabase client from the session manager
        self.preferencesRepo = PreferencesRepository(client: reference.supabaseClient)
        #endif
    }

    // MARK: - Persistence

    private func persistLocally() {
        defaults.set(geographicFocus, forKey: geoKey)
        #if DEBUG
        print("[OnboardingPreferencesRepository] Saved geographicFocus locally: \(geographicFocus)")
        #endif
    }

    @MainActor
    private func syncRemoteIfPossible() async {
        #if canImport(Supabase)
        do {
            // Prepare a partial update with neighborhoods only
            let update = PreferencesUpdateRequest(
                budget: nil,
                neighborhoods: geographicFocus,
                bedrooms: nil,
                bathrooms: nil,
                pets: nil,
                timing: nil,
                propertyTypes: nil,
                mustHaves: nil,
                dealBreakers: nil
            )
            _ = try await preferencesRepo.updatePreferences(update)
            #if DEBUG
            print("[OnboardingPreferencesRepository] Synced neighborhoods to backend: \(geographicFocus)")
            #endif
        } catch {
            #if DEBUG
            print("[OnboardingPreferencesRepository] Backend sync failed: \(error.localizedDescription)")
            #endif
        }
        #else
        // No-op on platforms/targets without Supabase
        #endif
    }
}

