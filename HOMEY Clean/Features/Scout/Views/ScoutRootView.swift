import SwiftUI
import CoreLocation

struct ScoutRootView: View {
    @State private var viewModel = ScoutViewModel()
    @State private var showingFullSheet = false
    @State private var showingHoloMap = false
    @State private var isSearchFocused = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    // Immersive Hero Banner - Edge to Edge
                    HeroVideoView(
                        character: .scout,
                        title: "Scout says Hi",
                        subtitle: "Your HOMEY Teammate",
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("scout.contentStart", anchor: .top)
                            }
                        }
                    )
                    
                    // Anchor for hero continue action
                    Color.clear
                        .frame(height: 1)
                        .id("scout.contentStart")
                    
                    VStack(spacing: 32) {
                        // Main hero view with panorama and lens
                        ZStack(alignment: .topTrailing) {
                            ScoutHeroView(viewModel: viewModel)
                                .frame(height: 420)
                                .padding(.top, 24)
                            
                            // AR Navigation Menu
                            ARNavigationMenu(selectedListing: viewModel.selectedListing)
                                .padding(.top, 40)
                                .padding(.trailing, 24)
                        }

                        ScoutSearchBar(
                            searchText: $viewModel.searchQuery,
                            isSearchFocused: $isSearchFocused
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        // Charlie's Update Box
                        CharlieUpdateBox()
                            .padding(.horizontal, 24)

                        // AR Feature Discovery Card
                        ARFeatureDiscoveryCard()
                            .padding(.horizontal, 24)

                        if isSearchFocused {
                            ScoutLensTray(viewModel: viewModel)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 20)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        SwipeablePropertyStack(viewModel: viewModel)
                            .padding(.horizontal, 24)

                        // Additional content space
                        Spacer(minLength: 240)
                    }
                }
            }
        }
        .sheet(isPresented: $showingFullSheet) {
            FullSheetView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingHoloMap) {
            HoloMapView(viewModel: viewModel)
        }
        .onChange(of: viewModel.selectedListing) { _, newListing in
            if newListing != nil {
                showingFullSheet = true
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

#Preview {
    ScoutRootView()
}