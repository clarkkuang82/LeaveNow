//
//  LeaveNowLockScreenView.swift
//  LeaveNowWidget
//

import SwiftUI
import ActivityKit
import WidgetKit

struct LeaveNowLockScreenView: View {
    let context: ActivityViewContext<LeaveNowActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            // ETA display
            VStack(spacing: 2) {
                if let eta = context.state.currentETAMinutes {
                    Text("\(eta)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(eta <= context.attributes.targetMinutes ? .red : .white)
                    Text("min")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    Text("--")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                    Text("min")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(width: 70)

            // Route details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text(context.attributes.originAddress)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                }

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    Text(context.attributes.destinationAddress)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                }

                if let error = context.state.lastError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                } else {
                    Text("Checked \(context.state.lastCheckTime, style: .relative) ago")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Status indicator
            if let eta = context.state.currentETAMinutes, eta <= context.attributes.targetMinutes {
                Image(systemName: "figure.walk")
                    .font(.title3)
                    .foregroundStyle(.red)
            } else {
                Image(systemName: "car.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
            }
        }
        .padding()
    }
}
