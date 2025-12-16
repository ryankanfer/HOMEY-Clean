import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public extension Font {
    static func playfairDisplayBold(_ size: CGFloat) -> Font {
        #if canImport(UIKit)
        if UIFont(name: "PlayfairDisplay-Bold", size: size) != nil {
            return .custom("PlayfairDisplay-Bold", size: size)
        }
        if UIFont(name: "PlayfairDisplay-SemiBold", size: size) != nil {
            return .custom("PlayfairDisplay-SemiBold", size: size)
        }
        if UIFont(name: "PlayfairDisplay-Regular", size: size) != nil {
            return .custom("PlayfairDisplay-Regular", size: size)
        }
        #endif
        return .system(size: size, weight: .bold, design: .serif)
    }
}
