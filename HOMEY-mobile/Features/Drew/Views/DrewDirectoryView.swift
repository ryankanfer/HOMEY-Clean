//
//  DrewDirectoryView.swift
//  HOMEY Clean
//
//  Replaced with Rolodex-style directory + “My Team” strip and category
//

import SwiftUI

// MARK: - Models
struct Professional: Identifiable {
    let id = UUID()
    let letter: String
    let name: String
    let title: String
    let phone: String
    let email: String
    let rating: Double
    let deals: Int
    let category: ProfessionalCategory
    let isOnMyTeam: Bool
}

enum ProfessionalCategory: String, CaseIterable {
    case all = "All"
    case myTeam = "My Team"
    case agents = "Agents"
    case lenders = "Lenders"
    case inspectors = "Inspectors"
    case attorneys = "Attorneys"
    case movers = "Movers"
}

// MARK: - Main View
struct RolodexView: View {
    @StateObject private var viewModel = RolodexViewModel()
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(hex: "1e3a5f"),
                    Color(hex: "2c5f8d"),
                    Color(hex: "4a7ba7")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Compact Header (identity + CTA)
                    compactHeader
                    
                    // Search Bar
                    searchBar
                    
                    // Category Tabs
                    categoryTabs
                    
                    // My Team Strip (horizontal)
                    if !viewModel.teamMembers.isEmpty {
                        myTeamStrip
                            .padding(.bottom, 8)
                    }
                    
                    // Rolodex Cards + Alphabet Strip
                    ZStack {
                        carouselView
                        
                        // Alphabet Strip
                        alphabetStrip
                    }
                    .frame(minHeight: 420)
                    
