//
//  TRAEUploadAnimations.swift
//  HOMEY Clean
//
//  Created by TRAE Motion Design System
//

import SwiftUI

// MARK: - TRAE Upload Animation Components

/// Document fly-in animation for vault uploads
struct TRAEDocumentFlyIn: View {
    let documentIcon: String
    let vaultPosition: CGPoint
    let isAnimating: Bool
    let onComplete: () -> Void
    
    @State private var documentPosition: CGPoint = CGPoint(x: 100, y: 100)
    @State private var documentScale: CGFloat = 1.0
    @State private var documentRotation: Double = 0
    @State private var documentOpacity: Double = 1.0
    @State private var trailPositions: [CGPoint] = []
    @State private var showSuccessEffect = false
    
    init(
        documentIcon: String = "doc.fill",
        vaultPosition: CGPoint,
        isAnimating: Bool,
        onComplete: @escaping () -> Void = {}
    ) {
        self.documentIcon = documentIcon
        self.vaultPosition = vaultPosition
        self.isAnimating = isAnimating
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Document trail effect
            ForEach(trailPositions.indices, id: \.self) { index in
                Image(systemName: documentIcon)
                    .font(.title2)
                    .foregroundColor(.blue.opacity(0.3 - Double(index) * 0.1))
                    .position(trailPositions[index])
                    .scaleEffect(0.8 - Double(index) * 0.1)
            }
            
            // Main document
            Image(systemName: documentIcon)
                .font(.title)
                .foregroundColor(.blue)
                .scaleEffect(documentScale)
                .rotationEffect(.degrees(documentRotation))
                .opacity(documentOpacity)
                .position(documentPosition)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Success effect
            if showSuccessEffect {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0)],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)
                    .position(vaultPosition)
                    .scaleEffect(showSuccessEffect ? 2.0 : 0.1)
                    .opacity(showSuccessEffect ? 0 : 1)
            }
        }
        .onChange(of: isAnimating) { animating in
            if animating {
                startFlyInAnimation()
            }
        }
    }
    
    private func startFlyInAnimation() {
        // Reset state
        documentPosition = CGPoint(x: 100, y: 100)
        documentScale = 1.0
        documentRotation = 0
        documentOpacity = 1.0
        showSuccessEffect = false
        trailPositions = []
        
        // Create trail effect
        createTrailEffect()
        
        // Animate document to vault
        withAnimation(
            .easeInOut(duration: 1.5)
            .delay(0.2)
        ) {
            documentPosition = vaultPosition
            documentScale = 0.3
            documentRotation = 360
        }
        
        // Fade out and show success effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.easeOut(duration: 0.3)) {
                documentOpacity = 0
            }
            
            withAnimation(.easeOut(duration: 0.8)) {
                showSuccessEffect = true
            }
            
            // Complete callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onComplete()
            }
        }
    }
    
    private func createTrailEffect() {
        let startPoint = CGPoint(x: 100, y: 100)
        let endPoint = vaultPosition
        
        for i in 0..<5 {
            let progress = Double(i) / 5.0
            let trailPoint = CGPoint(
                x: startPoint.x + (endPoint.x - startPoint.x) * progress,
                y: startPoint.y + (endPoint.y - startPoint.y) * progress
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    trailPositions.append(trailPoint)
                }
                
                // Remove trail after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if !trailPositions.isEmpty {
                        trailPositions.removeFirst()
                    }
                }
            }
        }
    }
}

// MARK: - Upload Progress with Liquid Animation

struct TRAEUploadProgress: View {
    let progress: Double
    let fileName: String
    let fileSize: String
    
    @State private var animatedProgress: Double = 0
    @State private var waveOffset: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showCompleteIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            // File info
            HStack {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(fileName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(fileSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showCompleteIcon {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .scaleEffect(pulseScale)
                }
            }
            
            // Liquid progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Liquid fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress)
                        .mask(
                            LiquidWave(offset: waveOffset)
                                .fill(Color.black)
                        )
                    
                    // Progress text
                    HStack {
                        Spacer()
                        Text("\(Int(animatedProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }
            .frame(height: 24)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            startAnimations()
        }
        .onChange(of: progress) { newProgress in
            animateToProgress(newProgress)
        }
    }
    
    private func startAnimations() {
        // Animate progress
        animateToProgress(progress)
        
        // Start wave animation
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            waveOffset = .pi * 4
        }
    }
    
    private func animateToProgress(_ newProgress: Double) {
        withAnimation(.easeInOut(duration: 0.8)) {
            animatedProgress = newProgress
        }
        
        // Show complete icon when done
        if newProgress >= 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    showCompleteIcon = true
                }
                
                // Pulse effect
                withAnimation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatCount(3, autoreverses: true)
                ) {
                    pulseScale = 1.2
                }
            }
        }
    }
}

