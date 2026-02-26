//
//  ConfigStore.swift
//  LeaveNow
//

import Foundation
import Combine

final class ConfigStore: ObservableObject {
    static let shared = ConfigStore()

    private let key = "LeaveNow.TripConfig"

    @Published private(set) var config: TripConfig {
        didSet { save() }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(TripConfig.self, from: data) {
            config = decoded
        } else {
            config = TripConfig()
        }
    }

    func update(_ newConfig: TripConfig) {
        config = newConfig
    }

    func update(origin: String? = nil, destination: String? = nil, interval: Int? = nil, target: Int? = nil) {
        var c = config
        if let v = origin { c.originAddress = v }
        if let v = destination { c.destinationAddress = v }
        if let v = interval { c.checkIntervalMinutes = v }
        if let v = target { c.targetMinutes = v }
        config = c
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
