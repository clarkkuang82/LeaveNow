//
//  LeaveNowApp.swift
//  LeaveNow
//
//  Created by Clark Kuang on 2/24/26.
//

import SwiftUI

@main
struct LeaveNowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        MonitorService.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    MonitorService.shared.restoreIfNeeded()
                }
        }
    }
}
