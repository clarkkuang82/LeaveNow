//
//  AddressFieldWithSuggestions.swift
//  LeaveNow
//

import SwiftUI
import MapKit

struct AddressFieldWithSuggestions: View {
    let label: String
    @Binding var text: String
    var onPickOnMap: () -> Void

    @StateObject private var search = LocationSearchService()
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                TextField(label, text: $text)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    search.setQuery(newValue)
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused { search.clearCompletions() }
                }
                Button {
                    onPickOnMap()
                } label: {
                    Image(systemName: "map.fill")
                }
                .buttonStyle(.borderless)
            }
            if isFocused && !search.completions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(search.completions) { suggestion in
                        SuggestionRow(suggestion: suggestion) {
                            select(suggestion)
                        }
                    }
                }
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func select(_ suggestion: MapSearchSuggestion) {
        isFocused = false
        Task {
            if let address = await search.resolveAddress(from: suggestion) {
                text = address
            }
            search.clearCompletions()
        }
    }
}

private struct SuggestionRow: View {
    let suggestion: MapSearchSuggestion
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
