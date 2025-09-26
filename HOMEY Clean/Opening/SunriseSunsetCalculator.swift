import Foundation

struct SunriseSunsetCalculator {
    struct Result { let sunrise: Date?, sunset: Date? }

    // NOAA algorithm approximation. Returns local times for the provided timezone.
    func sunriseSunset(for date: Date, latitude: Double, longitude: Double, timeZone: TimeZone) -> Result {
        let cal = Calendar(identifier: .gregorian)
        let dayStart = cal.startOfDay(for: date)
        let N = Double(cal.ordinality(of: .day, in: .year, for: dayStart) ?? 1)
        let lngHour = longitude / 15.0
        let zenith = 90.833 // civil twilight

        func compute(isSunrise: Bool) -> Date? {
            // 1) Approximate time
            let t = N + ((isSunrise ? 6.0 : 18.0) - lngHour) / 24.0
            // 2) Sun's mean anomaly
            var M = (0.9856 * t) - 3.289
            // 3) Sun's true longitude
            var L = M + (1.916 * sin(deg2rad(M))) + (0.020 * sin(deg2rad(2 * M))) + 282.634
            L = normalizeDegrees(L)
            // 4) Right ascension
            var RA = rad2deg(atan(0.91764 * tan(deg2rad(L))))
            RA = normalizeDegrees(RA)
            // quadrant correction
            let Lquadrant = floor(L / 90.0) * 90.0
            let RAquadrant = floor(RA / 90.0) * 90.0
            RA += (Lquadrant - RAquadrant)
            RA /= 15.0 // convert to hours
            // 5) Declination
            let sinDec = 0.39782 * sin(deg2rad(L))
            let cosDec = cos(asin(sinDec))
            // 6) Local hour angle
            let cosH = (cos(deg2rad(zenith)) - (sinDec * sin(deg2rad(latitude)))) / (cosDec * cos(deg2rad(latitude)))
            if cosH > 1 || cosH < -1 { return nil } // Polar day/night
            var H = isSunrise ? (360.0 - rad2deg(acos(cosH))) : rad2deg(acos(cosH))
            H /= 15.0
            // 7) Local mean time
            let T = H + RA - (0.06571 * t) - 6.622
            // 8) UTC
            var UT = T - lngHour
            UT = fmod(UT + 24.0, 24.0)
            // Build date with hour/minute
            let seconds = Int(UT * 3600.0)
            let components = DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: cal.component(.year, from: dayStart), month: cal.component(.month, from: dayStart), day: cal.component(.day, from: dayStart), hour: seconds / 3600, minute: (seconds % 3600) / 60, second: seconds % 60)
            if let utcDate = cal.date(from: components) {
                let offset = TimeInterval(timeZone.secondsFromGMT(for: utcDate))
                return Date(timeInterval: offset, since: utcDate)
            }
            return nil
        }

        let sr = compute(isSunrise: true)
        let ss = compute(isSunrise: false)
        return Result(sunrise: sr, sunset: ss)
    }

    private func deg2rad(_ deg: Double) -> Double { deg * .pi / 180.0 }
    private func rad2deg(_ rad: Double) -> Double { rad * 180.0 / .pi }
    private func normalizeDegrees(_ deg: Double) -> Double {
        var d = deg
        while d < 0 { d += 360 }
        while d >= 360 { d -= 360 }
        return d
    }
}
