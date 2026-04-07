//
//  TripConfigTests.swift
//  LeaveNowTests
//

import XCTest
@testable import LeaveNow

final class TripConfigTests: XCTestCase {
    func testDefaultValues() {
        let config = TripConfig()
        XCTAssertEqual(config.originAddress, "")
        XCTAssertEqual(config.destinationAddress, "")
        XCTAssertEqual(config.checkIntervalMinutes, TripConfig.defaultCheckInterval)
        XCTAssertEqual(config.targetMinutes, TripConfig.defaultTargetMinutes)
    }

    func testCheckIntervalClampedToMin() {
        let config = TripConfig(checkIntervalMinutes: 0)
        XCTAssertEqual(config.checkIntervalMinutes, TripConfig.minCheckInterval)
    }

    func testCheckIntervalClampedToMax() {
        let config = TripConfig(checkIntervalMinutes: 999)
        XCTAssertEqual(config.checkIntervalMinutes, TripConfig.maxCheckInterval)
    }

    func testTargetMinutesClampedToMin() {
        let config = TripConfig(targetMinutes: 1)
        XCTAssertEqual(config.targetMinutes, TripConfig.minTargetMinutes)
    }

    func testTargetMinutesClampedToMax() {
        let config = TripConfig(targetMinutes: 500)
        XCTAssertEqual(config.targetMinutes, TripConfig.maxTargetMinutes)
    }

    func testIsValidWithBothAddresses() {
        let config = TripConfig(originAddress: "Home", destinationAddress: "Work")
        XCTAssertTrue(config.isValid)
    }

    func testIsInvalidWithEmptyOrigin() {
        let config = TripConfig(originAddress: "", destinationAddress: "Work")
        XCTAssertFalse(config.isValid)
    }

    func testIsInvalidWithEmptyDestination() {
        let config = TripConfig(originAddress: "Home", destinationAddress: "")
        XCTAssertFalse(config.isValid)
    }

    func testIsInvalidWithWhitespaceOnlyAddresses() {
        let config = TripConfig(originAddress: "   ", destinationAddress: "  \n  ")
        XCTAssertFalse(config.isValid)
    }

    func testCodableRoundTrip() throws {
        let config = TripConfig(
            originAddress: "123 Main St",
            destinationAddress: "456 Oak Ave",
            checkIntervalMinutes: 10,
            targetMinutes: 45
        )

        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(TripConfig.self, from: data)
        XCTAssertEqual(config, decoded)
    }
}
