//
//  LeaveNowLiveActivity.swift
//  LeaveNowWidget
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LeaveNowLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LeaveNowActivityAttributes.self) { context in
            // Lock screen / banner presentation
            LeaveNowLockScreenView(context: context)
                .activityBackgroundTint(.black.opacity(0.7))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.attributes.destinationAddress)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                    }
                    .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let eta = context.state.currentETAMinutes {
                        Text("\(eta) min")
                            .font(.title2.bold())
                            .foregroundStyle(eta <= context.attributes.targetMinutes ? .red : .green)
                    } else {
                        Text("--")
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if let error = context.state.lastError {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                    } else {
                        Text("Checked \(context.state.lastCheckTime, style: .relative) ago")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "car.fill")
            } compactTrailing: {
                if let eta = context.state.currentETAMinutes {
                    Text("\(eta)m")
                        .font(.caption.bold())
                        .foregroundStyle(eta <= context.attributes.targetMinutes ? .red : .primary)
                } else {
                    Text("--")
                        .font(.caption.bold())
                }
            } minimal: {
                Image(systemName: "car.fill")
            }
        }
    }
}
