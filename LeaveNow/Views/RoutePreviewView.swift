//
//  RoutePreviewView.swift
//  LeaveNow
//

import SwiftUI
import MapKit
import CoreLocation

struct RoutePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let origin: String
    let destination: String
    let etaMinutes: Int?
    @StateObject private var mapSettings = MapSettingsStore.shared

    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var startCoord: CLLocationCoordinate2D?
    @State private var endCoord: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading route…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let err = errorMessage {
                    Text(err)
                        .foregroundStyle(.red)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Map(position: $position) {
                        if !routeCoordinates.isEmpty {
                            MapPolyline(coordinates: routeCoordinates)
                                .stroke(.blue, lineWidth: 5)
                        }
                        if let c = startCoord {
                            Marker("Start", coordinate: c)
                                .tint(.green)
                        }
                        if let c = endCoord {
                            Marker("End", coordinate: c)
                                .tint(.red)
                        }
                    }
                    .mapStyle(.standard)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    if let eta = etaMinutes {
                        Text("Driving ETA: \(eta) min")
                            .font(.headline)
                    }
                    Picker("Open in", selection: $mapSettings.mapProvider) {
                        ForEach(MapProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    .pickerStyle(.segmented)
                    Button {
                        MapsURLOpener.openDirections(origin: origin, destination: destination, provider: mapSettings.mapProvider)
                    } label: {
                        Text("Open in \(mapSettings.mapProvider.rawValue)")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await loadRoute()
            }
        }
    }

    private func loadRoute() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let result = try await RouteService.shared.drivingRouteCoordinates(origin: origin, destination: destination)
            await MainActor.run {
                routeCoordinates = result.coordinates
                startCoord = result.start
                endCoord = result.end
                if result.coordinates.count >= 2 {
                    let lats = result.coordinates.map(\.latitude)
                    let lons = result.coordinates.map(\.longitude)
                    let center = CLLocationCoordinate2D(
                        latitude: (lats.min()! + lats.max()!) / 2,
                        longitude: (lons.min()! + lons.max()!) / 2
                    )
                    let latDelta = max(0.01, (lats.max()! - lats.min()!) * 1.4)
                    let lonDelta = max(0.01, (lons.max()! - lons.min()!) * 1.4)
                    let region = MKCoordinateRegion(
                        center: center,
                        span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                    )
                    position = .region(region)
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
