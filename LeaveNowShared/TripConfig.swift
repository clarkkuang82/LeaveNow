//
//  TripConfig.swift
//  LeaveNow
//

import Foundation

/// User config: origin, destination, check interval, and target duration (notify when ETA ≤ this)
struct TripConfig: Codable, Equatable {
    var originAddress: String
    var destinationAddress: String
    /// Check interval in minutes
    var checkIntervalMinutes: Int
    /// Target duration in minutes: send "time to leave" when driving ETA ≤ this
    var targetMinutes: Int

    static let defaultCheckInterval = 5
    static let defaultTargetMinutes = 30
    static let minCheckInterval = 1
    static let maxCheckInterval = 60
    static let minTargetMinutes = 5
    static let maxTargetMinutes = 180

    init(
        originAddress: String = "",
        destinationAddress: String = "",
        checkIntervalMinutes: Int = Self.defaultCheckInterval,
        targetMinutes: Int = Self.defaultTargetMinutes
    ) {
        self.originAddress = originAddress
        self.destinationAddress = destinationAddress
        self.checkIntervalMinutes = min(max(checkIntervalMinutes, Self.minCheckInterval), Self.maxCheckInterval)
        self.targetMinutes = min(max(targetMinutes, Self.minTargetMinutes), Self.maxTargetMinutes)
    }

    var isValid: Bool {
        !originAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !destinationAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
