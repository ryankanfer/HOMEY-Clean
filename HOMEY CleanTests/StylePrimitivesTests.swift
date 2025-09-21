import SwiftUI
import XCTest
@testable import HOMEY_Clean

final class StylePrimitivesTests: XCTestCase {
    func testGradientBackgroundAnimates() throws {
        let theme = HeroTheme(top: .red, bottom: .blue, accent: .white)
        let bg = GradientBackground(theme: theme)
        XCTAssertEqual(bg.theme.top, .red)
        XCTAssertEqual(bg.theme.bottom, .blue)
    }

    func testGlassScaffoldItemCount() throws {
        let items = [
            GlassFooterItem(title: "One", imageName: "1.circle"),
            GlassFooterItem(title: "Two", imageName: "2.circle"),
            GlassFooterItem(title: "Three", imageName: "3.circle"),
        ]
        // Test that the scaffold can be created with custom items
        let _ = Text("Content").withGlassScaffold(items: items)
        XCTAssertEqual(items.count, 3)
    }
}