// MARK: - Liquid Wave Shape

struct LiquidWave: Shape {
    let offset: Double
    
    var animatableData: Double {
        get { offset }
        set { }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let waveHeight: CGFloat = 6
        
        path.move(to: CGPoint(x: 0, y: height / 2))
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let sine = sin(offset + relativeX * .pi * 3)
            let y = height / 2 + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Multi-Document Upload Animation

struct TRAEMultiDocumentUpload: View {
    let documents: [DocumentUpload]
    let vaultPosition: CGPoint
    
    @State private var currentIndex = 0
    @State private var completedUploads: Set<Int> = []
    
    var body: some View {
        ZStack {
            ForEach(documents.indices, id: \.self) { index in
                TRAEDocumentFlyIn(
                    documentIcon: documents[index].icon,
                    vaultPosition: vaultPosition,
                    isAnimating: currentIndex == index,
                    onComplete: {
                        documentCompleted(at: index)
                    }
                )
                .offset(
                    x: CGFloat(index * 20),
                    y: CGFloat(index * 10)
                )
            }
        }
        .onAppear {
            startSequentialUpload()
        }
    }
    
    private func startSequentialUpload() {
        guard !documents.isEmpty else { return }
        currentIndex = 0
    }
    
    private func documentCompleted(at index: Int) {
        completedUploads.insert(index)
        
        // Start next document after delay
        if index + 1 < documents.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentIndex = index + 1
            }
        }
    }
}

// MARK: - Document Upload Model

struct DocumentUpload {
    let id: UUID = UUID()
    let name: String
    let icon: String
    let size: String
    
    init(name: String, icon: String = "doc.fill", size: String) {
        self.name = name
        self.icon = icon
        self.size = size
    }
}

// MARK: - Vault Animation

struct TRAEVaultAnimation: View {
    let isReceiving: Bool
    
    @State private var glowIntensity: Double = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Vault base
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.8),
                            Color.purple.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .scaleEffect(scaleEffect)
            
            // Vault icon
            Image(systemName: "archivebox.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
                .rotationEffect(.degrees(rotationAngle))
            
            // Glow effect
            if isReceiving {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.cyan.opacity(glowIntensity),
                        lineWidth: 4
                    )
                    .frame(width: 88, height: 88)
                    .blur(radius: 4)
            }
        }
        .onChange(of: isReceiving) { receiving in
            if receiving {
                startReceivingAnimation()
            } else {
                stopReceivingAnimation()
            }
        }
    }
    
    private func startReceivingAnimation() {
        // Glow animation
        withAnimation(
            Animation.easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            glowIntensity = 0.8
        }
        
        // Scale pulse
        withAnimation(
            Animation.easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true)
        ) {
            scaleEffect = 1.1
        }
        
        // Subtle rotation
        withAnimation(
            Animation.linear(duration: 4.0)
                .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
    }
    
    private func stopReceivingAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            glowIntensity = 0
            scaleEffect = 1.0
            rotationAngle = 0
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply TRAE document fly-in animation
    func traeDocumentFlyIn(
        to vaultPosition: CGPoint,
        isAnimating: Bool,
        onComplete: @escaping () -> Void = {}
    ) -> some View {
        self.overlay(
            TRAEDocumentFlyIn(
                vaultPosition: vaultPosition,
                isAnimating: isAnimating,
                onComplete: onComplete
            )
        )
    }
    
    /// Apply TRAE upload progress animation
    func traeUploadProgress(
        progress: Double,
        fileName: String,
        fileSize: String
    ) -> some View {
        self.overlay(
            TRAEUploadProgress(
                progress: progress,
                fileName: fileName,
                fileSize: fileSize
            )
        )
    }
}