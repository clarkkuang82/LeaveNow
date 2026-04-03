---
name: tdd
description: Red-Green-Refactor TDD workflow. Use when the user asks to implement a feature or fix a bug using TDD, or when they say "tdd", "test-driven", or "red green".
argument-hint: <description of feature or bug to implement>
---

# Red-Green-Refactor TDD Skill

You are performing strict Red-Green-Refactor Test-Driven Development for an iOS Swift/SwiftUI project using XCTest.

## Input

The user describes a feature or bug fix: $ARGUMENTS

## Project Context

- **Language:** Swift
- **Framework:** SwiftUI, MapKit, CoreLocation, UserNotifications
- **Test framework:** XCTest
- **Test target directory:** `LeaveNowTests/`
- **Source directory:** `LeaveNow/`

## TDD Cycle

Follow this cycle strictly. **Never skip a step.** Announce each phase clearly.

### Phase 1: RED — Write a Failing Test

1. **Analyze** the feature/bug. Identify which service, model, or view logic to test.
2. **Create or update** a test file in `LeaveNowTests/`. Follow the naming convention `<ClassUnderTest>Tests.swift`.
3. **Write exactly one test** that captures the next small increment of behavior. The test must:
   - Import `XCTest` and `@testable import LeaveNow`
   - Subclass `XCTestCase`
   - Use descriptive naming: `test_<method>_<scenario>_<expectedResult>()`
   - Assert the expected behavior (use `XCTAssertEqual`, `XCTAssertTrue`, `XCTAssertNil`, `XCTAssertThrowsError`, etc.)
4. **Run the test** and confirm it **fails** (compilation error or assertion failure both count as red).
5. **Show the user** the failing test output. Say: `🔴 RED: Test fails as expected.`

### Phase 2: GREEN — Make It Pass

1. **Write the minimum production code** to make the failing test pass. Do not add anything extra.
   - Prefer editing existing files over creating new ones.
   - Do not refactor yet. Do not add unrelated functionality.
   - It is OK for the code to be ugly, duplicated, or hardcoded — the only goal is a passing test.
2. **Run the test** and confirm it **passes**.
3. **Run all existing tests** to confirm nothing is broken.
4. **Show the user** the passing output. Say: `🟢 GREEN: Test passes!`

### Phase 3: REFACTOR — Clean Up

1. **Review** both the production code and the test code for:
   - Duplication that can be extracted
   - Unclear naming
   - Overly complex logic that can be simplified
   - Protocol/dependency injection opportunities for testability
2. **Refactor** if improvements are warranted. Keep changes small and focused.
3. **Run all tests** again to confirm nothing broke.
4. Say: `♻️ REFACTOR: Code cleaned up. All tests still pass.`

### Repeat

After completing one full cycle, evaluate whether the feature/bug is fully addressed:
- If **not done**, return to Phase 1 and write the next failing test for the next increment.
- If **done**, summarize what was built and the full test suite results.

## Test Execution

Use `xcodebuild test` to run tests. The exact command:

```bash
xcodebuild test \
  -project LeaveNow.xcodeproj \
  -scheme LeaveNow \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:LeaveNowTests \
  2>&1 | tail -50
```

To run a single test:

```bash
xcodebuild test \
  -project LeaveNow.xcodeproj \
  -scheme LeaveNow \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
  -only-testing:LeaveNowTests/<TestClass>/<testMethod> \
  2>&1 | tail -50
```

If the test target `LeaveNowTests` does not exist yet, create it:
1. Create the `LeaveNowTests/` directory at the project root.
2. Add a test file.
3. Update `LeaveNow.xcodeproj/project.pbxproj` to include the test target, or instruct the user to add it via Xcode if pbxproj editing is too complex.

## Design Principles for Testable Code

- **Extract protocols** for external dependencies (MapKit, CLGeocoder, UNUserNotificationCenter) so tests can use mock/stub implementations.
- **Inject dependencies** via initializer parameters with default values pointing to real implementations.
- **Separate pure logic** from side effects. Test the logic; stub the side effects.
- **Keep @MainActor** usage on the outer layer; extract testable logic into plain functions/types where possible.
- **Use async/await** in tests with `func test_...() async throws` when testing async code.

## Rules

- **One test at a time.** Never write multiple failing tests before making one pass.
- **Smallest step possible.** Each test should drive a tiny, well-defined behavior.
- **Do not write production code without a failing test first.**
- **Do not refactor while red.** Get to green first, then refactor.
- **Communicate each phase transition** clearly so the user can follow along.
- **Commit after each green phase** if the user has asked for commits.
