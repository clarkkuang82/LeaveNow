//
//  LiveActivityService.swift
//  LeaveNow
//

import ActivityKit
import Foundation

@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()

    private var currentActivity: Activity<LeaveNowActivityAttributes>?

    private init() {}

    func startActivity(config: TripConfig) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // End any orphaned activities from previous sessions
        for activity in Activity<LeaveNowActivityAttributes>.activities {
            Task {
                let finalState = LeaveNowActivityAttributes.ContentState(
                    currentETAMinutes: nil,
                    lastCheckTime: .now,
                    lastError: nil,
                    isMonitoring: false
                )
                await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
            }
        }

        let attributes = LeaveNowActivityAttributes(
            originAddress: config.originAddress,
            destinationAddress: config.destinationAddress,
            targetMinutes: config.targetMinutes
        )
        let initialState = LeaveNowActivityAttributes.ContentState(
            currentETAMinutes: nil,
            lastCheckTime: .now,
            lastError: nil,
            isMonitoring: true
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            // Live Activity may be unavailable
        }
    }

    func updateActivity(etaMinutes: Int?, lastCheckTime: Date, error: String?) {
        guard let activity = currentActivity else { return }
        let state = LeaveNowActivityAttributes.ContentState(
            currentETAMinutes: etaMinutes,
            lastCheckTime: lastCheckTime,
            lastError: error,
            isMonitoring: true
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func endActivity() {
        guard let activity = currentActivity else { return }
        let finalState = LeaveNowActivityAttributes.ContentState(
            currentETAMinutes: nil,
            lastCheckTime: .now,
            lastError: nil,
            isMonitoring: false
        )
        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
