//
//  LocationManager.swift
//  MapPainterMobile
//
//  Created by Brian Hartnett on 11/16/24.
//

import CoreLocation
import Combine

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Request location access
        locationManager.startUpdatingLocation() // Start receiving location updates
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Add debounce logic
        let newCoordinate = location.coordinate
        DispatchQueue.main.async {
            if self.currentLocation != newCoordinate {
                self.currentLocation = newCoordinate
            }
        }
    }
}

