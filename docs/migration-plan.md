# Migration plan: legacy/homey-old → HOMEY Clean

## Dependency graph
Style primitives → Dashboard shells → Auth shells → RoleSelection → Charlie onboarding

## 1. Style primitives
- **Files**
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/Core/Theme.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/Liquid Glass Footer Pack/GlassFooterItem.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/Liquid Glass Footer Pack/GlassScaffold.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/GlassKitFallback.swift`
  - Typography: no direct legacy file – create `Style/Typography.swift`
- **Incompatibilities**
  - Depends on `HomeyKind` enum (missing in Clean)
  - Uses asset names not yet in Clean asset catalog
- **Adaptation steps**
  - Port `GradientBackground`, `HeroHeader`, `withGlassScaffold` and glass components into `Style/`
  - Introduce `HomeyKind` stub with placeholder images
  - Create `Typography` struct with standard `Font` constants
- **Unit tests**
  - Verify `GradientBackground` animates between top/bottom colors
  - Snapshot test that `withGlassScaffold` wraps content with footer items

## 2. Dashboard shells (Client, Agent, Admin)
- **Files**
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/Client/ClientDashboardView.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/Agent/AgentDashboardView.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/Admin/AdminDashboardView.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/AvatarStrip.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/SharedDashboardKit.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/HomeyKind.swift`
- **Incompatibilities**
  - Relies on non‑existent types (`TasteStore`, `JourneyWatcher`, `MatchesView`, `session.logout()`, etc.)
  - Uses complex `AppState` not present in Clean
- **Adaptation steps**
  - Strip to layout + navigation placeholders using `withGlassScaffold`
  - Replace missing dependencies with simple mocks
  - Implement minimal `AppState`/`SessionManager` hooks for role switching
- **Unit tests**
  - Assert each dashboard loads with header and footer scaffold
  - Verify role switch updates displayed dashboard

## 3. Auth flow shells (CreateAccountView, LoginView)
- **Files**
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/CreateAccountView.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY All OS/HOMEY/Pages/Welcome Screen/LoginView.swift`
- **Incompatibilities**
  - Legacy views call real auth APIs; Clean requires offline mock
  - Uses `LiquidGlassBackground`/`GlassGroupBox` from style module
- **Adaptation steps**
  - Rebuild forms using glass components, but replace networking with placeholder view models returning mock success
  - Hook submit buttons to `SessionManager` stubs
- **Unit tests**
  - Form validation for required fields
  - Login view shows error on empty credentials

## 4. RoleSelection
- **Files**
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/OnBoarding/OnboardingScreens.swift` (RoleSelectionView section)
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/OnBoarding/OnboardingModels.swift` (UserRole)
- **Incompatibilities**
  - Depends on `agentModeEnabled` flag and full onboarding data model
- **Adaptation steps**
  - Extract `RoleSelectionView` into standalone shell with simple `Binding<UserRole?>`
  - Provide `UserRole` enum and minimal data holder
- **Unit tests**
  - Selecting a role updates binding
  - Disabled rows remain non‑interactive when `agentModeEnabled` is false

## 5. Charlie onboarding
- **Files**
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/OnBoarding/OnboardingCoordinator.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/OnBoarding/BudgetRealityScreens.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/OnBoarding/PreferencesReviewDashboard.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/OnBoarding/Components.swift`
  - `legacy/homey-old/HOMEY Dev/HOMEY iOS/HOMEY iOS/OnBoarding/OnboardingModels.swift`
- **Incompatibilities**
  - Uses PhotosPicker, notifications, and Lottie placeholders absent in Clean
  - Requires navigation to dashboards not yet implemented
- **Adaptation steps**
  - Port coordinator and screens as SwiftUI shells, stubbing photo/notification APIs
  - Replace final dashboard routing with placeholder view
- **Unit tests**
  - Navigation flow: entering referral enables forward navigation
  - Renter budget screen computes 40× income check

## File map
| Legacy path | New path | Action | Risk |
|-------------|----------|--------|------|
| `Core/Theme.swift` | `Style/Theme.swift` | adapt | medium |
| `GlassFooterItem.swift` | `Style/GlassFooter.swift` | adapt | medium |
| `GlassScaffold.swift` | `Style/GlassScaffold.swift` | adapt | medium |
| `GlassKitFallback.swift` | `Style/GlassComponents.swift` | adapt | low |
| _none_ (Typography) | `Style/Typography.swift` | new | high |
| `Client/ClientDashboardView.swift` | `Dashboards/ClientDashboardView.swift` | adapt | high |
| `Agent/AgentDashboardView.swift` | `Dashboards/AgentDashboardView.swift` | adapt | high |
| `Admin/AdminDashboardView.swift` | `Dashboards/AdminDashboardView.swift` | adapt | high |
| `AvatarStrip.swift` | `Dashboards/AvatarStrip.swift` | adapt | medium |
| `SharedDashboardKit.swift` | `Dashboards/SharedDashboardKit.swift` | adapt | medium |
| `HomeyKind.swift` | `Models/HomeyKind.swift` | copy | low |
| `CreateAccountView.swift` | `Auth/CreateAccountView.swift` | adapt | medium |
| `Pages/Welcome Screen/LoginView.swift` | `Auth/LoginView.swift` | adapt | medium |
| `OnboardingScreens.swift` (RoleSelection) | `Onboarding/RoleSelectionView.swift` | adapt | medium |
| `OnboardingModels.swift` | `Onboarding/OnboardingModels.swift` | adapt | medium |
| `OnboardingCoordinator.swift` | `Onboarding/OnboardingCoordinator.swift` | adapt | high |
| `BudgetRealityScreens.swift` | `Onboarding/BudgetRealityScreens.swift` | adapt | high |
| `PreferencesReviewDashboard.swift` | `Onboarding/PreferencesReviewDashboard.swift` | adapt | high |
| `Components.swift` | `Onboarding/Components.swift` | adapt | medium |
