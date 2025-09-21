//
//  TRAEDemoView.swift
//  HOMEY Clean
//
//  TRAE Motion Design System Demo
//

import SwiftUI

struct TRAEDemoView: View {
    @State private var searchText = ""
    @State private var progress: Double = 0.3
    @State private var isFlipped = false
    @State private var isToggleOn = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("TRAE Motion Design System")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                        
                        Text("Interactive Animation Showcase")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Enhanced Button Animations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Enhanced Button Animations")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            Button("TRAE Enhanced Button") {
                                print("Enhanced button tapped!")
                            }
                            .buttonStyle(CTAButtonStyle())
                            
                            Button("Standard Button") {
                                print("Standard button tapped!")
                            }
                            .buttonStyle(.bordered)
                            
                            Text("Notice the enhanced spring animation and haptic feedback on the TRAE button!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Progress Animation Demo
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Animations")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 16) {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .scaleEffect(y: 2)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                            
                            HStack(spacing: 12) {
                                Button("Increase") {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        progress = min(1.0, progress + 0.2)
                                    }
                                }
                                .buttonStyle(CTAButtonStyle())
                                
                                Button("Reset") {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        progress = 0.0
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            Text("Progress: \(Int(progress * 100))%")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Animation Comparison
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Animation Comparison")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("TRAE Enhanced")
                                    .font(.headline)
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 60, height: 60)
                                    .scaleEffect(isToggleOn ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isToggleOn)
                                    .onTapGesture {
                                        TRAEMotionSystem.shared.triggerHaptic(.medium)
                                        isToggleOn.toggle()
                                    }
                            }
                            
                            VStack {
                                Text("Standard")
                                    .font(.headline)
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 60, height: 60)
                                    .scaleEffect(isToggleOn ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isToggleOn)
                                    .onTapGesture {
                                        isToggleOn.toggle()
                                    }
                            }
                        }
                        
                        Text("Tap the circles to compare TRAE's enhanced spring animations with haptic feedback vs standard animations.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("TRAE Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TRAEDemoView()
}