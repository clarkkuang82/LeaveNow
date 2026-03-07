# Test Coverage Analysis — LeaveNow

## Current State: 0% coverage, no tests exist

The project is a fresh Xcode/SwiftUI boilerplate (2 files, 41 lines). There are
**no test targets, no test files, and no CI/CD pipeline**. The Xcode project file
has a single scheme with no test action configured.

---

## What needs to be set up first

Before any tests can run, two Xcode test targets must be added to the project:

| Target | Type | Purpose |
|---|---|---|
| `LeaveNowTests` | XCTest (Unit) | Business logic, models, services, view models |
| `LeaveNowUITests` | XCUITest (UI) | End-to-end screen flows |

---

## Proposed test areas (prioritised by risk)

Given the app name ("LeaveNow"), the product is a departure-time / commute assistant.
As features are built, these are the areas that need the most test coverage:

---

### 1. Departure time calculation logic — Critical

This is the core product. Any bug here directly harms users.

```swift
// LeaveNowTests/DepartureCalculatorTests.swift
func testDepartureTimeSubtractsBufferFromETA() { ... }
func testDepartureTimeInThePastReturnsLeaveImmediately() { ... }
func testDepartureTimeWithZeroTravelTimeReturnsNow() { ... }
func testDepartureTimeRoundsToNearestMinute() { ... }
```

---

### 2. Location permission & CoreLocation integration — High

Location errors are a common crash source and gate the whole app experience.

```swift
// LeaveNowTests/LocationServiceTests.swift
func testLocationManagerRequestsWhenInUseAuthorization() { ... }
func testDeniedPermissionEmitsCorrectError() { ... }
func testLocationUpdateTriggersRecalculation() { ... }
```

---

### 3. Networking / transit data layer — High

If the app fetches travel times or transit schedules from an API, this layer needs:

```swift
// LeaveNowTests/TransitAPIClientTests.swift
func testSuccessfulResponseDecodesCorrectly() { ... }
func testMalformedJSONThrowsDecodingError() { ... }
func testNetworkTimeoutReturnsError() { ... }
func testBaseURLUsesProductionEndpointInRelease() { ... }
```

Inject a `URLProtocol` stub so tests never hit the real network.

---

### 4. Notification scheduling — High

"Leave now" alerts are only useful if they fire at the right time.

```swift
// LeaveNowTests/NotificationSchedulerTests.swift
func testNotificationFiresAtCalculatedDepartureTime() { ... }
func testCancellingRideRemovesPendingNotifications() { ... }
func testDeniedNotificationPermissionHandledGracefully() { ... }
```

Use `UNUserNotificationCenter` with a mock delegate — do not depend on device
permissions in tests.

---

### 5. User preferences / persistence — Medium

Settings (home address, commute buffer, preferred mode of transport) are typically
stored in `UserDefaults` or a local database.

```swift
// LeaveNowTests/UserPreferencesTests.swift
func testSavedHomeAddressPersistsAcrossLaunches() { ... }
func testDefaultBufferTimeIsFiveMinutes() { ... }
func testClearingPreferencesResetsToDefaults() { ... }
```

---

### 6. View model / state management — Medium

If MVVM is adopted (expected for a SwiftUI app), the view model contains logic that
is straightforward to unit-test without the UI:

```swift
// LeaveNowTests/HomeViewModelTests.swift
func testLoadingStateWhileFetchingRoute() { ... }
func testErrorStateWhenLocationUnavailable() { ... }
func testDepartureCountdownUpdatesEveryMinute() { ... }
```

---

### 7. UI / snapshot tests — Lower priority, high value

XCUITest for the critical user path:

```swift
// LeaveNowUITests/HomeScreenUITests.swift
func testTappingGetDirectionsOpensMap() { ... }
func testDepartureCardDisplaysCorrectTime() { ... }
func testOnboardingFlowCompletesToHomeScreen() { ... }
```

Snapshot tests (via swift-snapshot-testing) catch unintended visual regressions
in SwiftUI views.

---

### 8. Edge cases — Medium

These are the cases most often missed and most often responsible for production bugs:

- User crosses a timezone boundary mid-route
- Device clock is wrong / DST transition
- No internet connection at launch
- Background app refresh disabled
- Location accuracy below acceptable threshold
- Route API returns 0 results
- Departure time is midnight or next-day

---

## Recommended tooling additions

| Tool | Purpose |
|---|---|
| XCTest (built-in) | Unit + integration tests |
| XCUITest (built-in) | End-to-end UI tests |
| swift-snapshot-testing | Visual regression tests for SwiftUI views |
| GitHub Actions + `xcodebuild test` | Run tests on every PR |
| Codecov | Track coverage over time |

---

## Suggested CI configuration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          xcodebuild test \
            -project LeaveNow.xcodeproj \
            -scheme LeaveNow \
            -destination 'platform=iOS Simulator,name=iPhone 16' \
            -enableCodeCoverage YES
```
