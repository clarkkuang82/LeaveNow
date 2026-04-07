//
//  SharedMonitorState.swift
//  LeaveNow
//

import Foundation

/// A snapshot of monitoring state, written atomically by the main app, read by widgets.
struct SharedMonitorState: Codable, Equatable {
    var isMonitoring: Bool
    var lastCheckTime: Date?
    var lastDurationMinutes: Int?
    var lastError: String?
    var originAddress: String
    var destinationAddress: String
    var targetMinutes: Int

    static let defaultsKey = "LeaveNow.SharedMonitorState"

    static func load(from defaults: UserDefaults? = nil) -> SharedMonitorState? {
        let store = defaults ?? SharedDefaults.suite
        guard let data = store.data(forKey: Self.defaultsKey) else { return nil }
        return try? JSONDecoder().decode(SharedMonitorState.self, from: data)
    }

    func save(to defaults: UserDefaults? = nil) {
        let store = defaults ?? SharedDefaults.suite
        guard let data = try? JSONEncoder().encode(self) else { return }
        store.set(data, forKey: Self.defaultsKey)
    }
}
