//
//  AllDrawerComponents.swift
//  HOMEY Clean
//
//  All drawer view components extracted from ClientTabView
//

import SwiftUI

// MARK: - All Drawer View

struct AllDrawerView: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            // Drawer content
            HStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("All")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Menu items
                    ScrollView {
                        VStack(spacing: 16) {
                            DrawerMenuItem(
                                title: "Profile",
                                subtitle: "Your account and preferences",
                                icon: "person.circle.fill",
                                destination: "profile",
                                isDrawerPresented: $isPresented
                            )
                            
                            DrawerMenuItem(
                                title: "AR Features",
                                subtitle: "Property visualization & scanning",
                                icon: "arkit",
                                destination: "ar-features",
                                isDrawerPresented: $isPresented
                            )
                            
                            DrawerMenuItem(
                                title: "Insights",
                                subtitle: "Market insights / data",
                                icon: "chart.bar.fill",
                                destination: "insights",
                                isDrawerPresented: $isPresented
                            )
                            
                            DrawerMenuItem(
                                title: "Directory",
                                subtitle: "Trusted vendors / contacts",
                                icon: "folder.fill",
                                destination: "directory",
                                isDrawerPresented: $isPresented
                            )
                            
                            DrawerMenuItem(
                                title: "Vision",
                                subtitle: "Design / inspo content",
                                icon: "paintbrush.fill",
                                destination: "vision",
                                isDrawerPresented: $isPresented
                            )
                            
                            DrawerMenuItem(
                                title: "Settings",
                                subtitle: "App preferences",
                                icon: "gearshape.fill",
                                destination: "settings",
                                isDrawerPresented: $isPresented
                            )
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            DrawerMenuItem(
                                title: "Help & Support",
                                subtitle: "Get help and contact support",
                                icon: "questionmark.circle.fill",
                                destination: "help-support",
                                isDrawerPresented: $isPresented
                            )
                        }
                        .padding()
                    }
                }
                .frame(width: 300)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width > 0 {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            if value.translation.width > 100 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isPresented = false
                                }
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
            .padding(.trailing, 20)
        }
        .onAppear {
            dragOffset = 0
        }
    }
}