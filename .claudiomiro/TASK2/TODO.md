Fully implemented: YES
Code review passed

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack: Swift 5.x with SpriteKit framework
- Project structure and architecture (entity-component pattern)
- Testing framework: XCTest (Swift's standard testing framework)
- Grid system: 20x15 tiles, 40pt tile size
- Coordinate conversion patterns
- Coding conventions (emoji comments, naming patterns)
- Related code examples with file:line references
- Integration points and dependencies

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [X] **Item 1 — Create BugMovementTests.swift with Helper Functions and Setup**
  - **What to do:**
    1. Create new test file `Tests/BugDefenseTests/BugMovementTests.swift`
    2. Follow the XCTest pattern from `Tests/BugDefenseTests/BugDefenseTests.swift:1-5` (imports and class structure)
    3. Import required modules: `XCTest`, `@testable import BugDefense`
    4. Create final class `BugMovementTests: XCTestCase` with `@MainActor` annotation
    5. Implement helper function `createTestBug(path:speed:slowFactor:) -> Bug`:
       - Create Bug instance with `.ant` type at first waypoint
       - Set custom speed and slowFactor if provided (defaults: normal speed, slowFactor=1.0)
       - Call `bug.setPath(path)` to assign the path
       - Return configured bug instance
    6. Implement helper function `runUpdatesUntilCompletion(bug:maxIterations:)`:
       - Loop up to maxIterations (default 1000)
       - Call `bug.update(deltaTime: 0.016, pathfindingGrid: PathfindingGrid(width: 20, height: 15))` each iteration
       - Break when `bug.pathIndex >= bug.movementPath.count` (path completed)
       - Use realistic deltaTime of 0.016 seconds (≈60 FPS)
    7. Implement helper function `assertPositionNear(_:_:tolerance:file:line:)`:
       - Calculate distance between actual and expected CGPoint
       - Assert distance <= tolerance using `XCTAssertLessThanOrEqual`
       - Provide helpful message: "Position \(actual) not within \(tolerance) of expected \(expected), distance was \(distance)"

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:1-186` — Existing test structure, patterns, and XCTest usage
    - `Tests/BugDefenseTests/BugDefenseTests.swift:24-42` — Example of @MainActor tests and setup
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` — Test pattern for Bug instantiation and path assignment
    - `Sources/BugDefense/Bug.swift:151-219` — Bug initialization signature and properties
    - `Sources/BugDefense/Bug.swift:240-252` — `setPath()` method implementation (how path assignment works)
    - `Sources/BugDefense/Bug.swift:254-316` — `update()` method signature and behavior (what we're testing)
    - `Sources/BugDefense/GameConfiguration.swift:65-67` — Grid dimensions and tile size constants
    - `Sources/BugDefense/GameConfiguration.swift:177-182` — Grid-to-world coordinate conversion

  - **Touched (will modify/create):**
    - CREATE: `Tests/BugDefenseTests/BugMovementTests.swift`

  - **Interfaces / Contracts:**
    - Test class: `final class BugMovementTests: XCTestCase` with `@MainActor` annotation
    - Helper functions:
      - `func createTestBug(path: [GridPosition], speed: CGFloat? = nil, slowFactor: CGFloat = 1.0) -> Bug`
      - `func runUpdatesUntilCompletion(bug: Bug, maxIterations: Int = 1000)`
      - `func assertPositionNear(_ actual: CGPoint, _ expected: CGPoint, tolerance: CGFloat, file: StaticString = #file, line: UInt = #line)`
    - Must follow XCTest conventions and Swift testing patterns

  - **Tests:**
    Type: Unit tests with XCTest (setup only, no test cases yet)
    - Helper function validation: Create a simple 2-waypoint path, verify bug reaches second waypoint
    - Verify createTestBug properly initializes bug at first waypoint
    - Verify runUpdatesUntilCompletion terminates correctly

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    N/A - Test infrastructure, no observability requirements

  - **Security & Permissions:**
    N/A - No security concerns in test code

  - **Performance:**
    - Helper functions must be lightweight (called multiple times per test)
    - runUpdatesUntilCompletion should complete in < 100ms for typical paths
    - All test setup overhead should be < 1 second total

  - **Commands:**
    ```bash
    # Build and run tests
    swift test --filter BugMovementTests

    # Run with verbose output
    swift test --filter BugMovementTests --verbose
    ```

  - **Risks & Mitigations:**
    - **Risk:** SpriteKit requires MainActor annotation, tests may fail without it
      **Mitigation:** Mark entire test class with @MainActor, following pattern from BugDefenseTests.swift:24
    - **Risk:** Bug initialization may require valid PathfindingGrid
      **Mitigation:** Create minimal PathfindingGrid(width: 20, height: 15) instance for update calls
    - **Risk:** Infinite loop if bug never reaches waypoint
      **Mitigation:** Use maxIterations parameter with default 1000 (16 seconds at 60fps)

- [X] **Item 2 — Implement Straight Path Tests (Horizontal and Vertical)**
  - **What to do:**
    1. Implement `testBugMovesAlongStraightHorizontalPathWithoutDrift()`:
       - Arrange: Create path [(1,5), (2,5), (3,5), (4,5), (5,5)] - all same Y coordinate
       - Calculate expectedY = path[0].toWorldPosition().y (should be 220.0 for y=5)
       - Act: Create bug, track all positions during movement, run until completion
       - Assert: All recorded positions have Y within 0.5 points of expectedY
       - Assert: Bug completes path (pathIndex == path.count)
       - Assert: Final position matches last waypoint exactly (within 0.1 points)
    2. Implement `testBugMovesAlongStraightVerticalPathWithoutDrift()`:
       - Arrange: Create path [(5,1), (5,2), (5,3), (5,4), (5,5)] - all same X coordinate
       - Calculate expectedX = path[0].toWorldPosition().x (should be 220.0 for x=5)
       - Act: Create bug, track all positions during movement, run until completion
       - Assert: All recorded positions have X within 0.5 points of expectedX
       - Assert: Bug completes path (pathIndex == path.count)
       - Assert: Final position matches last waypoint exactly (within 0.1 points)
    3. Use XCTAssertEqual with accuracy parameter for floating-point comparisons
    4. Provide descriptive failure messages that include actual position and expected values

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:6-15` — Example of XCTAssertEqual usage with exact values
    - `.claudiomiro/TASK2/PROMPT.md:39-48` — Specification for horizontal/vertical path tests
    - `.claudiomiro/TASK2/PROMPT.md:129-169` — Example test implementation pattern
    - `Sources/BugDefense/Bug.swift:254-316` — Movement implementation being tested
    - `Sources/BugDefense/GameConfiguration.swift:177-182` — Coordinate conversion for expected values

  - **Touched (will modify/create):**
    - MODIFY: `Tests/BugDefenseTests/BugMovementTests.swift` — Add test methods

  - **Interfaces / Contracts:**
    - Test methods:
      - `func testBugMovesAlongStraightHorizontalPathWithoutDrift()`
      - `func testBugMovesAlongStraightVerticalPathWithoutDrift()`
    - Both must be instance methods, no parameters
    - Must use XCTest assertions (XCTAssertEqual, XCTAssertLessThanOrEqual)

  - **Tests:**
    Type: Unit tests
    - Happy path: Bug follows straight horizontal line from (1,5) to (5,5) without Y drift
    - Happy path: Bug follows straight vertical line from (5,1) to (5,5) without X drift
    - Edge case: Verify final position snaps exactly to last waypoint
    - Failure detection: Test should fail if bug drifts >0.5 points off expected axis

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Test output includes clear assertion messages showing:
      - Which position drifted (if drift detected)
      - Expected vs actual coordinates
      - Distance from expected path

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Each test should complete in < 500ms
    - Straight paths are short (5 waypoints) so should converge quickly
    - Total test time for both: < 1 second

  - **Commands:**
    ```bash
    # Run these specific tests
    swift test --filter testBugMovesAlongStraightHorizontalPathWithoutDrift
    swift test --filter testBugMovesAlongStraightVerticalPathWithoutDrift

    # Run all movement tests
    swift test --filter BugMovementTests
    ```

  - **Risks & Mitigations:**
    - **Risk:** TASK1 implementation may not fix drift completely, tests may fail
      **Mitigation:** If tests fail, document exact failure mode (drift amount, location) for debugging
    - **Risk:** Tolerance of 0.5 points may be too strict or too loose
      **Mitigation:** 0.5 points = 1.25% of 40pt tile, justified in PROMPT.md:120-125; adjust if needed based on results
    - **Risk:** Floating-point imprecision may cause false failures
      **Mitigation:** Use XCTAssertEqual with accuracy parameter for tolerance-based comparisons

- [X] **Item 3 — Implement Diagonal and Complex Path Tests**
  - **What to do:**
    1. Implement `testBugMovesAlongDiagonalPath()`:
       - Arrange: Create path [(2,2), (3,3), (4,4), (5,5)] - diagonal progression
       - Act: Create bug, run updates until completion
       - Assert: Bug passes through each waypoint in sequence (check after each waypoint)
       - Assert: Bug completes entire path (pathIndex == path.count)
       - Assert: Final position matches (5,5) waypoint exactly
    2. Implement `testBugMovesAlongLShapedCurvedPath()`:
       - Arrange: Create L-shaped path [(1,1), (2,1), (3,1), (3,2), (3,3), (3,4)] - horizontal then vertical
       - Act: Create bug, track positions during turn at (3,1)→(3,2), run until completion
       - Assert: Bug makes the corner correctly (reaches (3,1) exactly before turning)
       - Assert: No drift off path during turn (horizontal segment stays at y=1 world coords, vertical at x=3 world coords)
       - Assert: Bug completes entire path (pathIndex == path.count)
    3. Track intermediate positions to verify smooth movement through waypoints
    4. Verify both straight segments and turns are handled correctly

  - **Context (read-only):**
    - `.claudiomiro/TASK2/PROMPT.md:49-58` — Specification for diagonal and curved path tests
    - `.claudiomiro/AI_PROMPT.md:71-103` — Path expansion logic ensuring all intermediate tiles included
    - `Sources/BugDefense/Bug.swift:292-314` — Movement logic handling diagonal vs orthogonal segments
    - `Sources/BugDefense/Bug.swift:280-284` — Waypoint arrival and position snapping

  - **Touched (will modify/create):**
    - MODIFY: `Tests/BugDefenseTests/BugMovementTests.swift` — Add test methods

  - **Interfaces / Contracts:**
    - Test methods:
      - `func testBugMovesAlongDiagonalPath()`
      - `func testBugMovesAlongLShapedCurvedPath()`

  - **Tests:**
    Type: Unit tests
    - Diagonal path: Bug follows (2,2)→(3,3)→(4,4)→(5,5) correctly
    - L-shaped path: Bug makes 90-degree turn at corner without drift
    - Edge case: Corner waypoint (3,1) reached exactly before direction change
    - Edge case: Verify no diagonal drift during orthogonal segments

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Test output includes waypoint arrival confirmations
    - Clear assertion messages for turn behavior
    - Position tracking during critical corner transitions

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Diagonal test: ~5 waypoints, should complete < 500ms
    - L-shaped test: ~6 waypoints, should complete < 500ms
    - Total test time for both: < 1 second

  - **Commands:**
    ```bash
    # Run these specific tests
    swift test --filter testBugMovesAlongDiagonalPath
    swift test --filter testBugMovesAlongLShapedCurvedPath

    # Run all movement tests
    swift test --filter BugMovementTests
    ```

  - **Risks & Mitigations:**
    - **Risk:** Diagonal movement implementation may differ from straight movement, causing drift
      **Mitigation:** TASK1 uses vector normalization (Bug.swift:298-303) which should handle diagonal correctly
    - **Risk:** Corner turns may cause bugs to cut corners or overshoot
      **Mitigation:** Test explicitly checks position at corner waypoint before and after turn
    - **Risk:** Test may not detect subtle drift if tolerance is too loose
      **Mitigation:** Use stricter tolerance (0.5 points) on straight segments, verify exact waypoint arrival

- [X] **Item 4 — Implement Edge Case Tests (Speed Variations and Starting Position)**
  - **What to do:**
    1. Implement `testVerySlowBugStillReachesWaypoints()`:
       - Arrange: Create simple 3-waypoint path [(1,1), (2,1), (3,1)]
       - Create bug with custom slowFactor = 0.1 (10% normal speed)
       - Act: Run updates with maxIterations = 5000 (allow more time for slow bug)
       - Assert: Bug still completes path despite slow speed
       - Assert: Bug arrives exactly at each waypoint (same precision as fast bugs)
       - Assert: Takes significantly more iterations than normal speed (verify slowness)
    2. Implement `testVeryFastBugDoesNotSkipWaypoints()`:
       - Arrange: Create path with many close waypoints [(1,1), (2,1), (3,1), (4,1), (5,1)]
       - Create bug with type that has high moveSpeed (use .spider or configure custom speed)
       - Act: Run updates and track pathIndex progression
       - Assert: Bug increments pathIndex exactly once per waypoint (no skips)
       - Assert: Bug visits all 5 waypoints in sequence
       - Assert: Final position at (5,1) waypoint
    3. Implement `testBugStartingExactlyAtWaypointAdvancesProperly()`:
       - Arrange: Create path [(1,1), (2,1), (3,1)]
       - Create bug - verify initial position is exactly at (1,1) world position
       - Act: Call update() once with normal deltaTime
       - Assert: Bug starts moving toward (2,1), doesn't stay stuck at (1,1)
       - Assert: pathIndex advances appropriately
       - Run to completion and verify bug reaches final waypoint

  - **Context (read-only):**
    - `.claudiomiro/TASK2/PROMPT.md:59-70` — Specification for edge case tests
    - `Sources/BugDefense/Bug.swift:240-252` — setPath() implementation that positions bug at first waypoint
    - `Sources/BugDefense/Bug.swift:290` — Speed calculation: `moveSpeed * slowFactor * deltaTime`
    - `Sources/BugDefense/Bug.swift:280-284` — Waypoint arrival detection and pathIndex increment
    - `.claudiomiro/TASK2/TASK.md:87-103` — Detailed edge case descriptions

  - **Touched (will modify/create):**
    - MODIFY: `Tests/BugDefenseTests/BugMovementTests.swift` — Add test methods

  - **Interfaces / Contracts:**
    - Test methods:
      - `func testVerySlowBugStillReachesWaypoints()`
      - `func testVeryFastBugDoesNotSkipWaypoints()`
      - `func testBugStartingExactlyAtWaypointAdvancesProperly()`
    - May require extending createTestBug helper to accept speed/slowFactor parameters

  - **Tests:**
    Type: Unit tests
    - Slow bug edge case: slowFactor = 0.1, verify correct arrival and iteration count
    - Fast bug edge case: High moveSpeed, verify no waypoint skipping
    - Starting position edge case: Verify bug doesn't get stuck at initial waypoint
    - Boundary condition: pathIndex progression correctness for all edge cases

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Track iteration count for slow bug to verify it takes longer
    - Log pathIndex progression for fast bug to verify sequential waypoint visits
    - Record initial position and first movement for starting position test

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Slow bug test may take longer due to high iteration count (budget 1-2 seconds)
    - Fast bug test should complete quickly despite high speed (< 500ms)
    - Starting position test is very fast (minimal iterations, < 100ms)
    - Total test time for all three: < 3 seconds

  - **Commands:**
    ```bash
    # Run edge case tests
    swift test --filter testVerySlowBugStillReachesWaypoints
    swift test --filter testVeryFastBugDoesNotSkipWaypoints
    swift test --filter testBugStartingExactlyAtWaypointAdvancesProperly

    # Run all movement tests
    swift test --filter BugMovementTests
    ```

  - **Risks & Mitigations:**
    - **Risk:** Slow bug test may timeout or take excessive iterations
      **Mitigation:** Set maxIterations = 5000 (reasonable for 10x slower movement); if still insufficient, adjust slowFactor or path length
    - **Risk:** Fast bug may legitimately skip waypoints if speed > tile spacing
      **Mitigation:** TASK1 implementation should handle this via distance check (Bug.swift:280); test will reveal if fix is insufficient
    - **Risk:** Starting position test may not trigger edge case if setPath doesn't position exactly
      **Mitigation:** Verify initial position explicitly with assertion before update call
    - **Risk:** Tests may be flaky due to floating-point accumulation errors
      **Mitigation:** Use appropriate tolerances and multiple runs during development; document any observed flakiness

## Verification (global)

- [X] Run targeted tests for changed code only:
      ```bash
      # Run the new test file
      swift test --filter BugMovementTests

      # Run specific test if debugging
      swift test --filter testBugMovesAlongStraightHorizontalPathWithoutDrift

      # Build and test in one command
      swift build && swift test --filter BugMovementTests
      ```
      **CRITICAL:** Do not run full-project tests here - focus on BugMovementTests only
- [X] All 7 test cases pass (horizontal, vertical, diagonal, L-shaped, slow, fast, starting position)
- [X] Tests are deterministic - run twice to verify consistent results
- [X] Tests complete in reasonable time (< 5 seconds total for all tests)
- [X] Code follows Swift/XCTest conventions from existing test file
- [X] All acceptance criteria met (see below)
- [X] Test helper functions are reusable and clear
- [X] Assertion messages are descriptive and aid debugging

## Acceptance Criteria

- [X] **Test file created**: `Tests/BugDefenseTests/BugMovementTests.swift` exists and follows XCTest structure
- [X] **All 7+ test cases implemented**:
  - testBugMovesAlongStraightHorizontalPathWithoutDrift() — Verifies no Y-axis drift
  - testBugMovesAlongStraightVerticalPathWithoutDrift() — Verifies no X-axis drift
  - testBugMovesAlongDiagonalPath() — Verifies diagonal movement correctness
  - testBugMovesAlongLShapedCurvedPath() — Verifies corner turns without drift
  - testVerySlowBugStillReachesWaypoints() — Verifies slow bug (slowFactor=0.1) works
  - testVeryFastBugDoesNotSkipWaypoints() — Verifies fast bug doesn't skip waypoints
  - testBugStartingExactlyAtWaypointAdvancesProperly() — Verifies no stuck-at-start bug
- [X] **Tests are focused**: Each test verifies specific aspect of movement behavior (drift, waypoint arrival, speed handling)
- [X] **Tests use realistic values**:
  - deltaTime = 0.016 (60 FPS)
  - tileSize = 40 points (from GameConfiguration)
  - Speed values match actual bug types
  - Paths use valid grid coordinates (0-19 for x, 0-14 for y)
- [X] **Assertions are precise**:
  - Position drift tolerance: 0.5 points (1.25% of tile size)
  - Waypoint arrival tolerance: 0.1 points (exact positioning)
  - Clear assertion messages with actual vs expected values
- [X] **All tests pass**: `swift test --filter BugMovementTests` completes with 0 failures
- [X] **No flaky tests**: Running `swift test --filter BugMovementTests` twice produces identical results
- [X] **Test names are descriptive**: Names clearly indicate what is being tested (e.g., "testBugMovesAlongStraightHorizontalPathWithoutDrift")
- [X] **Edge cases covered**: Tests verify behavior for:
  - Slow bugs (slowFactor = 0.1)
  - Fast bugs (high moveSpeed)
  - Various path geometries (horizontal, vertical, diagonal, curved)
  - Starting position at first waypoint
- [X] **Grid position verified**: Tests check both `position` (world coordinates) and waypoint progression (via gridPosition)
- [X] **Code quality**:
  - Follows Swift naming conventions (camelCase)
  - Uses @MainActor annotation for SpriteKit compatibility
  - Includes helpful comments where logic is complex
  - Helper functions reduce code duplication

## Impact Analysis

- **Directly impacted:**
  - `Tests/BugDefenseTests/BugMovementTests.swift` (new file created)
  - Test coverage for `Sources/BugDefense/Bug.swift:254-316` (update method)

- **Indirectly impacted:**
  - TASKΩ (verification task) — Will use these tests to verify overall fix
  - Future bug movement changes — Tests will catch regressions
  - CI/CD pipeline — New tests will run on every commit (if CI configured)
  - Documentation — Tests serve as executable specification of movement behavior

## Follow-ups

- None identified — All requirements are clearly specified in TASK.md and PROMPT.md
- If tests fail, root cause may be in TASK1 implementation (Bug.swift:254-316), not test design


## PREVIOUS TASKS CONTEXT FILES AND RESEARCH: 
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/ANALYSIS.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/CONTEXT.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/RESEARCH.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/TODO.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/CONTEXT.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/RESEARCH.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/TODO.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/RESEARCH.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/RESEARCH.md

