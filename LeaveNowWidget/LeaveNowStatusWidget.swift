//
//  LeaveNowStatusWidget.swift
//  LeaveNowWidget
//

import WidgetKit
import SwiftUI

struct LeaveNowEntry: TimelineEntry {
    let date: Date
    let state: SharedMonitorState?
}

struct LeaveNowTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LeaveNowEntry {
        LeaveNowEntry(date: .now, state: SharedMonitorState(
            isMonitoring: true,
            lastCheckTime: .now,
            lastDurationMinutes: 25,
            lastError: nil,
            originAddress: "Home",
            destinationAddress: "Work",
            targetMinutes: 30
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (LeaveNowEntry) -> Void) {
        let state = SharedMonitorState.load()
        completion(LeaveNowEntry(date: .now, state: state))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeaveNowEntry>) -> Void) {
        let state = SharedMonitorState.load()
        let entry = LeaveNowEntry(date: .now, state: state)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct LeaveNowStatusWidget: Widget {
    let kind: String = "LeaveNowStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveNowTimelineProvider()) { entry in
            LeaveNowWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Leave Now")
        .description("Monitor your commute ETA at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
