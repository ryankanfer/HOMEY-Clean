import SwiftUI

// MARK: - WelcomeView (entry)

struct WelcomeView: View {
    @EnvironmentObject var session: SessionManager
    @State private var showSignup = false
    @State private var showLogin = false
    @State private var pageIndex = 0

    var body: some View {
        ZStack {
            AnimatedGradient() // your separate file handles this

            VStack(spacing: 20) {
                // Top copy
                VStack(spacing: 8) {
                    Text("Real Estate, Reimagined")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text(
                        "Real estate is a beast. We’re the team to tame it.\nHOMEY is your concierge-powered path to clarity."
                    )
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                }
                .padding(.top, 25)

                // Carousel with 3 pages
                TabView(selection: $pageIndex) {
                    MeetYourHomeysGrid()
                        .tag(0)
                        .padding(.horizontal, 16)
                        .frame(maxHeight: 520)

                    WhosItForSlide()
                        .tag(1)
                        .padding(.horizontal, 24)
                        .frame(maxHeight: 520)

                    FeaturesSlide()
                        .tag(2)
                        .padding(.horizontal, 24)
                        .frame(maxHeight: 520)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: pageIndex)

                // Navigation dots and left/right arrows
                HStack(spacing: 36) {
                    Button {
                        withAnimation(.spring()) {
                            pageIndex = max(pageIndex - 1, 0)
                        }
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(pageIndex == 0 ? .gray.opacity(0.5) : .blue)
                    }
                    .disabled(pageIndex == 0)

                    HStack(spacing: 8) {
                        ForEach(0 ..< 3) { idx in
                            Circle()
                                .fill(idx == pageIndex ? Color.blue : Color.gray.opacity(0.5))
                                .frame(width: 10, height: 10)
                        }
                    }

                    Button {
                        withAnimation(.spring()) {
                            pageIndex = min(pageIndex + 1, 2)
                        }
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(pageIndex == 2 ? .gray.opacity(0.5) : .blue)
                    }
                    .disabled(pageIndex == 2)
                }
                .padding(.vertical, 8)

                // Bottom CTAs
                VStack(spacing: 14) {
                    Button {
                        showSignup = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Get Started").font(.headline)
                            Image(systemName: "arrow.right").font(.headline)
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        )
                        .foregroundStyle(.white)
                        .shadow(radius: 6, y: 2)
                    }
                    .sheet(isPresented: $showSignup) {
                        CreateAccountView().environmentObject(session)
                    }

                    Button {
                        showLogin = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "person.circle")
                            Text("Login").font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .sheet(isPresented: $showLogin) {
                        LoginView().environmentObject(session)
                    }

                    Button {
                        withAnimation(.spring()) {
                            if pageIndex < 2 {
                                pageIndex += 1
                            }
                        }
                    } label: {
                        Text("Learn More")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                            .underline()
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 8)
            }
            .padding(.vertical, 12)
        }
        .ignoresSafeArea(edges: .top)
    }
}

private struct MeetYourHomeysGrid: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(HomeyKind.allCases) { homey in
                VStack(spacing: 8) {
                    Image(homey.assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .shadow(radius: 4, y: 2)

                    Text(homey.displayName) // <- was displayname
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

struct FocusedHomeyView: View {
    @Binding var index: Int?
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        let items = HomeyKind.allCases // <- use a local alias
        let count = items.count
        let idx = index ?? 0
        let homey = items[idx]

        VStack(spacing: 20) {
            Spacer(minLength: 44)
            VStack(spacing: 12) {
                Text(homey.displayTitle) // <- was displayname
                    .font(.title).bold()
                Text(homey.blurb)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))

            Image("\(homey.assetName)_wave")
                .resizable()
                .scaledToFit()
                .frame(height: 340)
                .shadow(radius: 18, y: 10)
                .padding(.bottom, 4)

            HStack(spacing: 40) {
                SwiftUI.Button(action: {
                    withAnimation(.spring()) {
                        index = (idx - 1 + count) % count
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill").font(.largeTitle)
                }

                SwiftUI.Button(action: {
                    withAnimation(.spring()) {
                        index = (idx + 1) % count
                    }
                }) {
                    Image(systemName: "arrow.right.circle.fill").font(.largeTitle)
                }
            }

            Spacer(minLength: 20)

            Button("Back to all HOMEYs") {
                withAnimation(.spring()) { index = nil }
            }
            .font(.callout.bold())
            .padding(.top, 12)
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { val, st, _ in st = val.translation.width }
                .onEnded { val in
                    if val.translation.width < -50 { index = (idx + 1) % count }
                    else if val.translation.width > 50 { index = (idx - 1 + count) % count }
                }
        )
    }
}

// MARK: - Slide 1: Meet Your HOMEYs

// Removed MeetYourHomeysSlide as per instructions

struct HomeyCard: View {
    let homey: HomeyKind
    let isExpanded: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(homey.assetName) // string-based image lookup
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)

            Text(homey.displayName)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(homey.displayName).font(.headline)
                    Text(homey.blurb)
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    TrianglePointer()
                        .fill(.thickMaterial)
                        .frame(width: 16, height: 12)
                        .offset(x: 24, y: 6)
                }
                .padding(.horizontal, 6)
                .offset(y: -6)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: isExpanded ? 260 : 160)
        .contentShape(Rectangle())
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isExpanded)
    }
}

// MARK: - Slide 2: Who’s It For?

struct WhosItForSlide: View {
    private let items: [(String, String)] = [
        ("house.fill", "Renters"),
        ("key.fill", "Buyers"),
        ("tag.fill", "Sellers"),
        ("building.2.fill", "Landlords"),
        ("person.2.fill", "Agents"),
    ]

    var body: some View {
        VStack(spacing: 14) {
            Text("Who’s It For?").font(.title2.bold())
            Text("Anyone who lives under a roof — and everyone who helps them.")
                .font(.footnote).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(items, id: \.1) { icon, label in
                    HStack(spacing: 12) {
                        Image(systemName: icon).font(.title3)
                        Text(label).font(.headline)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }
}

// MARK: - Slide 3: Features

struct FeaturesSlide: View {
    private let features: [(String, String, String)] = [
        ("sparkles", "AI Onboarding", "Quiz maps profile + goals"),
        ("exclamationmark.triangle.fill", "Reality Checks", "Feasibility + tradeoffs"),
        ("person.crop.circle", "Avatar Profiles", "Evolve via your data"),
        ("brain.head.profile", "Scenario Sims", "Practice key moments"),
        ("doc.text.fill", "Doc Retention", "Review + store files"),
        ("camera.viewfinder", "VR / AR Tours", "Immersive viewings"),
    ]

    var body: some View {
        VStack(spacing: 14) {
            Text("What You Get").font(.title2.bold())

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(features, id: \.1) { icon, title, sub in
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: icon).font(.title3)
                        Text(title).font(.headline)
                        Text(sub).font(.caption).foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }
}

// MARK: - Models & helpers

struct TrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: .init(x: rect.minX, y: rect.maxY))
        p.addLine(to: .init(x: rect.midX, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
