//
//  LeaveNowWidgetView.swift
//  LeaveNowWidget
//

import SwiftUI
import WidgetKit

struct LeaveNowWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: LeaveNowEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    // MARK: - Small Widget

    private var smallView: some View {
        VStack(spacing: 6) {
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundStyle(statusColor)

            if let minutes = entry.state?.lastDurationMinutes, entry.state?.isMonitoring == true {
                Text("\(minutes)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(etaColor)
                Text("min ETA")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("--")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(entry.state?.isMonitoring == true ? "Checking..." : "Not Active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Medium Widget

    private var mediumView: some View {
        HStack(spacing: 12) {
            // Left: ETA
            VStack(spacing: 4) {
                Image(systemName: statusIcon)
                    .font(.title3)
                    .foregroundStyle(statusColor)
                if let minutes = entry.state?.lastDurationMinutes, entry.state?.isMonitoring == true {
                    Text("\(minutes)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(etaColor)
                    Text("min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("--")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 80)

            // Right: Details
            VStack(alignment: .leading, spacing: 4) {
                if let state = entry.state, state.isMonitoring {
                    Label {
                        Text(state.originAddress)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
                    }
                    .font(.caption)

                    Label {
                        Text(state.destinationAddress)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .font(.caption)

                    Spacer()

                    if let error = state.lastError {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                    } else if let checkTime = state.lastCheckTime {
                        Text("Checked \(checkTime, style: .relative) ago")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Not Monitoring")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Open the app to start")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private var statusIcon: String {
        guard let state = entry.state, state.isMonitoring else {
            return "car.fill"
        }
        if state.lastError != nil {
            return "exclamationmark.triangle.fill"
        }
        if let eta = state.lastDurationMinutes, eta <= state.targetMinutes {
            return "figure.walk"
        }
        return "car.fill"
    }

    private var statusColor: Color {
        guard let state = entry.state, state.isMonitoring else {
            return .secondary
        }
        if state.lastError != nil { return .orange }
        if let eta = state.lastDurationMinutes, eta <= state.targetMinutes {
            return .red
        }
        return .green
    }

    private var etaColor: Color {
        guard let state = entry.state,
              let eta = state.lastDurationMinutes else { return .primary }
        return eta <= state.targetMinutes ? .red : .primary
    }
}
