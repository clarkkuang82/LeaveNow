//
//  MapLocationPicker.swift
//  LeaveNow
//

import SwiftUI
import MapKit

struct MapLocationPicker: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (String) -> Void

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @StateObject private var locationManager = LocationManager()
    @State private var resolvedAddress: String?
    @State private var isResolving = false
    @State private var errorMessage: String?

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    @StateObject private var search = LocationSearchService()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MapReader { proxy in
                    Map(position: $position) {
                        UserAnnotation()
                        if let coord = selectedCoordinate {
                            Marker("Selected", coordinate: coord)
                                .tint(.red)
                        }
                    }
                    .mapStyle(.standard)
                    .onTapGesture { position in
                        isSearchFocused = false
                        search.clearCompletions()
                        if let coordinate = proxy.convert(position, from: .local) {
                            selectedCoordinate = coordinate
                            resolvedAddress = nil
                            errorMessage = nil
                            Task { await reverseGeocode(coordinate) }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    searchBar
                    if isSearchFocused && !search.completions.isEmpty {
                        searchSuggestionsList
                    }
                    Spacer(minLength: 0)
                    bottomBar
                }
            }
            .navigationTitle("Pick on map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.lastLocation) { _, newLocation in
                guard let loc = newLocation else { return }
                position = .camera(MapCamera(centerCoordinate: loc.coordinate, distance: 2000))
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search address or place", text: $searchText)
                .focused($isSearchFocused)
                .onChange(of: searchText) { _, newValue in
                    search.setQuery(newValue)
                }
                .onSubmit {
                    isSearchFocused = false
                }
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    search.clearCompletions()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var searchSuggestionsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(search.completions) { suggestion in
                    Button {
                        selectSearchCompletion(suggestion)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            if !suggestion.subtitle.isEmpty {
                                Text(suggestion.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxHeight: 220)
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            if let msg = errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if let coord = selectedCoordinate {
                if let addr = resolvedAddress {
                    Text(addr)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    Button("Use this location") {
                        confirmLocation()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isResolving)
                }
            } else {
                Text("Search or tap on the map to choose a location")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func selectSearchCompletion(_ suggestion: MapSearchSuggestion) {
        isSearchFocused = false
        searchText = ""
        search.clearCompletions()
        Task {
            if let result = await search.resolveMapItem(from: suggestion) {
                await MainActor.run {
                    selectedCoordinate = result.coordinate
                    resolvedAddress = result.address
                    errorMessage = nil
                    position = .camera(MapCamera(centerCoordinate: result.coordinate, distance: 800))
                }
            }
        }
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async {
        isResolving = true
        errorMessage = nil
        let address = await search.reverseGeocode(coordinate: coordinate)
        await MainActor.run {
            resolvedAddress = address
            isResolving = false
            if address == nil {
                errorMessage = "Could not get address for this point."
            }
        }
    }

    private func confirmLocation() {
        guard let addr = resolvedAddress ?? selectedCoordinate.map({ "\($0.latitude), \($0.longitude)" }) else { return }
        onSelect(addr)
        dismiss()
    }
}
