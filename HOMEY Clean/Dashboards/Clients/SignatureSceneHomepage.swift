import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SignatureSceneHomepage: View {
    @State private var showUploadDocs = false
    @State private var showNeighborhoods = false
    @State private var showMarketPulse = false
    @State private var showSmartPicks = false
    @State private var animationOffset: CGFloat = 0

    // Prefer the new Homeys silhouette image if available; fallback to existing group art
    private func groupImage() -> Image {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: "silhoutte_group") ?? UIImage(named: "silhouette_group") {
            return Image(uiImage: uiImage)
        }
        #endif
        return Image("character-group")
    }

    private func isSilhouetteAvailable() -> Bool {
        #if canImport(UIKit)
        return UIImage(named: "silhoutte_group") != nil || UIImage(named: "silhouette_group") != nil
        #else
        return false
        #endif
    }

    private func backgroundImage() -> Image {
        #if canImport(UIKit)
        if let uiImage = UIImage(named: "silhoutte_group") ?? UIImage(named: "silhouette_group") {
            return Image(uiImage: uiImage)
        }
        #endif
        return Image("homepage_bg_day")
    }

    private enum HomeTimePhase {
        case day, sunset, night
    }
    @State private var timePhase: HomeTimePhase = .day

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Hero background with homepage_bg_day
                backgroundImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .offset(y: -24)

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(timeOfDayGradient())
                        // bleed more down: from 33% to ~55%
                        .frame(height: geometry.size.height * 0.55)
                        .mask(
                            LinearGradient(
                                colors: [
                                    Color.white,                      // full at top
                                    Color.white.opacity(0.85),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.0)          // feather out at bottom
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            // Gentle animated cloud bands to add motion
                            HStack(spacing: -50) {
                                ForEach(0 ..< 5, id: \.self) { index in
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 140, height: 70)
                                        .offset(x: animationOffset + CGFloat(index * 120))
                                }
                            }
                            .blur(radius: 24)
                        )
                        .animation(
                            Animation.linear(duration: 28)
                                .repeatForever(autoreverses: false),
                            value: animationOffset
                        )

                    Spacer()
                }
                .ignoresSafeArea()
                .onAppear {
                    animationOffset = geometry.size.width + 240
                    timePhase = currentTimePhase()
                }

                // Subtle bottom gradient for readability
                LinearGradient(
                    colors: [Color.black.opacity(0.35), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()

                // Main content
                VStack(spacing: 0) {
                    // Top section with greeting and characters
                    VStack(spacing: 20) {
                        // Greeting header - centered with proper fonts
                        VStack(spacing: 8) {
                            Text("Welcome home.")
                                .font(.custom("PlayfairDisplay-Regular", size: 32))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("Ready for your next step?")
                                .font(.custom("Lato-Regular", size: 18))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.top, 60)

                        // Character assembly shown only if silhouette background is not available
                        if !isSilhouetteAvailable() {
                            Image("character-group")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(y: -8)
                                .frame(height: 200)
                                .padding(.horizontal, 24)
                        }

                        Spacer(minLength: 40)
                    }

                    // Glass morphism cards section - smaller with 3D effects
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            GlassMorphismCard(
                                icon: "doc.fill",
                                title: "Upload Docs"
                            ) { showUploadDocs = true }

                            GlassMorphismCard(
                                icon: "map.fill",
                                title: "View Your\nJourney"
                            ) { /* Navigate to Charlie's dashboard */ }

                            GlassMorphismCard(
                                icon: "house.fill",
                                title: "Search For\nHomes"
                            ) { /* Navigate to Scout's room */ }
                        }
                        .padding(.horizontal, 32)

                        // Smart AI Box - pinned above nav footer
                        // Smart AI Recommendations Section
                        VStack(spacing: 12) {
                            SmartAIBox(context: .dashboard)
                                .padding(.horizontal, 24)
                            
                            // Featured recommendation card
                            SmartRecommendationView(
                                recommendation: SmartRecommendation(
                                    title: "Perfect Timing for Pre-Approval",
                                    subtitle: "Interest rates dropped 0.2% this week - secure your pre-approval now",
                                    type: .financial,
                                    context: .dashboard,
                                    priority: .high,
                                    aiAvatar: .charlie,
                                    actionTitle: "Get Pre-Approved",
                                    insights: ["Rates at 6-month low", "Save $200/month on payments", "Lock in rate for 90 days"]
                                )
                            )
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 16)
                    }

                    Spacer(minLength: 120) // Extra space for navigation footer
                }
            }
        }
        .sheet(isPresented: $showUploadDocs) {
            NavigationStack {
                UploadDocsView()
                    .navigationTitle("Upload Documents")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showUploadDocs = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showNeighborhoods) {
            NavigationStack {
                NeighborhoodsView()
                    .navigationTitle("Explore Neighborhoods")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showNeighborhoods = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showMarketPulse) {
            NavigationStack {
                MarketPulseView()
                    .navigationTitle("Market Pulse")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showMarketPulse = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showSmartPicks) {
            NavigationStack {
                SmartPicksDetailView()
                    .navigationTitle("Viza's Smart Picks")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showSmartPicks = false
                            }
                        }
                    }
            }
        }
    }

    private func currentTimePhase() -> HomeTimePhase {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<16: return .day
        case 16..<20: return .sunset
        default: return .night
        }
    }

    private func timeOfDayGradient() -> LinearGradient {
        switch timePhase {
        case .day:
            return LinearGradient(
                colors: [
                    Color(red: 0.65, green: 0.83, blue: 1.0).opacity(0.65), // airy sky
                    Color(red: 0.80, green: 0.90, blue: 1.0).opacity(0.45),
                    Color.white.opacity(0.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .sunset:
            return LinearGradient(
                colors: [
                    Color.orange.opacity(0.65),
                    Color.pink.opacity(0.45),
                    Color.purple.opacity(0.25),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .night:
            return LinearGradient(
                colors: [
                    Color.indigo.opacity(0.7),
                    Color.blue.opacity(0.5),
                    Color.black.opacity(0.2),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

struct GlassMorphismCard: View {
    let icon: String
    let title: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                ZStack {
                    // Base glass layer
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Inner highlight for depth
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )

                    // Outer border for definition
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            Color.black.opacity(0.1),
                            lineWidth: 0.5
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct SmartPicksSection: View {
    @Binding var showSmartPicks: Bool
    let currentJourney: JourneyStage

    var body: some View {
        Button(action: {
            showSmartPicks = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Viza's Smart Picks")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    Text(currentJourney.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views for Navigation

struct UploadDocsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Upload Documents")
                .font(.title2.weight(.semibold))

            Text("Upload your important documents here to get started with your home journey.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button("Choose Files") {
                // File picker action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct NeighborhoodsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Explore Neighborhoods")
                .font(.title2.weight(.semibold))

            Text("Discover the perfect neighborhood for your new home with detailed insights and local information.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button("Start Exploring") {
                // Navigation action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct MarketPulseView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Market Pulse")
                .font(.title2.weight(.semibold))

            Text(
                "Stay updated with the latest market trends, pricing insights, and investment opportunities in your area."
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.horizontal)

            Button("View Market Data") {
                // Market data action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct SmartPicksDetailView: View {
    let currentJourney: JourneyStage = .exploring

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text(currentJourney.smartPicksTitle)
                .font(.title2.weight(.semibold))

            Text(currentJourney.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(currentJourney.smartPicksItems, id: \.self) { item in
                    SmartPickRow(title: item, icon: "star.circle")
                }
            }
            .padding()
        }
        .padding()
    }
}

struct SmartPickRow: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(title)
                .font(.body)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}