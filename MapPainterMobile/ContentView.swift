import SwiftUI
import MapKit

// Identifiable wrapper for user location
struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D(
        latitude: 37.7749, // Default fallback (San Francisco)
        longitude: -122.4194
    )
    @State private var isLockedToUser = true
    @State private var userLocation: [IdentifiableLocation] = []

    var body: some View {
        ZStack {
            // Custom MapView
            MapView(
                centerCoordinate: $centerCoordinate,
                isLockedToUser: $isLockedToUser,
                userLocation: $userLocation
            )
            .edgesIgnoringSafeArea(.all)

            // Re-lock button
            if !isLockedToUser {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: reLock) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
        }
    }

    private func reLock() {
        if let userCoordinate = userLocation.first?.coordinate {
            centerCoordinate = userCoordinate // Update to the user's latest location
            isLockedToUser = true
        }
    }
}
