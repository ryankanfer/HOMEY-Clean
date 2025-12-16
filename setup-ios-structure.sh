#!/bin/bash

# HOMEY iOS Project Structure Generator
# Run this after creating your Xcode project

cd "/Users/ryankanfer/Documents/Developer/HOMEY Clean/homey-ios/HOMEY"

echo "🏗️  Creating HOMEY iOS project structure..."

# Create Core directories
mkdir -p Core/Network
mkdir -p Core/Models
mkdir -p Core/Utilities

# Create Features directories
mkdir -p Features/Authentication/Views
mkdir -p Features/Authentication/ViewModels
mkdir -p Features/Onboarding/Views
mkdir -p Features/Onboarding/Components
mkdir -p Features/Onboarding/ViewModels
mkdir -p Features/Home/Views
mkdir -p Features/Home/ViewModels
mkdir -p Features/Profile/Views

# Create Components directories
mkdir -p Components/Buttons
mkdir -p Components/Inputs
mkdir -p Components/Modals

# Create Theme directory
mkdir -p Theme

# Create App directory
mkdir -p App

echo "📁 Folder structure created!"
echo ""
echo "✨ Creating placeholder Swift files..."

# Core/Network files
cat > Core/Network/SupabaseClient.swift << 'EOF'
import Supabase
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://mzqswvyfnblghgvcgxpw.supabase.co")!
        let supabaseKey = "YOUR_ANON_KEY_HERE" // TODO: Add your anon key

        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
EOF

cat > Core/Network/AuthService.swift << 'EOF'
import Supabase
import Foundation

@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    @Published var session: Session?

    private let supabase = SupabaseManager.shared.client

    init() {
        Task {
            await checkSession()
        }
    }

    func checkSession() async {
        do {
            session = try await supabase.auth.session
            user = session?.user
        } catch {
            print("No active session")
        }
    }

    func signUp(email: String, password: String, fullName: String) async throws {
        // TODO: Implement signup
    }

    func signIn(email: String, password: String) async throws {
        // TODO: Implement signin
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        session = nil
        user = nil
    }
}
EOF

cat > Core/Network/DatabaseService.swift << 'EOF'
import Supabase
import Foundation

class DatabaseService {
    private let supabase = SupabaseManager.shared.client

    // TODO: Add database methods

    func fetchListings() async throws -> [Listing] {
        // Implement listing fetch
        return []
    }
}
EOF

# Core/Models files
cat > Core/Models/User.swift << 'EOF'
import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String
    let email: String?
    let fullName: String?
    let displayName: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
    }
}
EOF

cat > Core/Models/Listing.swift << 'EOF'
import Foundation

struct Listing: Codable, Identifiable {
    let id: String
    let address: String
    let price: Int
    let bedrooms: Int
    let bathrooms: Double

    // TODO: Add more fields from your database schema
}
EOF

cat > Core/Models/Agent.swift << 'EOF'
import Foundation

struct Agent: Codable, Identifiable {
    let id: String
    let fullName: String
    let email: String?
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case phone
    }
}
EOF

cat > Core/Models/OnboardingData.swift << 'EOF'
import Foundation

struct OnboardingData {
    var userType: String?
    var doorStyle: String?
    var firstName: String?
    var lastName: String?
    var phone: String?
    var location: String?
    var budgetMin: Int?
    var budgetMax: Int?

    // TODO: Add more fields as needed
}
EOF

# Core/Utilities files
cat > Core/Utilities/Constants.swift << 'EOF'
import Foundation

enum Constants {
    enum API {
        static let supabaseURL = "https://mzqswvyfnblghgvcgxpw.supabase.co"
        static let supabaseAnonKey = "YOUR_ANON_KEY" // TODO: Add key
    }

    enum AppInfo {
        static let bundleID = "ai.homeypocket.HOMEY"
        static let appName = "HOMEY"
    }
}
EOF

cat > Core/Utilities/Extensions.swift << 'EOF'
import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let homeyPrimary = Color(red: 0.6, green: 0.4, blue: 0.9)
    static let homeyAccent = Color(red: 0.9, green: 0.3, blue: 0.5)
    static let homeyBackground = Color.black
}

// MARK: - View Extensions
extension View {
    func homeyStyle() -> some View {
        self
            .foregroundColor(.white)
            .background(Color.homeyBackground)
    }
}
EOF

# Theme files
cat > Theme/Colors.swift << 'EOF'
import SwiftUI

extension Color {
    // Brand colors
    static let homeyPrimary = Color(red: 0.6, green: 0.4, blue: 0.9)
    static let homeyAccent = Color(red: 0.9, green: 0.3, blue: 0.5)

