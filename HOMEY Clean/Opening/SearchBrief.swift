import Foundation

// Lightweight filter model used across search components
struct LocalSearchFilters {
    var neighborhood: String?
    var minBeds: Int?
    var minBaths: Int?
    var minPrice: Int?
    var maxPrice: Int?
    // true = Rent, false = Buy, nil = unknown
    var isRent: Bool?
    // Canonical amenity names (e.g., "Elevator", "Laundry")
    var amenities: Set<String>

    // Backward-compatible initializer used throughout the app
    init(
        neighborhood: String?,
        minBeds: Int?,
        minBaths: Int?,
        minPrice: Int?,
        maxPrice: Int?,
        isRent: Bool? = nil,
        amenities: Set<String> = []
    ) {
        self.neighborhood = neighborhood
        self.minBeds = minBeds
        self.minBaths = minBaths
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.isRent = isRent
        self.amenities = amenities
    }
}

// Parser and formatter utilities for the natural-language brief
enum SearchBrief {
    // Human-friendly thousands formatting (e.g., 2500 -> 2.5k)
    static func k(_ v: Int) -> String {
        if v % 1000 == 0 { return "\(v/1000)k" }
        let thousands = Double(v) / 1000.0
        return String(format: "%.1fk", thousands)
    }

    // Merge two LocalSearchFilters, giving priority to the first
    static func mergeFilters(priority: LocalSearchFilters, fallback: LocalSearchFilters) -> LocalSearchFilters {
        LocalSearchFilters(
            neighborhood: priority.neighborhood ?? fallback.neighborhood,
            minBeds: priority.minBeds ?? fallback.minBeds,
            minBaths: priority.minBaths ?? fallback.minBaths,
            minPrice: priority.minPrice ?? fallback.minPrice,
            maxPrice: priority.maxPrice ?? fallback.maxPrice,
            isRent: priority.isRent ?? fallback.isRent,
            amenities: priority.amenities.union(fallback.amenities)
        )
    }

    // Build a natural language string from filters, merging with any extra free text from existing
    static func synthesizeBrief(from f: LocalSearchFilters, existing: String) -> String {
        var parts: [String] = []
        if let b = f.minBeds { parts.append("\(b) bed") }
        if let b = f.minBaths { parts.append("\(b) bath") }
        if let n = f.neighborhood, !n.isEmpty { parts.append(n) }
        if let lo = f.minPrice, let hi = f.maxPrice, hi >= lo {
            parts.append("\(k(lo))–\(k(hi))")
        } else if let lo = f.minPrice {
            parts.append("min \(k(lo))")
        } else if let hi = f.maxPrice {
            parts.append("max \(k(hi))")
        }

        if let isRent = f.isRent {
            parts.append(isRent ? "rent" : "buy")
        }

        // Include up to three amenities for readability
        if !f.amenities.isEmpty {
            let top = Array(f.amenities.prefix(3))
            parts.append(top.joined(separator: ", "))
        }

        // Preserve extra tokens from existing that aren’t structured (very light heuristic)
        let structuredTokens = Set(parts.map { $0.lowercased() })
        let extras = existing
            .split(separator: " ")
            .map(String.init)
            .filter { token in
                let lc = token.lowercased()
                return !structuredTokens.contains(lc)
            }

        let combined = (parts + extras).joined(separator: ", ")
        return combined.isEmpty ? existing : combined
    }

