//
//  LeaveNowActivityAttributes.swift
//  LeaveNow
//

import ActivityKit
import Foundation

struct LeaveNowActivityAttributes: ActivityAttributes {
    /// Static context that doesn't change during the Live Activity lifetime.
    var originAddress: String
    var destinationAddress: String
    var targetMinutes: Int

    /// Dynamic state that updates with each ETA check.
    struct ContentState: Codable, Hashable {
        var currentETAMinutes: Int?
        var lastCheckTime: Date
        var lastError: String?
        var isMonitoring: Bool
    }
}
