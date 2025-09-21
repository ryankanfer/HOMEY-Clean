import Foundation
import SwiftUI

// MARK: - Contact Model
struct Contact: Identifiable, Codable {
    let id = UUID()
    let name: String
    let avatar: String
    let avatarURL: String?
    let role: ProfessionalRole
    let company: String?
    let borough: Borough
    let languages: [Language]
    let trustScore: Double
    let biography: String
    let documents: [DrewDocument]
    let endorsements: [Endorsement]
    let introductionStatus: IntroductionStatus
    let lastActivity: Date
    let contactInfo: DrewContactInfo
    
    // Trust signals
    let pastDeals: Int
    let yearsExperience: Int
    let certifications: [String]
    let recommendations: Int
    
    // Computed properties
    var recencyDecay: Double {
        let daysSinceActivity = Calendar.current.dateComponents([.day], from: lastActivity, to: Date()).day ?? 0
        return max(0.1, 1.0 - (Double(daysSinceActivity) * 0.01))
    }
    
    var adjustedTrustScore: Double {
        return trustScore * recencyDecay
    }
    
    var displayTrustScore: String {
        return String(format: "%.1f", adjustedTrustScore)
    }
}

// MARK: - Supporting Enums
enum ProfessionalRole: String, CaseIterable, Codable {
    case lawyer = "Lawyer"
    case lender = "Lender"
    case inspector = "Inspector"
    case manager = "Property Manager"
    case broker = "Broker"
    case contractor = "Contractor"
    case accountant = "Accountant"
    case insurance = "Insurance Agent"
    case architect = "Architect"
    case mover = "Moving & Relocation Specialist"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .lawyer: return "briefcase.fill"
        case .lender: return "banknote.fill"
        case .inspector: return "magnifyingglass.circle.fill"
        case .manager: return "building.2.fill"
        case .broker: return "handshake.fill"
        case .contractor: return "hammer.fill"
        case .accountant: return "calculator.fill"
        case .insurance: return "shield.fill"
        case .architect: return "ruler.fill"
        case .mover: return "truck.box.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .lawyer: return .blue
        case .lender: return .green
        case .inspector: return .orange
        case .manager: return .purple
        case .broker: return .red
        case .contractor: return .brown
        case .accountant: return .indigo
        case .insurance: return .teal
        case .architect: return .cyan
        case .mover: return .mint
        }
    }
}

enum Borough: String, CaseIterable, Codable {
    case manhattan = "Manhattan"
    case brooklyn = "Brooklyn"
    case queens = "Queens"
    case bronx = "Bronx"
    case statenIsland = "Staten Island"
}

enum Language: String, CaseIterable, Codable {
    case english = "English"
    case spanish = "Spanish"
    case mandarin = "Mandarin"
    case cantonese = "Cantonese"
    case french = "French"
    case russian = "Russian"
    case arabic = "Arabic"
    case korean = "Korean"
}

enum IntroductionStatus: String, Codable {
    case none = "none"
    case requested = "requested"
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    
    var displayText: String {
        switch self {
        case .none: return "Request Intro"
        case .requested: return "Requested"
        case .pending: return "Pending"
        case .accepted: return "Connected"
        case .declined: return "Declined"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return .blue
        case .requested: return .orange
        case .pending: return .yellow
        case .accepted: return .green
        case .declined: return .red
        }
    }
}

// MARK: - Supporting Models
struct DrewDocument: Identifiable, Codable {
    let id = UUID()
    let title: String
    let type: DrewDocumentType
    let url: URL?
    let uploadDate: Date
}

enum DrewDocumentType: String, CaseIterable, Codable {
    case license = "License"
    case certification = "Certification"
    case portfolio = "Portfolio"
    case testimonial = "Testimonial"
    case contract = "Contract Template"
}

struct Endorsement: Identifiable, Codable {
    let id = UUID()
    let endorserName: String
    let endorserRole: String
    let message: String
    let date: Date
    let rating: Int // 1-5 stars
}

struct DrewContactInfo: Codable {
    let email: String
    let phone: String?
    let website: String?
    let linkedIn: String?
    let address: String?
}

