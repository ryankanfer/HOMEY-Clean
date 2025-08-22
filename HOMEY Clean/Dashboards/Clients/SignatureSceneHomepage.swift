import SwiftUI

struct SignatureSceneHomepage: View {
    @State private var showUploadDocs = false
    @State private var showNeighborhoods = false
    @State private var showMarketPulse = false
    @State private var showSmartPicks = false
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Hero background with homepage_bg_day
                Image("homepage_bg_day")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()

                // Animated sky overlay for upper third
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.1),
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: geometry.size.height / 3)
                        .mask(
                            // Animated cloud-like shapes
                            HStack(spacing: -50) {
                                ForEach(0 ..< 5, id: \.self) { index in
                                    Circle()
                                        .frame(width: 120, height: 60)
                                        .offset(x: animationOffset + CGFloat(index * 100))
                                }
                            }
                            .blur(radius: 20)
                        )
                        .animation(
                            Animation.linear(duration: 20)
                                .repeatForever(autoreverses: false),
                            value: animationOffset
                        )

                    Spacer()
                }
                .ignoresSafeArea()
                .onAppear {
                    animationOffset = geometry.size.width + 200
                }

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

                        // Character assembly without Charlie label
                        Image("character-group")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .padding(.horizontal, 24)

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
                        SmartAIBox()
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                    }

                    Spacer(minLength: 120) // Extra space for navigation footer
                }
            }
        }
        .sheet(isPresented: $showUploadDocs) {
            NavigationView {
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
            NavigationView {
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
            NavigationView {
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
            NavigationView {
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

struct IOSNativeFooter: View {
    @Binding var selectedTab: NavigationTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(NavigationTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))

                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.8),
                            Color.black.opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            Color.white.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }
}

// NavigationTab enum is now defined in GlassNavigationFooter.swift

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
