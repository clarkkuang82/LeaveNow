//
//  AppDelegate.swift
//  LeaveNow
//

import UIKit
import UserNotifications
import GoogleMobileAds
import AppTrackingTransparency

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        MobileAds.shared.start()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        requestTrackingAuthorization()
    }

    private func requestTrackingAuthorization() {
        guard #available(iOS 14, *) else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Task { @MainActor in
            if MonitorService.shared.isMonitoring {
                MonitorService.shared.scheduleBackgroundRefresh()
            }
        }
    }

    // Show notification banner/sound when app is in foreground (otherwise user never sees "time to leave")
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .list, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
}