    // Neighborhoods (case-insensitive matching)
    private static let neighborhoods: [String] = {
        let manhattan = [
            "Alphabet City","Battery Park City","Bowery","Chelsea","Chinatown","East Village",
            "Gramercy Park","Harlem","Hudson Yards","Inwood","Kips Bay","Lower East Side",
            "Midtown","Morningside Heights","NoHo","SoHo","Tribeca","Upper East Side",
            "Upper West Side","West Village","Yorkville"
        ]
        let brooklyn = [
            "Bay Ridge","Bedford-Stuyvesant","Boerum Hill","Brooklyn Heights","Bushwick",
            "Carroll Gardens","Cobble Hill","Coney Island","Crown Heights","DUMBO",
            "East New York","Fort Greene","Gowanus","Greenpoint","Midwood","Park Slope",
            "Prospect Heights","Red Hook","Sunset Park","Williamsburg"
        ]
        let queens = [
            "Astoria","Bayswater","Belle Harbor","Breezy Point","Corona","Elmhurst",
            "Flushing","Forest Hills","Glendale","Jackson Heights","Jamaica",
            "Kew Gardens","Long Island City","Maspeth","Neponsit","Ozone Park",
            "Rego Park","Ridgewood","Sunnyside","Woodside"
        ]
        return (manhattan + brooklyn + queens)
    }()

    // Parse the brief into structured filters only (no residual text)
    static func parseBrief(_ text: String) -> LocalSearchFilters {
        var result = LocalSearchFilters(neighborhood: nil, minBeds: nil, minBaths: nil, minPrice: nil, maxPrice: nil, isRent: nil, amenities: [])
        let lower = text.lowercased()

        // Neighborhood detection: prefer longest match to avoid partials
        let sortedNeighborhoods = neighborhoods.sorted { $0.count > $1.count }
        if let match = sortedNeighborhoods.first(where: { lower.contains($0.lowercased()) }) {
            result.neighborhood = match
        }

        // Beds: e.g., "2 bed", "3 beds", "2bd", "2 br"
        if let beds = matchInt(in: lower, patterns: [
            #"(\d+)\s*beds?\b"#,
            #"(\d+)\s*bd\b"#,
            #"(\d+)\s*br\b"#
        ]) {
            result.minBeds = beds
        }

        // Baths: "1 bath", "1.5 baths", "1ba"
        if let bathsStr = matchFirstCapture(in: lower, patterns: [
            #"(\d+(\.\d+)?)\s*baths?\b"#,
            #"(\d+(\.\d+)?)\s*ba\b"#
        ]) {
            if let bathsDouble = Double(bathsStr) {
                result.minBaths = Int(ceil(bathsDouble))
            }
        }

        // Price range: "$1m–$2m", "$500k-$800k", "$2,000–$3,500"
        if let (lo, hi) = matchPriceRange(in: lower) {
            result.minPrice = lo
            result.maxPrice = hi
        } else {
            // Min-only: "over $2m", "min $500k"
            if let minOnly = matchSinglePrice(in: lower, patterns: [
                #"(?:(?:over|min)\s*\$)([0-9\.,]+[mk]?)"#,
                #"min\s*([0-9\.,]+[mk]?)"#
            ]) {
                result.minPrice = minOnly
            }
            // Max-only: "under $3k", "max $4k"
            if let maxOnly = matchSinglePrice(in: lower, patterns: [
                #"(?:(?:under|max)\s*\$)([0-9\.,]+[mk]?)"#,
                #"max\s*([0-9\.,]+[mk]?)"#
            ]) {
                result.maxPrice = maxOnly
            }
        }

        // Market type inference (rent vs buy)
        result.isRent = inferMarketType(min: result.minPrice, max: result.maxPrice, text: lower)

        // Amenity parsing
        for (key, display) in amenityDictionary {
            if lower.contains(key) {
                result.amenities.insert(display)
            }
        }

        return result
    }

    // MARK: - Regex / Price helpers

    private static func matchInt(in text: String, patterns: [String]) -> Int? {
        if let s = matchFirstCapture(in: text, patterns: patterns) {
            return Int(s)
        }
        return nil
    }

