//
//  SharedMonitorStateTests.swift
//  LeaveNowTests
//

import XCTest
@testable import LeaveNow

final class SharedMonitorStateTests: XCTestCase {
    private var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: "com.test.SharedMonitorStateTests")!
        testDefaults.removePersistentDomain(forName: "com.test.SharedMonitorStateTests")
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "com.test.SharedMonitorStateTests")
        super.tearDown()
    }

    func testCodableRoundTrip() throws {
        let state = SharedMonitorState(
            isMonitoring: true,
            lastCheckTime: Date(timeIntervalSince1970: 1000),
            lastDurationMinutes: 25,
            lastError: nil,
            originAddress: "123 Main St",
            destinationAddress: "456 Oak Ave",
            targetMinutes: 30
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(SharedMonitorState.self, from: data)
        XCTAssertEqual(state, decoded)
    }

    func testCodableRoundTripWithError() throws {
        let state = SharedMonitorState(
            isMonitoring: true,
            lastCheckTime: nil,
            lastDurationMinutes: nil,
            lastError: "Network error",
            originAddress: "Home",
            destinationAddress: "Work",
            targetMinutes: 15
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(SharedMonitorState.self, from: data)
        XCTAssertEqual(state, decoded)
    }

    func testLoadReturnsNilWhenNoData() {
        let result = SharedMonitorState.load(from: testDefaults)
        XCTAssertNil(result)
    }

    func testSaveAndLoad() {
        let state = SharedMonitorState(
            isMonitoring: true,
            lastCheckTime: Date(timeIntervalSince1970: 2000),
            lastDurationMinutes: 42,
            lastError: nil,
            originAddress: "Origin",
            destinationAddress: "Destination",
            targetMinutes: 30
        )

        state.save(to: testDefaults)
        let loaded = SharedMonitorState.load(from: testDefaults)

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded, state)
    }

    func testSaveOverwritesPreviousState() {
        let state1 = SharedMonitorState(
            isMonitoring: true,
            lastCheckTime: nil,
            lastDurationMinutes: 10,
            lastError: nil,
            originAddress: "A",
            destinationAddress: "B",
            targetMinutes: 30
        )
        state1.save(to: testDefaults)

        let state2 = SharedMonitorState(
            isMonitoring: false,
            lastCheckTime: nil,
            lastDurationMinutes: nil,
            lastError: nil,
            originAddress: "C",
            destinationAddress: "D",
            targetMinutes: 60
        )
        state2.save(to: testDefaults)

        let loaded = SharedMonitorState.load(from: testDefaults)
        XCTAssertEqual(loaded, state2)
    }
}
