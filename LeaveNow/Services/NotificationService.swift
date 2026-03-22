//
//  NotificationService.swift
//  LeaveNow
//

import Foundation
import Combine
import UserNotifications

enum NotificationAuthStatus {
    case notDetermined
    case denied
    case authorized
}

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published private(set) var authorizationStatus: NotificationAuthStatus = .notDetermined

    private init() {
        Task { await updateStatus() }
    }

    func updateStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus == .authorized ? .authorized
            : settings.authorizationStatus == .denied ? .denied
            : .notDetermined
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await updateStatus()
            return granted
        } catch {
            return false
        }
    }

    /// Send local "time to leave" notification (shows in foreground via AppDelegate.willPresent).
    /// Uses summaryArgument and relevanceScore so it mirrors and displays well on Apple Watch.
    func sendLeaveNowNotification(estimatedMinutes: Int) {
        guard authorizationStatus == .authorized else { return }
        let content = UNMutableNotificationContent()
        content.title = "Time to leave!"
        content.body = "ETA is \(estimatedMinutes) min. Consider leaving now."
        content.sound = .default
        content.threadIdentifier = "LeaveNow.timeToLeave"
        content.summaryArgument = "ETA \(estimatedMinutes) min"
        content.summaryArgumentCount = 1
        if #available(iOS 15.0, *) {
            content.relevanceScore = 1.0
            content.interruptionLevel = .timeSensitive
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "LeaveNow.leave.\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