    private static func matchFirstCapture(in text: String, patterns: [String]) -> String? {
        for pattern in patterns {
            if let r = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                if let m = r.firstMatch(in: text, options: [], range: range),
                   m.numberOfRanges >= 2,
                   let r1 = Range(m.range(at: 1), in: text) {
                    return String(text[r1])
                }
            }
        }
        return nil
    }

    // Parse "$1m–$2m", "$500k-$800k", "$2,000–$3,500"
    private static func matchPriceRange(in text: String) -> (Int, Int)? {
        let patterns = [
            #"\$([0-9\.,]+[mk]?)\s*[-–—]\s*\$?([0-9\.,]+[mk]?)"#
        ]
        for pattern in patterns {
            if let r = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                if let m = r.firstMatch(in: text, options: [], range: range),
                   m.numberOfRanges >= 3,
                   let r1 = Range(m.range(at: 1), in: text),
                   let r2 = Range(m.range(at: 2), in: text) {
                    let lo = parseMoneyToken(String(text[r1]))
                    let hi = parseMoneyToken(String(text[r2]))
                    if let lo, let hi, hi >= lo { return (lo, hi) }
                }
            }
        }
        return nil
    }

    // Parse a single captured money token using provided patterns
    // Returns integer dollars for matches like "min $500k", "under $3k"
    private static func matchSinglePrice(in text: String, patterns: [String]) -> Int? {
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                if let m = regex.firstMatch(in: text, options: [], range: range),
                   m.numberOfRanges >= 2,
                   let r1 = Range(m.range(at: 1), in: text) {
                    let token = String(text[r1])
                    if let v = parseMoneyToken(token) { return v }
                }
            }
        }
        return nil
    }

    // Infer market type using tokens and price magnitudes
    // Heuristics:
    // - Explicit tokens override ("rent", "buy", "sale")
    // - Prices < 50k -> likely rent (monthly), >= 100k -> likely buy (sale)
    private static func inferMarketType(min: Int?, max: Int?, text: String) -> Bool? {
        if text.contains("rent") { return true }
        if text.contains("buy") || text.contains("sale") { return false }

        let candidates = [min, max].compactMap { $0 }
        guard !candidates.isEmpty else { return nil }
        let hi = candidates.max()!
        let lo = candidates.min()!
        if hi < 50_000 { return true }
        if lo >= 100_000 { return false }
        return nil
    }

    // Amenity keywords mapping to canonical display names
    private static let amenityDictionary: [String: String] = [
        "elevator": "Elevator",
        "laundry": "Laundry",
        "pet friendly": "Pet friendly",
        "doorman": "Doorman",
        "parking": "Parking",
        "dishwasher": "Dishwasher",
        "balcony": "Balcony",
        "gym": "Gym"
    ]

    // Suggest amenities not yet selected; prioritize common ones
    static func suggestedAmenities(from text: String, existing: Set<String>) -> [String] {
        var suggestions: [String] = []
        let lower = text.lowercased()
        // If text mentions any amenity we surface it first, else use common defaults
        for (key, display) in amenityDictionary {
            if lower.contains(key) && !existing.contains(display) {
                suggestions.append(display)
            }
        }
        let common = ["Elevator", "Laundry", "Pet friendly", "Doorman", "Parking"]
        for item in common where !existing.contains(item) && !suggestions.contains(item) {
            suggestions.append(item)
        }
        return Array(suggestions.prefix(5))
    }

    // Parse single price like "under $3k", "over $2m", "max $4k", "min $500k"
    static func parseMoneyToken(_ s: String) -> Int? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.hasSuffix("m") {
            let num = trimmed.dropLast()
            if let d = Double(num.replacingOccurrences(of: ",", with: "")) {
                return Int(d * 1_000_000)
            }
        } else if trimmed.hasSuffix("k") {
            let num = trimmed.dropLast()
            if let d = Double(num.replacingOccurrences(of: ",", with: "")) {
                return Int(d * 1_000)
            }
        } else {
            if let d = Double(trimmed.replacingOccurrences(of: ",", with: "")) {
                return Int(d)
            }
        }
        return nil
    }
}