                    // Navigation Controls
                    navigationControls
                }
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $viewModel.showingMatchModal) {
            MatchMeView(isPresented: $viewModel.showingMatchModal)
        }
        // Hide nav title when embedded in a NavigationStack
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Compact Header (Improved)
    private var compactHeader: some View {
        HStack(spacing: 12) {
            // Identity chip
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Text("D")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    )
                
                Text("Your Curated Directory")
                    .font(TypographySystem.BodyAndUI.label)
                    .foregroundColor(.white.opacity(0.95))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.10))
                    .background(.ultraThinMaterial, in: Capsule())
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            
            Spacer()
            
            // Match Me CTA (refined)
            Button(action: { viewModel.showingMatchModal = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Match Me")
                        .font(TypographySystem.BodyAndUI.button)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .white.opacity(0.18), radius: 10, x: 0, y: 0)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                )
                .scaleEffect(1.0)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)     // reduced from 60 to bring content higher
        .padding(.bottom, 10)  // tighter to give more room to content
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .font(.system(size: 18))
            
            TextField("Search professionals...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .accentColor(.white)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.1))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ProfessionalCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        title: category.rawValue,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                            viewModel.selectedCategory = category
                        }
                    }
                    .scaleEffect(viewModel.selectedCategory == category ? 1.02 : 1.0)
                    .animation(.spring(response: 0.28, dampingFraction: 0.82), value: viewModel.selectedCategory)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 2)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - My Team Strip
    private var myTeamStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("My Team")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.95))
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedCategory = .myTeam
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                        Text("View All")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(Color.white.opacity(0.12))
                    )
                }
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.teamMembers) { pro in
                        TeamMiniCard(professional: pro) {
                            viewModel.jumpToProfessional(by: pro.id)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Carousel View
    private var carouselView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.filteredProfessionals.enumerated()), id: \.element.id) { index, professional in
                    RolodexProfessionalCard(professional: professional)
                        .offset(x: offsetForCard(at: index, in: geometry))
                        .scaleEffect(scaleForCard(at: index))
                        .rotation3DEffect(
                            .degrees(rotationForCard(at: index)),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .opacity(opacityForCard(at: index))
                        .zIndex(zIndexForCard(at: index))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: viewModel.currentIndex)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 420)
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
    }
    
    // MARK: - Carousel Calculations
    private func offsetForCard(at index: Int, in geometry: GeometryProxy) -> CGFloat {
        let difference = CGFloat(index - viewModel.currentIndex)
        if difference == 0 { return 0 }
        if difference == -1 { return -geometry.size.width * 0.6 }
        if difference == 1 { return geometry.size.width * 0.6 }
        return difference < 0 ? -geometry.size.width : geometry.size.width
    }
    
    private func scaleForCard(at index: Int) -> CGFloat {
        let difference = abs(index - viewModel.currentIndex)
        if difference == 0 { return 1.0 }
        if difference == 1 { return 0.7 }
        return 0.5
    }
    
    private func rotationForCard(at index: Int) -> Double {
        let difference = index - viewModel.currentIndex
        if difference == 0 { return 0 }
        if difference == -1 { return 45 }
        if difference == 1 { return -45 }
        return difference < 0 ? 90 : -90
    }
    
    private func opacityForCard(at index: Int) -> Double {
        let difference = abs(index - viewModel.currentIndex)
        if difference == 0 { return 1.0 }
        if difference == 1 { return 0.4 }
        return 0.0
    }
    
    private func zIndexForCard(at index: Int) -> Double {
        let difference = abs(index - viewModel.currentIndex)
        return Double(100 - difference)
    }
    
    // MARK: - Alphabet Strip
    private var alphabetStrip: some View {
        VStack(spacing: 2) {
            ForEach(viewModel.availableLetters, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(viewModel.currentLetter == letter ? Color(hex: "1e3a5f") : .white.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(viewModel.currentLetter == letter ? .white : .clear)
                    )
                    .scaleEffect(viewModel.currentLetter == letter ? 1.2 : 1.0)
                    .onTapGesture {
                        viewModel.jumpToLetter(letter)
                    }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding(.trailing, 10)
    }
    
    // MARK: - Navigation Controls
    private var navigationControls: some View {
        VStack(spacing: 15) {
            // Card Counter
            Text("\(viewModel.currentIndex + 1) / \(viewModel.filteredProfessionals.count)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Navigation Arrows
            HStack(spacing: 80) {
                NavigationButton(icon: "chevron.left") {
                    viewModel.previousCard()
                }
                .disabled(viewModel.currentIndex == 0)
                .opacity(viewModel.currentIndex == 0 ? 0.3 : 1.0)
                
                NavigationButton(icon: "chevron.right") {
                    viewModel.nextCard()
                }
                .disabled(viewModel.currentIndex >= viewModel.filteredProfessionals.count - 1)
                .opacity(viewModel.currentIndex >= viewModel.filteredProfessionals.count - 1 ? 0.3 : 1.0)
            }
        }
        .padding(.bottom, 30)
        .padding(.top, 6)
    }
}

// MARK: - My Team Mini Card (renamed to avoid conflicts)
private struct TeamMiniCard: View {
    let professional: Professional
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(initials(from: professional.name))
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(professional.name)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(professional.title)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func initials(from name: String) -> String {
        let comps = name.split(separator: " ")
        let first = comps.first?.first.map(String.init) ?? ""
        let last = comps.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
}

// MARK: - Professional Card (renamed to avoid conflicts)
struct RolodexProfessionalCard: View {
    let professional: Professional
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Name
            Text(professional.name)
                .font(.system(size: 26, weight: .black))
                .foregroundColor(Color(hex: "1e3a5f"))
            
            // Title
            Text(professional.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "2c5f8d"))
                .padding(.top, 8)
            
            // Divider
            LinearGradient(
                colors: [Color(hex: "1e3a5f"), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 2)
            .padding(.vertical, 20)
            
            // Contact Details
            VStack(alignment: .leading, spacing: 12) {
                ContactRow(icon: "phone.fill", text: professional.phone)
                ContactRow(icon: "envelope.fill", text: professional.email)
                ContactRow(icon: "star.fill", text: "\(String(format: "%.1f", professional.rating)) · \(professional.deals) deals")
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 10) {
                RolodexActionButton(title: "Call", isPrimary: true) {
                    // Handle call action
                }
                
                RolodexActionButton(title: "Email", isPrimary: false) {
                    // Handle email action
                }
            }
            .padding(.top, 20)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
        )
    }
}

// MARK: - Contact Row
struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "2c5f8d"))
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.8))
        }
    }
}

