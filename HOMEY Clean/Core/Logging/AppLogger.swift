import Foundation
import OSLog

enum LogCategory: String {
    case navigation
    case sheets
    case ar
    case vision
    case errors
    case lifecycle
}

enum Loggers {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.homey.app"

    static let navigation = Logger(subsystem: subsystem, category: LogCategory.navigation.rawValue)
    static let sheets = Logger(subsystem: subsystem, category: LogCategory.sheets.rawValue)
    static let ar = Logger(subsystem: subsystem, category: LogCategory.ar.rawValue)
    static let vision = Logger(subsystem: subsystem, category: LogCategory.vision.rawValue)
    static let errors = Logger(subsystem: subsystem, category: LogCategory.errors.rawValue)
    static let lifecycle = Logger(subsystem: subsystem, category: LogCategory.lifecycle.rawValue)
}