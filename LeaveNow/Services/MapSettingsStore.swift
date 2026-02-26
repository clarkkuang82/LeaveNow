//
//  MapSettingsStore.swift
//  LeaveNow
//

import Foundation
import Combine

final class MapSettingsStore: ObservableObject {
    static let shared = MapSettingsStore()

    private let providerKey = "LeaveNow.MapProvider"

    @Published var mapProvider: MapProvider {
        didSet { UserDefaults.standard.set(mapProvider.rawValue, forKey: providerKey) }
    }

    init() {
        mapProvider = UserDefaults.standard.string(forKey: providerKey).flatMap(MapProvider.init(rawValue:)) ?? .apple
    }
}
