//
//  LeaveNowActivityAttributesTests.swift
//  LeaveNowTests
//

import XCTest
@testable import LeaveNow

final class LeaveNowActivityAttributesTests: XCTestCase {
    func testContentStateCodableRoundTrip() throws {
        let state = LeaveNowActivityAttributes.ContentState(
            currentETAMinutes: 25,
            lastCheckTime: Date(timeIntervalSince1970: 1000),
            lastError: nil,
            isMonitoring: true
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(LeaveNowActivityAttributes.ContentState.self, from: data)
        XCTAssertEqual(state, decoded)
    }

    func testContentStateWithErrorCodableRoundTrip() throws {
        let state = LeaveNowActivityAttributes.ContentState(
            currentETAMinutes: nil,
            lastCheckTime: Date(timeIntervalSince1970: 2000),
            lastError: "Route unavailable",
            isMonitoring: true
        )

        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(LeaveNowActivityAttributes.ContentState.self, from: data)
        XCTAssertEqual(state, decoded)
    }

    func testContentStateHashable() {
        let state1 = LeaveNowActivityAttributes.ContentState(
            currentETAMinutes: 10,
            lastCheckTime: Date(timeIntervalSince1970: 1000),
            lastError: nil,
            isMonitoring: true
        )
        let state2 = LeaveNowActivityAttributes.ContentState(
            currentETAMinutes: 10,
            lastCheckTime: Date(timeIntervalSince1970: 1000),
            lastError: nil,
            isMonitoring: true
        )

        XCTAssertEqual(state1.hashValue, state2.hashValue)

        var set = Set<LeaveNowActivityAttributes.ContentState>()
        set.insert(state1)
        set.insert(state2)
        XCTAssertEqual(set.count, 1)
    }

    func testAttributesCodableRoundTrip() throws {
        let attributes = LeaveNowActivityAttributes(
            originAddress: "Home",
            destinationAddress: "Office",
            targetMinutes: 30
        )

        let data = try JSONEncoder().encode(attributes)
        let decoded = try JSONDecoder().decode(LeaveNowActivityAttributes.self, from: data)
        XCTAssertEqual(attributes.originAddress, decoded.originAddress)
        XCTAssertEqual(attributes.destinationAddress, decoded.destinationAddress)
        XCTAssertEqual(attributes.targetMinutes, decoded.targetMinutes)
    }
}
