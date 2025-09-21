import SwiftUI

// MARK: - Document Context Tooltip Component

struct DocumentContextTooltip: View {
    let documentType: DocumentType
    let isVisible: Bool
    let onDismiss: () -> Void
    
    @State private var animateIcon = false
    @State private var animateGradient = false
    
    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 16) {
                // Enhanced Header with warm gradient
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .scaleEffect(animateIcon ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
                        
                        Image(systemName: documentType.systemIcon)
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(documentType.displayName)
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                        
                        Text("📖 Your Document Story")
                            .font(.caption)
                            .foregroundColor(.orange.opacity(0.8))
                            .italic()
                    }
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary.opacity(0.6))
                            .font(.title3)
                    }
                }
                
                // Enhanced Context Information with warm styling
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("🏠")
                            .font(.title3)
                        Text("Why this document matters in your housing journey:")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                    }
                    
                    Text(contextDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                    
                    if !tips.isEmpty {
                        HStack {
                            Text("💡")
                                .font(.title3)
                            Text("Pro Tips for Success:")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("✨")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(tip)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .padding(.leading, 8)
                    }
                }
                
                // Enhanced Action Button with warm gradient
                Button(action: onDismiss) {
                    HStack {
                        Text("🎯")
                            .font(.title3)
                        Text("Got it! Let's continue")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.pink.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .orange.opacity(0.1), radius: 20, x: 0, y: 8)
            )
            .padding(.horizontal, 20)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .opacity.combined(with: .scale(scale: 0.9))
            ))
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isVisible)
            .onAppear {
                animateIcon = true
            }
        }
    }
    
    private var contextDescription: String {
        switch documentType {
        case .bankStatement:
            return """
            Your bank statements tell the story of your financial life. Landlords and lenders examine these to see consistent income deposits, 
            responsible spending patterns, and sufficient reserves. They're looking for proof that you can handle monthly payments reliably - 
            think of it as your financial report card that shows you're ready for homeownership.
            """
            
        case .taxReturn:
            return """
            Tax returns are your official income autobiography. They provide a complete picture of your earnings, deductions, and financial 
            complexity over the past year. For major purchases like homes, they're essential because they show sustained income patterns 
            and help lenders calculate exactly how much you can afford.
            """
            
        case .payStub:
            return """
            Your recent pay stubs are like a financial pulse check - they prove you're currently employed and earning steady income. 
            Most lenders want to see 2-3 recent stubs to verify you meet the '3x rent rule' and that your job is stable. 
            They're your ticket to proving you can make those monthly payments.
            """
            
        case .creditReport:
            return """
            Your credit report is your financial reputation in black and white. It tells the story of how you've handled money in the past - 
            every payment, every account, every financial decision. A strong credit score (700+) opens doors to better interest rates, 
            lower deposits, and premium properties. It's proof you're financially trustworthy.
            """
            
        case .driversLicense:
            return """
            Your driver's license helps verify you're you during closing and throughout the rental process. Beyond basic identification, 
            it confirms your current address, validates your identity for background checks, and serves as your primary ID for all legal 
            documents. It's the foundation that makes everything else official.
            """
            
        case .socialSecurity:
            return """
            Your Social Security card is your unique identifier in the financial system. It's required for comprehensive background checks, 
            credit verification, and tax reporting. While essential, treat this document with extreme care - only share it when absolutely 
            necessary and with trusted parties during official transactions.
            """
            
        case .passport:
            return """
            A passport is premium identification that carries extra weight, especially for international buyers or when other ID documents 
            are limited. It demonstrates your legal status and provides backup identification. For high-end properties or complex 
            transactions, it adds an extra layer of credibility to your application.
            """
            
        case .lease:
            return """
            Previous lease agreements are your rental resume - they show you've successfully navigated housing before. They demonstrate 
            your ability to commit to long-term agreements, maintain properties responsibly, and work well with landlords. 
            Each successful lease builds your credibility as a reliable tenant.
            """
            
        case .rentalHistory:
            return """
            Your rental history is proof of your track record as a tenant. It shows consistent on-time payments, proper property care, 
            and positive relationships with previous landlords. This document can make or break your application in competitive markets - 
            it's your tenant reputation score.
            """
            
        case .employmentLetter:
            return """
            Employment verification letters provide official confirmation of your job stability and income. They're especially crucial 
            when you're starting a new position or have unique employment arrangements. This letter gives lenders confidence that your 
            income is reliable and will continue throughout your lease or mortgage term.
            """
            
        case .w2Form:
            return """
            W-2 forms are your official annual income statement from your employer. They provide verified, government-reported income 
            figures that lenders trust completely. Combined with tax returns, they paint a complete picture of your earning capacity 
            and employment stability over time.
            """
            
        case .insurance:
            return """
            Insurance documents show you're prepared for life's unexpected moments. Renter's insurance protects your belongings, 
            health insurance shows you can handle medical costs, and auto insurance demonstrates responsibility. Together, they prove 
            you're financially prepared and risk-aware.
            """
            
        case .reference:
            return """
            Personal and professional references are your character witnesses in the housing world. They vouch for your reliability, 
            trustworthiness, and suitability as a tenant or neighbor. Strong references from employers, previous landlords, or respected 
            community members can tip the scales in your favor.
            """
            
        case .offerLetter:
            return """
            Job offer letters show your future earning potential and employment security. They're especially valuable when you're 
            transitioning between jobs or starting a new career. This document helps lenders understand your income trajectory and 
            gives them confidence in your ability to meet future payments.
            """
            
        case .id:
            return """
            Valid identification is the cornerstone of any housing transaction. It verifies your identity, confirms your legal status, 
            and enables all other verification processes. Without proper ID, no other documents matter - it's your key to entering 
            the housing market.
            """
            
        case .referenceLetter:
            return """
            Reference letters provide detailed, personal testimonials about your character and reliability. Unlike simple contact 
            references, these written endorsements offer specific examples of your trustworthiness, responsibility, and positive qualities. 
            They're particularly valuable in competitive housing markets.
            """
            
        case .boardForm:
            return """
            Co-op and condo board applications are comprehensive evaluations of your financial and personal suitability. These detailed 
            forms require extensive documentation because board members are essentially choosing their future neighbors. Success here 
            means joining an exclusive community with shared values and standards.
            """
        }
    }
    
    private var tips: [String] {
        switch documentType {
        case .bankStatement:
            return [
                "Provide 2-3 months of recent statements",
                "Ensure statements show consistent deposits",
                "Highlight any large deposits with explanations"
            ]
            
        case .taxReturn:
            return [
                "Include all schedules and forms",
                "Provide 1-2 years of returns",
                "Have a CPA letter if self-employed"
            ]
            
        case .payStub:
            return [
                "Get the most recent 2-3 pay stubs",
                "Ensure year-to-date totals are visible",
                "Include bonus/overtime documentation"
            ]
            
        case .creditReport:
            return [
                "Get reports from all three bureaus",
                "Review for errors before submitting",
                "Include explanation letters for any issues"
            ]
            
        case .driversLicense:
            return [
                "Ensure license is current and not expired",
                "Update address if recently moved",
                "Have backup ID available"
            ]
            
        case .employmentLetter:
            return [
                "Request on company letterhead",
                "Include salary, position, and start date",
                "Get HR contact information included"
            ]
            
        case .reference:
            return [
                "Choose references who know you well",
                "Provide their contact information",
                "Give references a heads up they may be contacted"
            ]
            
        default:
            return []
        }
    }
}

// MARK: - Document Context Manager

class DocumentContextManager: ObservableObject {
    @Published var activeTooltip: DocumentType?
    @Published var hasSeenTooltips: Set<DocumentType> = []
    
    func showTooltip(for documentType: DocumentType) {
        activeTooltip = documentType
    }
    
    func dismissTooltip() {
        if let currentType = activeTooltip {
            hasSeenTooltips.insert(currentType)
        }
        activeTooltip = nil
    }
    
    func shouldShowTooltip(for documentType: DocumentType) -> Bool {
        return !hasSeenTooltips.contains(documentType)
    }
}

#Preview {
    VStack {
        DocumentContextTooltip(
            documentType: .bankStatement,
            isVisible: true,
            onDismiss: {}
        )
        
        Spacer()
    }
    .background(Color(.systemGray6))
}