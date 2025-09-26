import Foundation
import CoreLocation
import Combine

final class TimeOfDayService: NSObject, ObservableObject {
    enum Phase: String { case sunrise, day, sunset, night }

    static let shared = TimeOfDayService()

    @Published private(set) var phase: Phase = .day
    @Published private(set) var phaseProgress: Double = 0.0 // 0..1 within current phase
    @Published private(set) var sunrise: Date?
    @Published private(set) var sunset: Date?

    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private var timer: Timer?

    // Phase window padding in minutes
    private let twilightPadding: TimeInterval = 45 * 60 // 45 minutes around sunrise/sunset

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        requestLocation()
        startTicker()
    }

    deinit { timer?.invalidate() }

    // MARK: - Public helpers

    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            // Will fall back to hour-based mapping
            break
        }
    }

    // MARK: - Internals

    private func startTicker() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updatePhase()
        }
        updatePhase()
    }

    private func refreshSolarTimesIfNeeded(for date: Date = Date()) {
        guard let loc = location else { return }
        // Recompute at least once per day or when we first get a location
        let cal = Calendar.current
        if sunrise == nil || sunset == nil || !(sunrise.map { cal.isDate($0, inSameDayAs: date) } ?? false) {
            let calc = SunriseSunsetCalculator()
            let result = calc.sunriseSunset(for: date, latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, timeZone: TimeZone.current)
            sunrise = result.sunrise
            sunset = result.sunset
        }
    }

    private func updatePhase(date: Date = Date()) {
        refreshSolarTimesIfNeeded(for: date)
        let cal = Calendar.current

        // If we have solar times, build phase windows with twilight padding
        if let sr = sunrise, let ss = sunset {
            let sunriseStart = sr.addingTimeInterval(-twilightPadding)
            let sunriseEnd = sr.addingTimeInterval(twilightPadding)
            let sunsetStart = ss.addingTimeInterval(-twilightPadding)
            let sunsetEnd = ss.addingTimeInterval(twilightPadding)

            let p: Phase
            let progress: Double

            if date >= sunriseStart && date <= sunriseEnd {
                p = .sunrise
                progress = normalizedProgress(date, start: sunriseStart, end: sunriseEnd)
            } else if date > sunriseEnd && date < sunsetStart {
                p = .day
                progress = normalizedProgress(date, start: sunriseEnd, end: sunsetStart)
            } else if date >= sunsetStart && date <= sunsetEnd {
                p = .sunset
                progress = normalizedProgress(date, start: sunsetStart, end: sunsetEnd)
            } else {
                // Night spans from sunsetEnd to next sunriseStart
                let nextSunriseStart: Date = {
                    guard let nextSR = cal.date(byAdding: .day, value: (date > sunriseStart ? 1 : 0), to: sunriseStart) else { return date }
                    return nextSR
                }()
                let nightStart = sunsetEnd
                let nightEnd = nextSunriseStart
                p = .night
                progress = normalizedProgress(date, start: nightStart, end: nightEnd)
            }

            publish(p, progress: progress)
            return
        }

        // Fallback: simple hour-based mapping
        let hour = cal.component(.hour, from: date)
        let p: Phase
        switch hour {
        case 5..<7: p = .sunrise
        case 7..<17: p = .day
        case 17..<20: p = .sunset
        default: p = .night
        }
        publish(p, progress: 0.5)
    }

    private func normalizedProgress(_ now: Date, start: Date, end: Date) -> Double {
        guard end > start else { return 0.5 }
        let total = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        return min(max(elapsed / total, 0), 1)
    }

    private func publish(_ newPhase: Phase, progress: Double) {
        if phase != newPhase { phase = newPhase }
        if abs(phaseProgress - progress) > 0.001 { phaseProgress = progress }
    }
}

// MARK: - CLLocationManagerDelegate
extension TimeOfDayService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways { manager.requestLocation() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let best = locations.last {
            location = best
            sunrise = nil
            sunset = nil
            updatePhase()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fall back to hour-based mapping
        updatePhase()
    }
}
