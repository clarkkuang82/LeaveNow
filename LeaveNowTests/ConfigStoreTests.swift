//
//  ConfigStoreTests.swift
//  LeaveNowTests
//

import XCTest
@testable import LeaveNow

final class ConfigStoreTests: XCTestCase {
    private let suiteName = "com.test.ConfigStoreTests"
    private var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testInitWithEmptyDefaults() {
        let store = ConfigStore(defaults: testDefaults)
        XCTAssertEqual(store.config, TripConfig())
    }

    func testUpdatePersistsConfig() {
        let store = ConfigStore(defaults: testDefaults)
        let newConfig = TripConfig(
            originAddress: "Home",
            destinationAddress: "Work",
            checkIntervalMinutes: 10,
            targetMinutes: 45
        )
        store.update(newConfig)

        // Create a new instance reading from the same defaults
        let store2 = ConfigStore(defaults: testDefaults)
        XCTAssertEqual(store2.config, newConfig)
    }

    func testPartialUpdate() {
        let store = ConfigStore(defaults: testDefaults)
        store.update(origin: "New Origin")
        XCTAssertEqual(store.config.originAddress, "New Origin")
        XCTAssertEqual(store.config.destinationAddress, "")

        store.update(destination: "New Destination")
        XCTAssertEqual(store.config.originAddress, "New Origin")
        XCTAssertEqual(store.config.destinationAddress, "New Destination")
    }

    func testUpdateInterval() {
        let store = ConfigStore(defaults: testDefaults)
        store.update(interval: 15)
        XCTAssertEqual(store.config.checkIntervalMinutes, 15)
    }

    func testUpdateTarget() {
        let store = ConfigStore(defaults: testDefaults)
        store.update(target: 60)
        XCTAssertEqual(store.config.targetMinutes, 60)
    }
}