// MARK: - Sample Data
extension Contact {
    static let sampleContacts: [Contact] = [
        Contact(
            name: "Sarah Chen",
            avatar: "person.circle.fill",
            avatarURL: "https://example.com/avatars/sarah-chen.jpg",
            role: ProfessionalRole.lawyer,
            company: "Chen & Associates",
            borough: Borough.manhattan,
            languages: [Language.english, Language.mandarin],
            trustScore: 4.8,
            biography: "Experienced real estate attorney specializing in residential transactions and commercial leases. Over 15 years of practice in NYC.",
            documents: [
                DrewDocument(
                    title: "Real Estate License",
                    type: .license,
                    url: URL(string: "https://example.com/license.pdf"),
                    uploadDate: Date().addingTimeInterval(-86400 * 30)
                ),
                DrewDocument(
                    title: "Professional Certification",
                    type: .certification,
                    url: URL(string: "https://example.com/cert.pdf"),
                    uploadDate: Date().addingTimeInterval(-86400 * 60)
                )
            ],
            endorsements: [],
            introductionStatus: IntroductionStatus.none,
            lastActivity: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            contactInfo: DrewContactInfo(
                email: "sarah@chenlaw.com",
                phone: "(212) 555-0123",
                website: "www.chenlaw.com",
                linkedIn: "sarah-chen-law",
                address: "123 Broadway, New York, NY 10001"
            ),
            pastDeals: 150,
            yearsExperience: 15,
            certifications: ["NY Bar", "Real Estate Law Specialist"],
            recommendations: 42
        ),
        Contact(
            name: "Michael Rodriguez",
            avatar: "person.circle.fill",
            avatarURL: "https://example.com/avatars/michael-rodriguez.jpg",
            role: ProfessionalRole.lender,
            company: "Empire Mortgage",
            borough: Borough.brooklyn,
            languages: [Language.english, Language.spanish],
            trustScore: 4.6,
            biography: "Senior mortgage specialist with expertise in first-time buyer programs and investment property financing.",
            documents: [],
            endorsements: [],
            introductionStatus: IntroductionStatus.none,
            lastActivity: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            contactInfo: DrewContactInfo(
                email: "mrodriguez@empiremortgage.com",
                phone: "(718) 555-0456",
                website: "www.empiremortgage.com",
                linkedIn: "michael-rodriguez-mortgage",
                address: "456 Atlantic Ave, Brooklyn, NY 11217"
            ),
            pastDeals: 200,
            yearsExperience: 12,
            certifications: ["NMLS Licensed", "FHA Specialist"],
            recommendations: 38
        ),
        
        Contact(
             name: "Maria Lopez",
             avatar: "maria_lopez",
             avatarURL: "maria_lopez",
            role: ProfessionalRole.inspector,
            company: "SafeHouse Inspections LLC",
            borough: Borough.manhattan,
            languages: [Language.english, Language.spanish],
            trustScore: 4.8,
            biography: "Maria is a licensed home inspector with over 12 years of experience ensuring property safety and compliance. " +
                       "Her thorough inspections and detailed reports have helped thousands of buyers make informed decisions about their investments.",
            documents: [
                DrewDocument(
                    title: "Home Inspector License",
                    type: .license,
                    url: URL(string: "https://example.com/license-maria.pdf"),
                    uploadDate: Date().addingTimeInterval(-86400 * 45)
                ),
                DrewDocument(
                    title: "ASHI Certification",
                    type: .certification,
                    url: URL(string: "https://example.com/cert-maria.pdf"),
                    uploadDate: Date().addingTimeInterval(-86400 * 90)
                )
            ],
            endorsements: [
                Endorsement(
                    endorserName: "David Chen",
                    endorserRole: "Property Manager",
                    message: "Maria's inspections are incredibly thorough and professional.",
                    date: Date().addingTimeInterval(-86400 * 10),
                    rating: 5
                )
            ],
            introductionStatus: IntroductionStatus.none,
            lastActivity: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            contactInfo: DrewContactInfo(
                email: "maria.lopez@safehouseinspect.com",
                phone: "(212) 555-9812",
                website: "www.safehouseinspections.com",
                linkedIn: "maria-lopez-inspector",
                address: "789 Broadway, New York, NY 10003"
            ),
            pastDeals: 89,
            yearsExperience: 12,
            certifications: ["Licensed Home Inspector", "ASHI Certified Inspector"],
            recommendations: 34
        ),
        
        Contact(
             name: "David Chen",
             avatar: "david_chen",
             avatarURL: "david_chen",
            role: ProfessionalRole.manager,
            company: "Metro Property Group",
            borough: Borough.manhattan,
            languages: [Language.english, Language.mandarin],
            trustScore: 4.7,
            biography: "David manages a diverse portfolio of residential and commercial properties across Manhattan. " +
                       "With 10 years in property management, he specializes in tenant relations, maintenance coordination, and maximizing property value for owners.",
            documents: [
                DrewDocument(
                    title: "Property Management License",
                    type: .license,
                    url: URL(string: "https://example.com/license-david.pdf"),
                    uploadDate: Date().addingTimeInterval(-86400 * 60)
                )
            ],
            endorsements: [],
            introductionStatus: IntroductionStatus.none,
            lastActivity: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            contactInfo: DrewContactInfo(
                email: "dchen@metropropgroup.com",
                phone: "(646) 555-4321",
                website: "www.metropropgroup.com",
                linkedIn: "david-chen-pm",
                address: "321 Park Ave, New York, NY 10010"
            ),
            pastDeals: 156,
            yearsExperience: 10,
            certifications: ["Licensed Property Manager", "Certified Property Manager (CPM)"],
            recommendations: 42
        ),
        
        Contact(
             name: "Jessica Brown",
             avatar: "jessica_brown",
             avatarURL: "jessica_brown",
            role: ProfessionalRole.broker,
            company: "Prime Realty NYC",
            borough: Borough.manhattan,
            languages: [Language.english],
            trustScore: 4.9,
            biography: "Jessica is a top-performing real estate broker specializing in luxury Manhattan properties. " +
                       "With 15 years of experience and over $500M in sales, she provides white-glove service to high-net-worth clients seeking premium real estate investments.",
            documents: [
                DrewDocument(
                    title: "Real Estate Broker License",
                    type: .license,
                    url: URL(string: "https://example.com/license-jessica.pdf"),
                    uploadDate: Date().addingTimeInterval(-86400 * 30)
                )
            ],
            endorsements: [],
            introductionStatus: IntroductionStatus.none,
            lastActivity: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            contactInfo: DrewContactInfo(
                email: "jbrown@primerealtynyc.com",
                phone: "(917) 555-2290",
                website: "www.primerealtynyc.com",
                linkedIn: "jessica-brown-nyc",
                address: "555 Fifth Ave, New York, NY 10017"
            ),
            pastDeals: 203,
            yearsExperience: 15,
            certifications: ["Licensed Real Estate Broker", "Luxury Property Specialist"],
            recommendations: 67
        ),
        
        Contact(
             name: "Samuel Ortiz",
             avatar: "samuel_ortiz",
             avatarURL: "samuel_ortiz",
            role: ProfessionalRole.contractor,
            company: "Ortiz Construction & Design",
            borough: Borough.brooklyn,
            languages: [Language.english, Language.spanish],
            trustScore: 4.8,
            biography: "Samuel leads a full-service construction and design firm specializing in residential renovations and custom builds. " +
                       "With 18 years of experience, his team has transformed hundreds of properties while maintaining the highest standards of craftsmanship.",
            documents: [
                DrewDocument(
                    title: "General Contractor License",
                    type: .license,
                    url: URL(string: "https://example.com/license-samuel.pdf"),
                    uploadDate: Date().addingTimeInterval(-86400 * 90)
                )
            ],
            endorsements: [],
            introductionStatus: IntroductionStatus.none,
            lastActivity: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            contactInfo: DrewContactInfo(
                email: "samuel@ortizbuilds.com",
                phone: "(212) 555-7766",
                website: "www.ortizbuilds.com",
                linkedIn: "samuel-ortiz-contractor",
                address: "678 Atlantic Ave, Brooklyn, NY 11217"
            ),
            pastDeals: 134,
             yearsExperience: 18,
             certifications: ["Licensed General Contractor", "OSHA Certified"],
             recommendations: 56
         ),
         
         Contact(
              name: "Emily Carter",
              avatar: "emily_carter",
              avatarURL: "emily_carter",
             role: ProfessionalRole.accountant,
             company: "Carter & Associates Accounting",
             borough: Borough.manhattan,
             languages: [Language.english],
             trustScore: 4.9,
             biography: "Emily is a certified public accountant specializing in real estate taxation and investment analysis. " +
                        "With 14 years of experience, she helps property investors optimize their tax strategies and maximize returns on real estate portfolios.",
             documents: [
                 DrewDocument(
                     title: "CPA License",
                     type: .license,
                     url: URL(string: "https://example.com/license-emily.pdf"),
                     uploadDate: Date().addingTimeInterval(-86400 * 120)
                 ),
                 DrewDocument(
                     title: "Real Estate Tax Specialist",
                     type: .certification,
                     url: URL(string: "https://example.com/cert-emily.pdf"),
                     uploadDate: Date().addingTimeInterval(-86400 * 200)
                 )
             ],
             endorsements: [
                 Endorsement(
                     endorserName: "Jessica Brown",
                     endorserRole: "Real Estate Broker",
                     message: "Emily's tax expertise has saved my clients thousands in real estate transactions.",
                     date: Date().addingTimeInterval(-86400 * 6),
                     rating: 5
                 )
             ],
             introductionStatus: IntroductionStatus.none,
             lastActivity: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
             contactInfo: DrewContactInfo(
                 email: "emily.carter@cartercpa.com",
                 phone: "(718) 555-1180",
                 website: "www.cartercpa.com",
                 linkedIn: "emily-carter-cpa",
                 address: "456 Lexington Ave, New York, NY 10017"
             ),
             pastDeals: 78,
             yearsExperience: 14,
             certifications: ["Certified Public Accountant (CPA)", "Real Estate Tax Specialist"],
             recommendations: 41
         ),
         
         Contact(
             name: "Marcus Johnson",
             avatar: "marcus_johnson",
             avatarURL: "marcus_johnson",
             role: ProfessionalRole.lawyer,
             company: "Johnson Legal Associates",
             borough: Borough.manhattan,
             languages: [Language.english],
             trustScore: 4.7,
             biography: "Marcus is a seasoned real estate attorney with 16 years of experience in complex commercial and residential transactions. " +
                        "He specializes in contract negotiations, due diligence, and closing procedures for high-value properties.",
             documents: [
                 DrewDocument(
                     title: "NY Bar License",
                     type: .license,
                     url: URL(string: "https://example.com/license-marcus.pdf"),
                     uploadDate: Date().addingTimeInterval(-86400 * 75)
                 )
             ],
             endorsements: [],
             introductionStatus: IntroductionStatus.none,
             lastActivity: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
             contactInfo: DrewContactInfo(
                 email: "marcus.johnson@johnsonlegal.com",
                 phone: "(212) 555-8901",
                 website: "www.johnsonlegal.com",
                 linkedIn: "marcus-johnson-attorney",
                 address: "890 Park Ave, New York, NY 10075"
             ),
             pastDeals: 187,
             yearsExperience: 16,
             certifications: ["NY State Bar", "Real Estate Law Specialist"],
             recommendations: 52
         ),
         
         Contact(
             name: "Olivia Green",
             avatar: "olivia_green",
             avatarURL: "olivia_green",
             role: ProfessionalRole.architect,
             company: "Green Design Studio",
             borough: Borough.brooklyn,
             languages: [Language.english],
             trustScore: 4.8,
             biography: "Olivia is an innovative architect specializing in sustainable residential design and historic renovations. " +
                        "With 11 years of experience, she creates beautiful, functional spaces that respect both environmental and historical considerations.",
             documents: [
                 DrewDocument(
                     title: "Architecture License",
                     type: .license,
                     url: URL(string: "https://example.com/license-olivia.pdf"),
                     uploadDate: Date().addingTimeInterval(-86400 * 45)
                 )
             ],
             endorsements: [],
             introductionStatus: IntroductionStatus.none,
             lastActivity: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
             contactInfo: DrewContactInfo(
                 email: "olivia.green@greendesignstudio.com",
                 phone: "(718) 555-3344",
                 website: "www.greendesignstudio.com",
                 linkedIn: "olivia-green-architect",
                 address: "234 Court St, Brooklyn, NY 11201"
             ),
             pastDeals: 67,
             yearsExperience: 11,
             certifications: ["Licensed Architect", "LEED Certified Professional"],
             recommendations: 29
         ),
         
         Contact(
             name: "Robert Williams",
             avatar: "robert_williams",
             avatarURL: "robert_williams",
             role: ProfessionalRole.mover,
             company: "Williams Moving & Storage",
             borough: Borough.queens,
             languages: [Language.english],
             trustScore: 4.6,
             biography: "Robert runs a full-service moving and storage company that has been serving NYC families and businesses for over 20 years. " +
                        "His team specializes in careful handling of valuable items and efficient long-distance relocations.",
             documents: [
                 DrewDocument(
                     title: "DOT Moving License",
                     type: .license,
                     url: URL(string: "https://example.com/license-robert.pdf"),
                     uploadDate: Date().addingTimeInterval(-86400 * 30)
                 )
             ],
             endorsements: [],
             introductionStatus: IntroductionStatus.none,
             lastActivity: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
             contactInfo: DrewContactInfo(
                 email: "robert.williams@williamsmoving.com",
                 phone: "(718) 555-6677",
                 website: "www.williamsmoving.com",
                 linkedIn: "robert-williams-moving",
                 address: "567 Northern Blvd, Queens, NY 11372"
             ),
             pastDeals: 245,
             yearsExperience: 20,
             certifications: ["DOT Licensed Mover", "Professional Moving Specialist"],
             recommendations: 83
         )
    ]
}