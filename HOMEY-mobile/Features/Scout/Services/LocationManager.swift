import Foundation
import CoreLocation
import Combine

// MARK: - Location Manager Protocol

protocol LocationManagerProtocol {
    var currentLocation: AnyPublisher<CLLocationCoordinate2D?, Never> { get }
    var currentNeighborhood: AnyPublisher<String, Never> { get }
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }
    
    func requestLocationPermission()
    func startLocationUpdates()
    func stopLocationUpdates()
    func reverseGeocode(coordinate: CLLocationCoordinate2D) -> AnyPublisher<String, Error>
}

// MARK: - Location Manager Implementation

class LocationManager: NSObject, LocationManagerProtocol {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // Publishers
    private let currentLocationSubject = CurrentValueSubject<CLLocationCoordinate2D?, Never>(nil)
    private let currentNeighborhoodSubject = CurrentValueSubject<String, Never>("Unknown")
    private let authorizationStatusSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    var currentLocation: AnyPublisher<CLLocationCoordinate2D?, Never> {
        currentLocationSubject.eraseToAnyPublisher()
    }
    
    var currentNeighborhood: AnyPublisher<String, Never> {
        currentNeighborhoodSubject.eraseToAnyPublisher()
    }
    
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
        setupLocationUpdates()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update every 50 meters
        
        // Set initial authorization status
        authorizationStatusSubject.send(locationManager.authorizationStatus)
    }
    
    private func setupLocationUpdates() {
        // When location changes, update neighborhood
        currentLocation
            .compactMap { $0 }
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .flatMap { [weak self] coordinate -> AnyPublisher<String, Never> in
                guard let self = self else {
                    return Just("Unknown").eraseToAnyPublisher()
                }
                
                return self.reverseGeocode(coordinate: coordinate)
                    .map { $0 }
                    .catch { _ in Just("Unknown") }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] neighborhood in
                self?.currentNeighborhoodSubject.send(neighborhood)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Could show alert to go to settings
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func startLocationUpdates() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) -> AnyPublisher<String, Error> {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return Future<String, Error> { [weak self] promise in
            self?.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    promise(.failure(LocationError.noPlacemarkFound))
                    return
                }
                
                // Try to get neighborhood, sublocality, or locality
                let neighborhood = placemark.subLocality ??
                                 placemark.locality ??
                                 placemark.subAdministrativeArea ??
                                 "Unknown"
                
                promise(.success(neighborhood))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let coordinate = location.coordinate
        currentLocationSubject.send(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        // Could emit error through a separate publisher if needed
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatusSubject.send(status)
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            stopLocationUpdates()
            currentLocationSubject.send(nil)
            currentNeighborhoodSubject.send("Location Access Denied")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Location Error

enum LocationError: Error, LocalizedError {
    case noPlacemarkFound
    case geocodingFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .noPlacemarkFound:
            return "No location information found"
        case .geocodingFailed:
            return "Failed to determine location"
        case .permissionDenied:
            return "Location permission denied"
        }
    }
}

// MARK: - Mock Location Manager for Testing

class MockLocationManager: LocationManagerProtocol {
    private let mockLocationSubject = CurrentValueSubject<CLLocationCoordinate2D?, Never>(nil)
    private let mockNeighborhoodSubject = CurrentValueSubject<String, Never>("Flatiron")
    private let mockAuthStatusSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.authorizedWhenInUse)
    
    var currentLocation: AnyPublisher<CLLocationCoordinate2D?, Never> {
        mockLocationSubject.eraseToAnyPublisher()
    }
    
    var currentNeighborhood: AnyPublisher<String, Never> {
        mockNeighborhoodSubject.eraseToAnyPublisher()
    }
    
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        mockAuthStatusSubject.eraseToAnyPublisher()
    }
    
    init(mockLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.7410, longitude: -73.9896),
         mockNeighborhood: String = "Flatiron") {
        
        // Simulate location updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mockLocationSubject.send(mockLocation)
        }
        
        mockNeighborhoodSubject.send(mockNeighborhood)
    }
    
    func requestLocationPermission() {
        mockAuthStatusSubject.send(.authorizedWhenInUse)
    }
    
    func startLocationUpdates() {
        // Mock implementation - already sending updates
    }
    
    func stopLocationUpdates() {
        mockLocationSubject.send(nil)
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) -> AnyPublisher<String, Error> {
        // Mock neighborhoods based on coordinates
        let neighborhoods = [
            "Flatiron", "Midtown East", "Tribeca", "Gramercy", "West Village",
            "SoHo", "Chelsea", "Upper East Side", "Upper West Side", "Brooklyn Heights"
        ]
        
        let randomNeighborhood = neighborhoods.randomElement() ?? "Flatiron"
        
        return Just(randomNeighborhood)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}