    // Background
    static let homeyBackground = Color.black
    static let homeyCard = Color(white: 1, opacity: 0.1)

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.4)
}
EOF

cat > Theme/Fonts.swift << 'EOF'
import SwiftUI

extension Font {
    static let homeyTitle = Font.custom("PlayfairDisplay-Bold", size: 36)
    static let homeyHeading = Font.custom("PlayfairDisplay-Regular", size: 24)
    static let homeySubheading = Font.system(size: 18, weight: .semibold)
    static let homeyBody = Font.system(size: 16)
    static let homeyCaption = Font.system(size: 14)
}
EOF

cat > Theme/Spacing.swift << 'EOF'
import SwiftUI

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
EOF

cat > Theme/Animations.swift << 'EOF'
import SwiftUI

enum AnimationDuration {
    static let fast: Double = 0.2
    static let medium: Double = 0.3
    static let slow: Double = 0.5
}

extension Animation {
    static let homeySpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let homeyEaseIn = Animation.easeIn(duration: AnimationDuration.medium)
    static let homeyEaseOut = Animation.easeOut(duration: AnimationDuration.medium)
}
EOF

# Components files
cat > Components/Buttons/PrimaryButton.swift << 'EOF'
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(16)
            .opacity(isDisabled || isLoading ? 0.5 : 1)
        }
        .disabled(isDisabled || isLoading)
    }
}
EOF

cat > Components/Inputs/StyledTextField.swift << 'EOF'
import SwiftUI

struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.custom("PlayfairDisplay-Regular", size: 24))
        .foregroundColor(.white)
        .padding(.bottom, 16)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.2)),
            alignment: .bottom
        )
    }
}
EOF

cat > Components/Modals/ErrorModal.swift << 'EOF'
import SwiftUI

struct ErrorModal: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                Text("⚠️")
                    .font(.system(size: 60))

                Text("Oops!")
                    .font(.custom("PlayfairDisplay-Bold", size: 28))
                    .foregroundColor(.white)

                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                PrimaryButton(title: "Try Again", action: onDismiss)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(32)
        }
    }
}
EOF

cat > Components/Modals/ComingSoonModal.swift << 'EOF'
import SwiftUI

struct ComingSoonModal: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                Text("🚀")
                    .font(.system(size: 60))

                Text("Coming Soon")
                    .font(.custom("PlayfairDisplay-Bold", size: 28))
                    .foregroundColor(.white)

                Text("This feature is on its way!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                PrimaryButton(title: "Got it", action: onDismiss)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(32)
        }
    }
}
EOF

# Features/Authentication files
cat > Features/Authentication/Views/LoginView.swift << 'EOF'
import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Color.homeyBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Welcome back")
                    .font(.homeyTitle)
                    .foregroundColor(.textPrimary)

                // TODO: Add login form

                PrimaryButton(title: "Sign In") {
                    // TODO: Implement sign in
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
EOF

cat > Features/Authentication/Views/SignUpView.swift << 'EOF'
import SwiftUI

struct SignUpView: View {
    var body: some View {
        ZStack {
            Color.homeyBackground
                .ignoresSafeArea()

            VStack {
                Text("Create Account")
                    .font(.homeyTitle)
                    .foregroundColor(.textPrimary)

                // TODO: Add signup form
            }
        }
    }
}
EOF

cat > Features/Authentication/Views/AccessCodeView.swift << 'EOF'
import SwiftUI

struct AccessCodeView: View {
    @State private var accessCode = ""

    var body: some View {
        ZStack {
            Color.homeyBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Early Access")
                    .font(.homeyTitle)
                    .foregroundColor(.textPrimary)

                Text("Enter your access code to continue")
                    .font(.homeyBody)
                    .foregroundColor(.textSecondary)

                // TODO: Add access code input
            }
            .padding(.horizontal, 24)
        }
    }
}
EOF

# Features/Onboarding files
cat > Features/Onboarding/Views/WelcomeView.swift << 'EOF'
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Text("Welcome to HOMEY.")
                    .font(.custom("PlayfairDisplay-Regular", size: 36))
                    .foregroundColor(.white)
            }
        }
    }
}
EOF

echo "✅ Project structure created successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Open your Xcode project"
echo "2. In Xcode, go to File > Add Files to 'HOMEY'"
echo "3. Select all the new folders and files"
echo "4. Make sure 'Copy items if needed' is UNCHECKED"
echo "5. Make sure 'Create groups' is selected"
echo "6. Click Add"
echo ""
echo "🎨 Don't forget to:"
echo "- Add Supabase Swift package (https://github.com/supabase/supabase-swift)"
echo "- Add your Supabase anon key to Core/Network/SupabaseClient.swift"
echo "- Add Playfair Display font to your project"
echo ""
echo "🚀 Ready to start building!"
