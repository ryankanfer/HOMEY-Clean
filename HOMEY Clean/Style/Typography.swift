//
//  Typography.swift
//  HOMEY Clean
//
//  Enhanced typography system using Playfair Display for headings
//  and Lato for body text - Modern, Cozy, Efficient, Friendly design
//

import SwiftUI

// This file now imports the consolidated TypographySystem from Core/Design/TypographySystem.swift
// The duplicate TypographySystem enum has been removed to resolve redeclaration errors

// MARK: - Legacy Typography (Deprecated)
@available(*, deprecated, message: "Use TypographySystem and .homeyFont() modifier instead.")
enum Typography {
    static let hero = TypographySystem.hero
    static let title = TypographySystem.title
    static let titleMedium = TypographySystem.titleMedium
    static let subtitle = TypographySystem.subtitle
    static let heading = TypographySystem.heading
    static let bodyLarge = TypographySystem.bodyLarge
    static let body = TypographySystem.body
    static let bodyMedium = TypographySystem.bodyMedium
    static let bodySmall = TypographySystem.bodySmall
    static let caption = TypographySystem.caption
    static let button = TypographySystem.button
    static let buttonLarge = TypographySystem.buttonLarge
    static let buttonSmall = TypographySystem.buttonSmall
    static let navigation = TypographySystem.navigation
    static let tabBar = TypographySystem.tabBar
    static let label = TypographySystem.label
    static let quote = TypographySystem.quote
    static let emphasis = TypographySystem.emphasis
    static let numeric = TypographySystem.numeric
}

// MARK: - Legacy Typography Extensions (Deprecated)
@available(*, deprecated, message: "Use the .homeyFont() modifier instead.")
extension Text {
    func homeyHero() -> Text {
        self.font(Typography.hero)
    }
    
    func homeyTitle() -> Text {
        self.font(Typography.title)
    }
    
    func homeySubtitle() -> Text {
        self.font(Typography.subtitle)
    }
    
    func homeyHeading() -> Text {
        self.font(Typography.heading)
    }
    
    func homeyBody() -> Text {
        self.font(Typography.body)
    }
    
    func homeyBodyLarge() -> Text {
        self.font(Typography.bodyLarge)
    }
    
    func homeyCaption() -> Text {
        self.font(Typography.caption)
    }
    
    func homeyButton() -> Text {
        self.font(Typography.button)
    }
    
    func homeyNavigation() -> Text {
        self.font(Typography.navigation)
    }
}