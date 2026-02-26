//
//  AppDelegate.swift
//  LeaveNow
//

import UIKit
import UserNotifications
import GoogleMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        // Mark this device as a test device for AdMob so it always gets test ads.
        // NOTE: Replace the ID below if Google logs a new test device identifier after reinstall.
        // MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
        //     "f0b6fc46eeac842d8b6d39598d2cbbca"
            // You can also add simulator ID if needed, e.g. GADSimulatorID
        //]

        // Initialize the Google Mobile Ads SDK as early as possible.
        MobileAds.shared.start()
        return true
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
