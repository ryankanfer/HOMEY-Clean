import SwiftUI

struct PaigeDashboard: View {
    @State private var selectedVault: DocumentVault?
    @State private var showVaultDetail = false
    @State private var scannerRotation: Double = 0
    @State private var scannerPulse = false
    @State private var showUploadSheet = false

    let vaults = DocumentVault.sampleVaults

    var body: some View {
        ZStack {
            // Deep slate gray/charcoal gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.18), // Deep slate gray
                    Color(red: 0.12, green: 0.12, blue: 0.15), // Charcoal
                    Color(red: 0.10, green: 0.10, blue: 0.12)  // Darker charcoal
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Linen texture overlay
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.015),
                            Color.clear,
                            Color.white.opacity(0.008)
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: 300
                    )
                )
                .ignoresSafeArea()
                .blendMode(.overlay)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        HeroVideoView(
                            character: .paige,
                            title: "Paige says Hi",
                            subtitle: "Your HOMEY Teammate",
                            onContinue: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo("paige.contentStart", anchor: .top)
                                }
                            }
                        )

                        Color.clear
                            .frame(height: 1)
                            .id("paige.contentStart")

                        VStack(spacing: 30) {
                            // Header Section
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Document Vault")
                                            .font(.custom("JosefinSans-Bold", size: 32))
                                            .foregroundColor(.white)

                                        Text("Secure • Organized • Accessible")
                                            .font(.custom("PlayfairDisplay-Regular", size: 16))
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    CircularScannerView(
                                        rotation: $scannerRotation,
                                        pulse: $scannerPulse
                                    )
                                }
                                .padding(.horizontal, Spacing.xl)
                                .padding(.top, Spacing.lg)

                                VaultProgressView(vaults: vaults)
                                    .padding(.horizontal, Spacing.xl)
                            }

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 24)
                            ], spacing: 20) {
                                ForEach(vaults) { vault in
                                    VaultShelfView(vault: vault) {
                                        selectedVault = vault
                                        showVaultDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.xl)

                            VStack(spacing: 16) {
                                Text("Quick Actions")
                                    .font(.custom("JosefinSans-SemiBold", size: 20))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack(spacing: 16) {
                                    QuickActionButton(
                                        icon: "plus.circle.fill",
                                        title: "Upload Document",
                                        color: .blue
                                    ) {
                                        showUploadSheet = true
                                    }

                                    QuickActionButton(
                                        icon: "doc.viewfinder.fill",
                                        title: "Scan Document",
                                        color: .green
                                    ) { }
                                }

                                HStack(spacing: 16) {
                                    QuickActionButton(
                                        icon: "square.and.arrow.up.fill",
                                        title: "Export All",
                                        color: .purple
                                    ) { }

                                    QuickActionButton(
                                        icon: "lock.shield.fill",
                                        title: "Security Settings",
                                        color: .orange
                                    ) { }
                                }
                            }
                            .padding(.horizontal, Spacing.xl)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
        .onAppear {
            startScannerAnimation()
        }
        .sheet(isPresented: $showVaultDetail) {
            if let vault = selectedVault {
                VaultDetailSheet(vault: vault, isPresented: $showVaultDetail)
            }
        }
        .sheet(isPresented: $showUploadSheet) {
            DocumentUploadSheet(isPresented: $showUploadSheet)
        }
    }

    private func startScannerAnimation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            scannerRotation = 360
        }

        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            scannerPulse.toggle()
        }
    }
}

// MARK: - Circular Scanner View

struct CircularScannerView: View {
    @Binding var rotation: Double
    @Binding var pulse: Bool

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.cyan.opacity(0.3), .blue.opacity(0.6), .cyan.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 80, height: 80)
                .scaleEffect(pulse ? 1.1 : 1.0)

            // Inner scanner beam
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    LinearGradient(
                        colors: [.clear, .cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotation))

            // Center icon
            Image(systemName: "doc.viewfinder")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.cyan)
        }
    }
}

// MARK: - Vault Progress View

struct VaultProgressView: View {
    let vaults: [DocumentVault]
    
    // HOMEY neutral colors
    private let homeyMint = Color(red: 0.6, green: 0.8, blue: 0.7)
    private let homeySage = Color(red: 0.7, green: 0.8, blue: 0.7)

    private var overallProgress: Double {
        let totalProgress = vaults.reduce(0) { $0 + $1.completionPercentage }
        return totalProgress / Double(vaults.count)
    }

    private var completedVaults: Int {
        vaults.filter { $0.completionPercentage >= 0.8 }.count
    }
    
    private var allVaultsCompleted: Bool {
        vaults.allSatisfy { $0.completionPercentage >= 1.0 }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Paige's avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [homeyMint, homeySage],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("P")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    // Paige's friendly message
                    Text("\(Int(overallProgress * 100))% done — \(allVaultsCompleted ? "All set! 🎉" : "just a few more docs.")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("\(Int(overallProgress * 100))%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(homeyMint)
            }

            // Progress bar with softer colors
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [homeyMint, homeySage],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * overallProgress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            // Generate Package button (appears when all vaults are completed)
            if allVaultsCompleted {
                Button(action: {
                    // Generate package action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Generate Package")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [homeyMint, homeySage],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: allVaultsCompleted)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            homeyMint.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Vault Shelf View

struct VaultShelfView: View {
    let vault: DocumentVault
    let onTap: () -> Void
    @State private var isPressed = false
    @State private var showCheckmark = false
    
    private var isCompleted: Bool {
        vault.completionPercentage >= 1.0
    }
    
    private var completedDocs: Int {
        vault.documents.filter { $0.status == .uploaded || $0.status == .verified }.count
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPressed = false
                }
            }
            
            if isCompleted {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showCheckmark = true
                }
            }
            
            onTap()
        }) {
            HStack(spacing: 12) {
                // Icon with progress ring
                ZStack {
                    // Progress ring background
                    Circle()
                        .stroke(vault.color.opacity(0.2), lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: vault.completionPercentage)
                        .stroke(
                            vault.color,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    
                    // Icon background with subtle glow
                    Circle()
                        .fill(vault.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .shadow(color: vault.color.opacity(0.3), radius: 4, x: 0, y: 0)
                    
                    // Icon or checkmark
                    if isCompleted && showCheckmark {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: vault.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(vault.color)
                    }
                    
                    if vault.isLocked {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.red)
                                    .background(
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 14, height: 14)
                                    )
                            }
                        }
                        .frame(width: 44, height: 44)
                    }
                }
                
                // Vault info
                VStack(alignment: .leading, spacing: 4) {
                    Text(vault.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Progress label underneath
                    Text("\(Int(vault.completionPercentage * 100))% • \(completedDocs)/\(vault.documents.count) docs")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20) // Pill shape
                    .fill(
                        LinearGradient(
                            colors: [
                                vault.color.opacity(0.08),
                                vault.color.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                vault.color.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: vault.color.opacity(isPressed ? 0.4 : 0.2),
                        radius: isPressed ? 8 : 4,
                        x: 0,
                        y: 2
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isCompleted {
                showCheckmark = true
            }
        }
    }
}

#Preview {
    PaigeDashboard()
}