// MARK: - Action Button (renamed to avoid conflicts)
struct RolodexActionButton: View {
    let title: String
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(isPrimary ? .white : Color(hex: "1e3a5f"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isPrimary ? Color(hex: "1e3a5f") : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "1e3a5f"), lineWidth: isPrimary ? 0 : 2)
                )
        }
    }
}

// MARK: - Category Tab
struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold)) // slightly larger for tap target
                .foregroundColor(isSelected ? Color(hex: "1e3a5f") : .white.opacity(0.9))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.1))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isSelected ? .clear : Color.white.opacity(0.18), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Navigation Button
struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 55, height: 55)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                )
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Match Me View
struct MatchMeView: View {
    @Binding var isPresented: Bool
    @State private var selectedType: String?
    @State private var selectedBudget: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text("Smart Match")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.white)
                    
                    HStack {
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                .padding(.bottom, 10)
                
                Text("Find your perfect professional")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Question 1
                        QuizQuestion(
                            title: "What are you looking for?",
                            options: [
                                ("house.fill", "Real Estate Agent", "agent"),
                                ("dollarsign.circle.fill", "Mortgage Lender", "lender"),
                                ("magnifyingglass", "Home Inspector", "inspector"),
                                ("briefcase.fill", "Attorney", "attorney"),
                                ("shippingbox.fill", "Moving Services", "mover")
                            ],
                            selectedOption: $selectedType
                        )
                        
                        // Question 2
                        QuizQuestion(
                            title: "What's your budget range?",
                            options: [
                                ("banknote", "Under $500K", "low"),
                                ("dollarsign", "$500K - $1M", "mid"),
                                ("diamond", "$1M+", "high")
                            ],
                            selectedOption: $selectedBudget
                        )
                        
                        // Show Matches Button
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("SHOW MY MATCHES")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(Color(hex: "1a1a1a"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "ffd700"), Color(hex: "ffed4e")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                        .disabled(selectedType == nil || selectedBudget == nil)
                        .opacity(selectedType == nil || selectedBudget == nil ? 0.5 : 1.0)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Quiz Question
struct QuizQuestion: View {
    let title: String
    let options: [(icon: String, text: String, value: String)]
    @Binding var selectedOption: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                ForEach(options, id: \.value) { option in
                    QuizOptionButton(
                        icon: option.icon,
                        text: option.text,
                        isSelected: selectedOption == option.value
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedOption = option.value
                        }
                    }
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Quiz Option Button
struct QuizOptionButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 24)
                
                Text(text)
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
            }
            .foregroundColor(isSelected ? Color(hex: "1a1a1a") : .white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [Color(hex: "ffd700"), Color(hex: "ffed4e")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? .clear : Color.white.opacity(0.2), lineWidth: 2)
            )
        }
    }
}

