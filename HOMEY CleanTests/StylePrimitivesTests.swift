import Testing
@testable import HOMEY_Clean
import SwiftUI

struct StylePrimitivesTests {
    @Test func gradientBackgroundAnimates() throws {
        let bg = GradientBackground(top: .red, bottom: .blue)
        #expect(bg.initialColors == [.red, .blue])
        #expect(bg.toggledColors == [.blue, .red])
    }

    @Test func glassScaffoldItemCount() throws {
        let items = [
            GlassFooterItem(systemImage: "1.circle", title: "One"),
            GlassFooterItem(systemImage: "2.circle", title: "Two"),
            GlassFooterItem(systemImage: "3.circle", title: "Three")
        ]
        let view = Text("Content").withGlassScaffold(items)
        #expect(view.footerItems.count == items.count)
    }
}
