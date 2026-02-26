//
//  MapsURLOpener.swift
//  LeaveNow
//

import Foundation
import UIKit
import MapKit
import CoreLocation

/// Opens the local Apple Maps or Google Maps app with driving directions. No API key required.
enum MapsURLOpener {
    /// Open directions in the selected map app (Apple Maps or Google Maps).
    static func openDirections(origin: String, destination: String, provider: MapProvider) {
        switch provider {
        case .apple:
            openInAppleMaps(origin: origin, destination: destination)
        case .google:
            openInGoogleMaps(origin: origin, destination: destination)
        }
    }

    /// Open Google Maps app with driving directions (uses local app, no API key).
    static func openInGoogleMaps(origin: String, destination: String) {
        let s = origin.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? origin
        let d = destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? destination
        let urlString = "comgooglemaps://?saddr=\(s)&daddr=\(d)&directionsmode=driving"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback: open in browser
            let fallback = "https://www.google.com/maps/dir/?api=1&origin=\(s)&destination=\(d)&travelmode=driving"
            if let url = URL(string: fallback) {
                UIApplication.shared.open(url)
            }
        }
    }

    /// Open Apple Maps app with driving directions.
    static func openInAppleMaps(origin: String, destination: String) {
        Task { @MainActor in
            let geocoder = CLGeocoder()
            guard let oMarks = try? await geocoder.geocodeAddressString(origin),
                  let dMarks = try? await geocoder.geocodeAddressString(destination),
                  let o = oMarks.first?.location,
                  let d = dMarks.first?.location else { return }
            let start = MKMapItem(placemark: MKPlacemark(coordinate: o.coordinate, addressDictionary: nil))
            start.name = origin
            let end = MKMapItem(placemark: MKPlacemark(coordinate: d.coordinate, addressDictionary: nil))
            end.name = destination
            MKMapItem.openMaps(with: [start, end], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}
