
HOMEY Liquid Glass Pack (iOS 26)
What’s inside
- GlassKit.swift: GlassBackground, GlassCard, GlassChip, GlassButtonStyle, GlassNavBar
- ScoutReviewView.swift: drop-in replacement using the glass components
- GlassRootOverlay.swift: optional wrapper to give any screen a glass background

How to install (2 minutes)
1) Drag these files into your HOMIE app target (do NOT add to the Share Extension).
2) In any view you want full-bleed glass, wrap your content in GlassRootOverlay:
   GlassRootOverlay { RootViewContent() }
   or set your root ZStack background to GlassBackground().ignoresSafeArea().
3) Use GlassCard/GlassChip/GlassButtonStyle in key surfaces (Scout, Paige, Charlie).

Notes
- These use system materials (.thinMaterial / .ultraThinMaterial) so they auto-adapt to iOS 26’s look.
- No dependencies, pure SwiftUI.
