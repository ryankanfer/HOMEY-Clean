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
            // Background with subtle gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.9),
                    Color.gray.opacity(0.1),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Film grain texture overlay
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.02),
                            Color.clear,
                            Color.white.opacity(0.01)
                        ],
                        center: .center,
                        startRadius: 100,
                        endRadius: 400
                    )
                )
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // Header Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Document Vault")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Text("Secure • Organized • Accessible")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // Circular Scanner
                            CircularScannerView(
                                rotation: $scannerRotation,
                                pulse: $scannerPulse
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        // Overall Progress
                        VaultProgressView(vaults: vaults)
                            .padding(.horizontal, 24)
                    }

                    // Document Vaults Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 20) {
                        ForEach(vaults) { vault in
                            VaultShelfView(vault: vault) {
                                selectedVault = vault
                                showVaultDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Quick Actions
                    VStack(spacing: 16) {
                        Text("Quick Actions")
                            .font(.system(size: 20, weight: .semibold))
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
                            ) {
                                // Scan action
                            }
                        }

                        HStack(spacing: 16) {
                            QuickActionButton(
                                icon: "square.and.arrow.up.fill",
                                title: "Export All",
                                color: .purple
                            ) {
                                // Export action
                            }

                            QuickActionButton(
                                icon: "lock.shield.fill",
                                title: "Security Settings",
                                color: .orange
                            ) {
                                // Security action
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // Space for navigation footer
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

    private var overallProgress: Double {
        let totalProgress = vaults.reduce(0) { $0 + $1.completionPercentage }
        return totalProgress / Double(vaults.count)
    }

    private var completedVaults: Int {
        vaults.filter { $0.completionPercentage >= 0.8 }.count
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text("\(completedVaults)/\(vaults.count) vaults complete")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("\(Int(overallProgress * 100))%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * overallProgress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Vault Shelf View

struct VaultShelfView: View {
    let vault: DocumentVault
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Vault Icon and Status
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    vault.color.opacity(0.3),
                                    vault.color.opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: vault.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(vault.color)

                    if vault.isLocked {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.red)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.8))
                                            .frame(width: 20, height: 20)
                                    )
                            }
                        }
                        .frame(width: 80, height: 80)
                    }
                }

                // Vault Info
                VStack(spacing: 8) {
                    Text(vault.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text(vault.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    // Progress indicator
                    HStack(spacing: 8) {
                        ProgressView(value: vault.completionPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: vault.color))
                            .scaleEffect(y: 0.8)

                        Text("\(Int(vault.completionPercentage * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(vault.color)
                    }

                    Text(
                        "\(vault.documents.filter { $0.status == .uploaded || $0.status == .verified }.count)/\(vault.documents.count) docs"
                    )
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        vault.color.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaigeDashboard()
}