// MARK: - View Model
class RolodexViewModel: ObservableObject {
    @Published var professionals: [Professional] = [
        Professional(letter: "C", name: "Chen, David", title: "Home Inspector · Licensed", phone: "(646) 555-0234", email: "david@chenhome.com", rating: 4.9, deals: 312, category: .inspectors, isOnMyTeam: true),
        Professional(letter: "D", name: "Davidson, James", title: "Senior Loan Officer · Chase", phone: "(212) 555-0123", email: "james.d@chase.com", rating: 4.9, deals: 456, category: .lenders, isOnMyTeam: false),
        Professional(letter: "D", name: "Davis, John", title: "Real Estate Specialist", phone: "(212) 555-0234", email: "john@davisrealty.com", rating: 4.8, deals: 189, category: .agents, isOnMyTeam: true),
        Professional(letter: "G", name: "Garcia, Lisa", title: "Mortgage Specialist", phone: "(718) 555-0567", email: "lisa.g@wellsfargo.com", rating: 4.8, deals: 278, category: .lenders, isOnMyTeam: false),
        Professional(letter: "M", name: "Miller, Sarah", title: "Elite Real Estate Agent", phone: "(718) 555-0456", email: "sarah@millerrealty.com", rating: 5.0, deals: 287, category: .agents, isOnMyTeam: true),
        Professional(letter: "R", name: "Rodriguez, Maria", title: "Real Estate Attorney", phone: "(917) 555-0678", email: "maria@rodlaw.com", rating: 4.9, deals: 534, category: .attorneys, isOnMyTeam: false),
        Professional(letter: "S", name: "Smith, Robert", title: "Construction Contractor", phone: "(718) 555-0901", email: "robert@smithconst.com", rating: 4.8, deals: 267, category: .movers, isOnMyTeam: false),
        Professional(letter: "W", name: "Wang, Emily", title: "Luxury Property Specialist", phone: "(212) 555-0789", email: "emily.wang@luxury.com", rating: 5.0, deals: 143, category: .agents, isOnMyTeam: false)
    ]
    
    @Published var currentIndex: Int = 0
    @Published var searchText: String = ""
    @Published var selectedCategory: ProfessionalCategory = .all
    @Published var showingMatchModal: Bool = false
    
    var teamMembers: [Professional] {
        professionals.filter { $0.isOnMyTeam }
    }
    
    var filteredProfessionals: [Professional] {
        var result = professionals
        
        // Category filter
        switch selectedCategory {
        case .all:
            break
        case .myTeam:
            result = result.filter { $0.isOnMyTeam }
        case .agents, .lenders, .inspectors, .attorneys, .movers:
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var availableLetters: [String] {
        let letters = Set(filteredProfessionals.map { $0.letter })
        return letters.sorted()
    }
    
    var currentLetter: String {
        guard currentIndex < filteredProfessionals.count else { return "" }
        return filteredProfessionals[currentIndex].letter
    }
    
    func nextCard() {
        guard currentIndex < filteredProfessionals.count - 1 else { return }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            currentIndex += 1
        }
    }
    
    func previousCard() {
        guard currentIndex > 0 else { return }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            currentIndex -= 1
        }
    }
    
    func jumpToLetter(_ letter: String) {
        if let index = filteredProfessionals.firstIndex(where: { $0.letter == letter }) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                currentIndex = index
            }
        }
    }
    
    func jumpToProfessional(by id: UUID) {
        // Ensure we are viewing the collection that contains the professional
        if selectedCategory == .myTeam {
            if let idx = filteredProfessionals.firstIndex(where: { $0.id == id }) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    currentIndex = idx
                }
                return
            }
        }
        
        // If not currently in My Team, try to locate in the overall filtered list.
        if let idx = filteredProfessionals.firstIndex(where: { $0.id == id }) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                currentIndex = idx
            }
        } else {
            // Switch to the appropriate category so the item is visible, then jump.
            if let target = professionals.first(where: { $0.id == id }) {
                if target.isOnMyTeam {
                    selectedCategory = .myTeam
                } else {
                    selectedCategory = target.category
                }
                DispatchQueue.main.async {
                    if let newIdx = self.filteredProfessionals.firstIndex(where: { $0.id == id }) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            self.currentIndex = newIdx
                        }
                    }
                }
            }
        }
    }
}

// NOTE: Removed duplicate Color.init(hex:) extension here to avoid redeclaration.
// Use the shared implementation in Color+Hex.swift.

// MARK: - Preview
struct RolodexView_Previews: PreviewProvider {
    static var previews: some View {
        RolodexView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - Backward-compatibility wrapper
// Provides the old entry-point name used across the app.
public struct DrewDirectoryView: View {
    public init() {}
    public var body: some View {
        RolodexView()
    }
}
