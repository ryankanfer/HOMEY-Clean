import Foundation
import CoreLocation
import WeatherKit

final class AppWeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
    enum Condition { case clear, rain, snow, fog, cloudy }

    static let shared = AppWeatherService()

    private let weatherService = WeatherService.shared
    private let locationManager = CLLocationManager()
    private var lastCondition: Condition = .clear

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func fetchCurrent(completion: @escaping (Condition) -> Void) {
        // If we already have a recent condition, return it quickly while refreshing.
        completion(lastCondition)
        requestLocationIfNeeded()
        guard let loc = locationManager.location else {
            // fallback clear
            completion(.clear)
            return
        }
        Task { @MainActor in
            do {
                let weather = try await weatherService.weather(for: loc)
                let mapped = Self.mapToCondition(weather.currentWeather)
                self.lastCondition = mapped
                completion(mapped)
            } catch {
                // Fallback to clear if WeatherKit fails (simulator/entitlements)
                completion(.clear)
            }
        }
    }

    private func requestLocationIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            if locationManager.location == nil {
                locationManager.requestLocation()
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    private static func mapToCondition(_ current: CurrentWeather) -> Condition {
        switch current.condition {
        // Clear-ish skies
        case .clear, .mostlyClear:
            return .clear

        // Cloud cover
        case .partlyCloudy, .mostlyCloudy, .cloudy:
            return .cloudy

        // Precipitation (rain)
        case .drizzle, .rain, .heavyRain, .freezingRain:
            return .rain

        // Snow conditions
        case .flurries, .snow, .heavySnow:
            return .snow

        // Fallback for any other or newer conditions (including fog/haze/smoke variants on newer SDKs)
        @unknown default:
            return .clear
        }
    }
}
