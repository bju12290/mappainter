import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var isLockedToUser: Bool
    @Binding var userLocation: [IdentifiableLocation]

    let locationManager = CLLocationManager()

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none // Let us handle locking
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if isLockedToUser {
            let region = MKCoordinateRegion(
                center: centerCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        private var lastUpdated: Date = Date.distantPast
        private var lastKnownLocation: CLLocation?

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            // Unlock the map when the user interacts with it
            DispatchQueue.main.async {
                self.parent.isLockedToUser = false
            }
        }

        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            guard let location = userLocation.location else { return }

            // Apply movement filter (ignore minor position changes)
            if let lastLocation = lastKnownLocation {
                let distance = location.distance(from: lastLocation) // Distance in meters
                if distance < 10 { // Ignore movements less than 10 meters
                    return
                }
            }
            lastKnownLocation = location

            // Throttle updates
            let now = Date()
            guard now.timeIntervalSince(lastUpdated) > 0.5 else { return }
            lastUpdated = now

            DispatchQueue.main.async {
                self.parent.userLocation = [IdentifiableLocation(coordinate: location.coordinate)]
                if self.parent.isLockedToUser {
                    self.parent.centerCoordinate = location.coordinate
                }
            }
        }
    }
}
