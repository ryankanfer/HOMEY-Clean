import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var savedListingIDs = Set<UUID>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // This should be replaced with the actual logged-in user's ID
    private var currentUserID: UUID? = UUID(uuidString: "your-user-id-here") // Replace with a real user ID for testing

    private let listingService = ListingService.shared
    
    func loadInitialData() {
        guard let userID = currentUserID else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        Task {
            do {
                self.listings = try await listingService.fetchListings()
                self.savedListingIDs = try await listingService.fetchSavedPropertyIDs(for: userID)
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func toggleSave(for listing: Listing) {
        guard let userID = currentUserID else { return }

        let isSaved = savedListingIDs.contains(listing.id)
        
        Task {
            do {
                if isSaved {
                    try await listingService.unsaveProperty(listingID: listing.id, userID: userID)
                    savedListingIDs.remove(listing.id)
                } else {
                    try await listingService.saveProperty(listingID: listing.id, userID: userID)
                    savedListingIDs.insert(listing.id)
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}