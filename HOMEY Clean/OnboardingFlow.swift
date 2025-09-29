// OnboardingFlow.swift
// Backwards-compatibility shim: the legacy `OnboardingFlow` has been
// replaced by `ComprehensiveOnboardingFlow`. Keep this typealias so
// existing call sites (e.g., RootView) continue to compile.

import SwiftUI

@available(*, deprecated, renamed: "ComprehensiveOnboardingFlow")
typealias OnboardingFlow = ComprehensiveOnboardingFlow
