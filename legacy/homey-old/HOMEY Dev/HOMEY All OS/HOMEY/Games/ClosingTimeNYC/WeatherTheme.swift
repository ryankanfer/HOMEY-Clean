
import Foundation
import SwiftUI

enum WeatherKind: CaseIterable { case clear, rain, snow, heat }
enum TimeBand { case day, night }

struct WeatherTheme: Equatable {
    let time: TimeBand
    let weather: WeatherKind

    static func current() -> WeatherTheme {
        let hour = Calendar.current.component(.hour, from: Date())
        let time: TimeBand = (7 ... 18).contains(hour) ? .day : .night
        let weather = [WeatherKind.clear, .rain, .snow, .heat].randomElement()!
        return WeatherTheme(time: time, weather: weather)
    }
}
