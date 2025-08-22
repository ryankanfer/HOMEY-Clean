// Spacing.swift
import SwiftUI

/// Semantic spacing tokens for consistent layout
public enum Spacing {
    /// 4pt - Tight spacing for chips, pills
    public static let xs: CGFloat = 4
    /// 8pt - Small spacing for list items, form elements
    public static let sm: CGFloat = 8
    /// 12pt - Medium spacing for cards, sections
    public static let md: CGFloat = 12
    /// 16pt - Standard spacing for screen padding
    public static let lg: CGFloat = 16
    /// 24pt - Large spacing for major sections
    public static let xl: CGFloat = 24
    /// 32pt - Extra large spacing for hero sections
    public static let xxl: CGFloat = 32
}

public extension View {
    /// Standard screen padding (16pt)
    func padScreen() -> some View {
        padding(Spacing.lg)
    }

    /// Card padding (12pt)
    func padCard() -> some View {
        padding(Spacing.md)
    }

    /// Section spacing (24pt)
    func padSection() -> some View {
        padding(Spacing.xl)
    }
}
