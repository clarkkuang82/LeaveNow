//
//  SharedDefaults.swift
//  LeaveNow
//

import Foundation

/// Centralized access to the App Group UserDefaults shared between the main app and widget extension.
enum SharedDefaults {
    static let suiteName = "group.com.clarkkuang.leavenow"

    static var suite: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
}
