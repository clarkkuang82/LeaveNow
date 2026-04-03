//
//  MonitorService.swift
//  LeaveNow
//

import Foundation
import Combine
import BackgroundTasks

@MainActor
final class MonitorService: ObservableObject {
    static let shared = MonitorService()
    static let bgTaskIdentifier = "com.clarkkuang.leavenow.refresh"

    @Published private(set) var isMonitoring = false
    @Published private(set) var lastCheckTime: Date?
    @Published private(set) var lastDurationMinutes: Int?
    @Published private(set) var lastError: String?

    private var timer: Timer?
    private var isChecking = false
    private var hasNotifiedThisCycle = false
    private static let isMonitoringKey = "LeaveNow.isMonitoring"
    private var configStore: ConfigStore { ConfigStore.shared }
    private var routeService: RouteService { RouteService.shared }
    private var notificationService: NotificationService { NotificationService.shared }

    private init() {}

    func startMonitoring() {
        guard configStore.config.isValid else { return }
        stopTimer()
        isMonitoring = true
        UserDefaults.standard.set(true, forKey: Self.isMonitoringKey)
        lastError = nil
        scheduleNextCheck()
        scheduleBackgroundRefresh()
    }

    func stopMonitoring() {
        stopTimer()
        isMonitoring = false
        UserDefaults.standard.set(false, forKey: Self.isMonitoringKey)
        isChecking = false
        hasNotifiedThisCycle = false
        lastCheckTime = nil
        lastDurationMinutes = nil
        lastError = nil
    }

    func restoreIfNeeded() {
        guard !isMonitoring,
              UserDefaults.standard.bool(forKey: Self.isMonitoringKey),
              configStore.config.isValid else { return }
        startMonitoring()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func scheduleNextCheck() {
        guard isMonitoring else { return }
        let interval = configStore.config.checkIntervalMinutes
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval * 60), repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.performCheck() }
        }
        timer?.tolerance = 60
        // Run first check immediately
        Task { @MainActor in await performCheck() }
    }

    func performCheck() async {
        let config = configStore.config
        guard config.isValid, !isChecking else { return }

        isChecking = true
        defer { isChecking = false }
        lastError = nil

        do {
            let seconds = try await routeService.drivingDurationSeconds(origin: config.originAddress, destination: config.destinationAddress)
            let minutes = max(1, Int(seconds / 60))
            lastCheckTime = Date()
            lastDurationMinutes = minutes

            if minutes <= config.targetMinutes && !hasNotifiedThisCycle {
                hasNotifiedThisCycle = true
                notificationService.sendLeaveNowNotification(estimatedMinutes: minutes)
            } else if minutes > config.targetMinutes {
                hasNotifiedThisCycle = false
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func scheduleBackgroundRefresh() {
        let interval = configStore.config.checkIntervalMinutes
        let request = BGAppRefreshTaskRequest(identifier: Self.bgTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(interval * 60))
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Background task may be unavailable (e.g. simulator)
        }
    }

    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: bgTaskIdentifier, using: nil) { task in
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.main.async {
                Task { @MainActor in
                    await MonitorService.shared.performCheck()
                    MonitorService.shared.scheduleBackgroundRefresh()
                    semaphore.signal()
                }
            }
            let waitResult = semaphore.wait(timeout: .now() + 20)
            task.setTaskCompleted(success: waitResult == .success)
        }
    }
}
