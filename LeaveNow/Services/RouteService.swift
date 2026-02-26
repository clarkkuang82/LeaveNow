//
//  RouteService.swift
//  LeaveNow
//

import Foundation
import MapKit
import CoreLocation

enum RouteError: LocalizedError {
    case geocodeFailed(String)
    case directionsFailed(String)

    var errorDescription: String? {
        switch self {
case .geocodeFailed(let msg): return "Geocode failed: \(msg)"
    case .directionsFailed(let msg): return "Directions failed: \(msg)"
        }
    }
}

/// Fetch driving duration and route via Apple MapKit. Use "Open in Google Maps" to navigate in the Google Maps app.
@MainActor
final class RouteService {
    static let shared = RouteService()
    private let geocoder = CLGeocoder()

    private init() {}

    /// Returns expected driving duration in seconds, or throws on failure.
    func drivingDurationSeconds(origin: String, destination: String) async throws -> TimeInterval {
        let originItem = try await geocodeToMapItem(origin)
        let destItem = try await geocodeToMapItem(destination)
        let request = MKDirections.Request()
        request.source = originItem
        request.destination = destItem
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        let response = try await directions.calculateETA()
        return response.expectedTravelTime
    }

    /// Returns the driving route for drawing on a map (polyline + start/end).
    func drivingRouteCoordinates(origin: String, destination: String) async throws -> (coordinates: [CLLocationCoordinate2D], start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let route = try await drivingRouteApple(origin: origin, destination: destination)
        let coords = route.polyline.coordinates
        guard let first = coords.first, let last = coords.last else { throw RouteError.directionsFailed("No route") }
        return (coords, first, last)
    }

    /// Apple-only: returns MKRoute for backward compatibility.
    func drivingRoute(origin: String, destination: String) async throws -> MKRoute {
        try await drivingRouteApple(origin: origin, destination: destination)
    }

    private func drivingRouteApple(origin: String, destination: String) async throws -> MKRoute {
        let originItem = try await geocodeToMapItem(origin)
        let destItem = try await geocodeToMapItem(destination)
        let request = MKDirections.Request()
        request.source = originItem
        request.destination = destItem
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        guard let route = response.routes.first else { throw RouteError.directionsFailed("No route") }
        return route
    }

    private func geocodeToMapItem(_ address: String) async throws -> MKMapItem {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RouteError.geocodeFailed("Address is empty") }

        let placemarks = try await geocoder.geocodeAddressString(trimmed)
        guard let cl = placemarks.first, let coord = cl.location?.coordinate else {
            throw RouteError.geocodeFailed("Could not resolve \"\(trimmed)\"")
        }
        let mkPlacemark = MKPlacemark(coordinate: coord, addressDictionary: cl.addressDictionary as? [String: Any])
        return MKMapItem(placemark: mkPlacemark)
    }
}

private extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}
