//
//  LocationSearchService.swift
//  LeaveNow
//

import Foundation
import Combine
import MapKit
import CoreLocation
import Contacts

/// Address autocomplete and geocoding via Apple MapKit.
@MainActor
final class LocationSearchService: NSObject, ObservableObject {
    @Published var completions: [MapSearchSuggestion] = []
    @Published var isSearching = false

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func setQuery(_ query: String) {
        guard query.count >= 2 else {
            completions = []
            return
        }
        isSearching = true
        completer.queryFragment = query
    }

    func clearCompletions() {
        completions = []
    }

    func resolveAddress(from suggestion: MapSearchSuggestion) async -> String? {
        guard case .apple(let completion) = suggestion else { return nil }
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            guard let item = response.mapItems.first else { return nil }
            return formatAddress(from: item.placemark)
        } catch { return nil }
    }

    func resolveMapItem(from suggestion: MapSearchSuggestion) async -> (address: String, coordinate: CLLocationCoordinate2D)? {
        guard case .apple(let completion) = suggestion else { return nil }
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            guard let item = response.mapItems.first else { return nil }
            return (formatAddress(from: item.placemark), item.placemark.coordinate)
        } catch { return nil }
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let pm = placemarks.first else { return nil }
            let mk = MKPlacemark(placemark: pm)
            return formatAddress(from: mk)
        } catch { return nil }
    }

    private func formatAddress(from placemark: MKPlacemark) -> String {
        if #available(iOS 11.0, *), let postal = placemark.postalAddress {
            let formatter = CNPostalAddressFormatter()
            return formatter.string(from: postal)
                .replacingOccurrences(of: "\n", with: ", ")
        }
        var parts: [String] = []
        if let s = placemark.subThoroughfare { parts.append(s) }
        if let t = placemark.thoroughfare { parts.append(t) }
        if let l = placemark.locality { parts.append(l) }
        if let a = placemark.administrativeArea { parts.append(a) }
        if let c = placemark.country { parts.append(c) }
        return parts.joined(separator: ", ")
    }
}

extension LocationSearchService: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            completions = completer.results.map { .apple($0) }
            isSearching = false
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            completions = []
            isSearching = false
        }
    }
}
