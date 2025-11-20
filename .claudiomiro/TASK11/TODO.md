Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK11/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK11/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Swift 5.x + SpriteKit tech stack and XCTest framework
- Project structure and Swift Package Manager configuration
- MapType enum architecture and waypoint-based pathfinding system
- Grid system constraints (20x15 tiles, safe zone x:1-18, y:1-13)
- House position requirement (GridPosition(x: 10, y: 7))
- Existing test patterns in BugDefenseTests.swift and BugMovementTests.swift
- Minimal testing philosophy (test new maps only, not existing engine)

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Create MapConfigurationTests.swift with Comprehensive Unit Tests for New Maps**
  - **What to do:**
    1. Create test file `Tests/BugDefenseTests/MapConfigurationTests.swift`
    2. Add standard Swift test imports: `import XCTest` and `@testable import BugDefense`
    3. Define test class: `final class MapConfigurationTests: XCTestCase {}`
    4. Implement `testNewMapsPathValidity()` test method that:
       - Defines array of new maps: `[.map21, .map22, .map23, .map24, .map25, .map26, .map27, .map28, .map29, .map30]`
       - Iterates through each map and validates:
         - Path has at least 2 waypoints (`XCTAssertGreaterThanOrEqual(path.count, 2)`)
         - Path ends at house position (`XCTAssertEqual(path.last, map.housePosition)`)
         - All waypoints are within grid bounds (x: 0-19, y: 0-14)
         - No intermediate waypoints overlap house position (except final waypoint)
       - Include descriptive failure messages with map identifier
    5. Implement `testMapCountIncludesNewMaps()` test method:
       - Get MapType.allCases count
       - Assert count is at least 30 (`XCTAssertGreaterThanOrEqual(allMaps.count, 30)`)
    6. Implement `testMapRandomSelectionIncludesNewMaps()` test method:
       - Verify `.map21` and `.map30` are in MapType.allCases
       - Verify MapType.random() returns non-nil value
    7. Follow test structure pattern from `Tests/BugDefenseTests/BugDefenseTests.swift:1-363` for consistency
    8. Use clear assertion messages for debugging (include map name/number in messages)

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:1-363` — Existing test structure and XCTest patterns
    - `Tests/BugDefenseTests/BugDefenseTests.swift:6-22` — GridPosition test examples
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` — Bug path assignment test patterns
    - `Tests/BugDefenseTests/BugMovementTests.swift:1-447` — Comprehensive movement test patterns
    - `Tests/BugDefenseTests/BugMovementTests.swift:8-45` — Helper function patterns for test setup
    - `Sources/BugDefense/MapConfiguration.swift:5-26` — MapType enum definition
    - `Sources/BugDefense/MapConfiguration.swift:36-38` — MapType.random() method
    - `Sources/BugDefense/MapConfiguration.swift:42-64` — roadPath computed property
    - `Sources/BugDefense/MapConfiguration.swift:106-108` — housePosition property
    - `Sources/BugDefense/GameConfiguration.swift:64-67` — Grid dimensions constants
    - `Package.swift:26-28` — Test target configuration

  - **Touched (will modify/create):**
    - CREATE: `Tests/BugDefenseTests/MapConfigurationTests.swift` — New test file for map validation

  - **Interfaces / Contracts:**
    - Test class: `final class MapConfigurationTests: XCTestCase` (Swift XCTest pattern)
    - Test methods: `func testMethodName()` (standard XCTest naming)
    - Assertions: XCTAssertEqual, XCTAssertTrue, XCTAssertGreaterThanOrEqual, XCTAssertNotEqual
    - Access: `@testable import BugDefense` for internal type access
    - Contract validation: All new maps (21-30) must:
      - Return non-empty path arrays via `roadPath` property
      - End at GridPosition(x: 10, y: 7)
      - Stay within bounds x:0-19, y:0-14
      - Have no intermediate waypoints at house position
    - Integration: MapType.allCases must include all 30 maps
    - Integration: MapType.random() must be functional

  - **Tests:**
    Type: Unit tests with XCTest framework
    - Happy path: All 10 new maps (21-30) return valid paths
    - Happy path: Each new map path has minimum 2 waypoints
    - Happy path: Each new map path ends at correct house position
    - Validation: All waypoints for all new maps within grid bounds
    - Validation: No intermediate waypoints at house position
    - Edge case: MapType.allCases count >= 30 (20 existing + 10 new)
    - Integration: MapType.allCases contains .map21 and .map30
    - Integration: MapType.random() returns non-nil value

  - **Migrations / Data:**
    N/A - No data changes (only test code)

  - **Observability:**
    - Test output shows pass/fail for each assertion
    - Descriptive failure messages identify which map failed and why
    - Example: "Map map23 does not end at house" or "Map map27 has x coordinate out of bounds: 20"
    - XCTest framework provides automatic test reporting

  - **Security & Permissions:**
    N/A - No security concerns (test code for local single-player game)

  - **Performance:**
    - Tests run in < 1 second (map path validation is O(n) where n = waypoints per map)
    - Total operations: ~10 maps × ~30-50 waypoints × 3-4 validations = ~1000-2000 simple checks
    - No pathfinding or simulation required (static path validation only)
    - Memory: Minimal (test allocates map paths temporarily)

  - **Commands:**
    ```bash
    # Compile the project
    swift build

    # Run only MapConfigurationTests
    swift test --filter MapConfigurationTests

    # Run all tests (includes new MapConfigurationTests)
    swift test

    # Verbose output for debugging
    swift test --filter MapConfigurationTests --verbose
    ```

  - **Risks & Mitigations:**
    - **Risk:** Tests might fail if maps 21-30 are not yet implemented in MapConfiguration.swift
      **Mitigation:** This task depends on TASK1-10 completion. Verify MapType enum includes cases map21-map30 before running tests. If maps are missing, tests will fail with clear "Unknown case" compilation errors.
    - **Risk:** Test assertions might be too strict (e.g., safe zone validation when only grid bounds matter)
      **Mitigation:** Follow TASK.md requirements precisely (lines 41-46). Test grid bounds (0-19, 0-14) not safe zone, unless specified in acceptance criteria.
    - **Risk:** Descriptive failure messages might be unclear for debugging
      **Mitigation:** Include map identifier (name/number) and specific violation in all assertion messages. Example: `"Map \(map.rawValue) has x coordinate out of bounds: \(pos.x)"`
    - **Risk:** Tests might not catch all integration issues (e.g., expandPath() failures)
      **Mitigation:** Tests validate unexpanded waypoint arrays, not expanded paths. expandPath() is existing functionality, not modified. Trust existing system per minimal testing philosophy (AI_PROMPT.md:269-336).

- [ ] **Item 2 — Verify Compilation and Test Execution**
  - **What to do:**
    1. Run `swift build` to verify project compiles without errors
    2. Verify MapConfigurationTests.swift compiles (no syntax errors)
    3. Run `swift test --filter MapConfigurationTests` to execute tests
    4. If tests fail, analyze failure messages:
       - "Unknown case" → Maps 21-30 not implemented (check TASK1-10 completion)
       - "Path does not end at house" → Map implementation bug (check specific map path)
       - "Out of bounds" → Map waypoint exceeds grid dimensions (check specific waypoint)
    5. Ensure all tests pass (green output)
    6. Document any failures in TASK11/TODO.md under "Follow-ups" section
    7. If all tests pass, proceed to final verification

  - **Context (read-only):**
    - `Package.swift:1-30` — Swift Package Manager configuration
    - `Sources/BugDefense/MapConfiguration.swift:5-26` — Verify map21-map30 enum cases exist
    - `Sources/BugDefense/MapConfiguration.swift:42-64` — Verify switch includes all new cases
    - `.claudiomiro/TASK1/TODO.md` through `.claudiomiro/TASK9/TODO.md` — Reference for map implementation status

  - **Touched (will modify/create):**
    - READ: All source files (compilation verification)
    - READ: MapConfigurationTests.swift (test execution)

  - **Interfaces / Contracts:**
    - Swift compiler: Must produce zero errors, zero warnings ideal
    - XCTest runner: Must execute all tests in MapConfigurationTests class
    - Test results: Must show "Test Suite 'MapConfigurationTests' passed" or specific failures
    - Exit codes: swift test returns 0 for success, non-zero for failures

  - **Tests:**
    Type: Verification of test suite execution (meta-testing)
    - Compilation: Project builds successfully with new test file
    - Execution: All MapConfigurationTests tests run without crashes
    - Reporting: Test failures provide clear diagnostic messages
    - Success criteria: All tests in MapConfigurationTests pass

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Compiler output shows build success/failure
    - Test runner output shows pass/fail for each test method
    - Example successful output:
      ```
      Test Suite 'MapConfigurationTests' started
      Test Case '-[BugDefenseTests.MapConfigurationTests testNewMapsPathValidity]' passed (0.003 seconds)
      Test Case '-[BugDefenseTests.MapConfigurationTests testMapCountIncludesNewMaps]' passed (0.001 seconds)
      Test Case '-[BugDefenseTests.MapConfigurationTests testMapRandomSelectionIncludesNewMaps]' passed (0.001 seconds)
      Test Suite 'MapConfigurationTests' passed
      ```

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Build time: < 10 seconds (incremental build with single new test file)
    - Test execution: < 1 second (fast static validation tests)

  - **Commands:**
    ```bash
    # Full build and test cycle
    swift build && swift test --filter MapConfigurationTests

    # Check for compilation warnings
    swift build 2>&1 | grep -i warning

    # Verbose test output for debugging
    swift test --filter MapConfigurationTests --verbose
    ```

  - **Risks & Mitigations:**
    - **Risk:** Compilation might fail due to missing map implementations
      **Mitigation:** Check TASK1-10 completion status first. If any task is incomplete (Fully implemented: NO), coordinate with user or wait for dependencies.
    - **Risk:** Tests might pass but not catch bugs (false positives)
      **Mitigation:** Review test logic carefully. Ensure assertions actually validate the conditions (e.g., XCTAssertEqual not XCTAssertNotNil for specific values).
    - **Risk:** Test failures might be unclear or misleading
      **Mitigation:** Run tests with --verbose flag. Read assertion messages carefully. Cross-reference with MapConfiguration.swift source to identify actual issue.

- [ ] **Item 3 — Optional Manual Integration Testing (Recommended)**
  - **What to do:**
    1. If possible, run the game application: `swift run BugDefenseApp`
    2. Manually trigger map cycling or random selection to view new maps 21-30
    3. Visual verification for each new map:
       - Road tiles (brown) render along the entire path
       - Path visually appears to reach the house at center
       - No visual gaps or discontinuities in road
       - Bugs spawn and follow path correctly to house
    4. Functional verification:
       - Bugs navigate entire path without getting stuck
       - Towers cannot be placed on road tiles
       - Map switching works correctly (tier progression)
    5. Document any visual or functional issues in TASK11/TODO.md Follow-ups
    6. This step is optional but highly recommended for quality assurance

  - **Context (read-only):**
    - `Sources/BugDefense/GameScene.swift:237-304` — Grid rendering implementation
    - `Sources/BugDefense/GameScene.swift:488-504` — Bug spawning with road path
    - `Sources/BugDefense/GameScene.swift:826-856` — Tower placement blocking on roads
    - `Sources/BugDefense/GameScene.swift:1287-1290` — Map switching at tier boundaries
    - `.claudiomiro/AI_PROMPT.md:143-158` — Visual and integration requirements

  - **Touched (will modify/create):**
    - READ: Entire game system (runtime observation)
    - No code modifications

  - **Interfaces / Contracts:**
    - Game application runs without crashes
    - All maps (1-30) are selectable and playable
    - Visual rendering matches expectations (road tiles, house position)
    - Gameplay mechanics work correctly (bug movement, tower placement)

  - **Tests:**
    Type: Manual integration testing (exploratory)
    - Visual: Road tiles render correctly for all new maps
    - Visual: House appears at correct position (center of grid)
    - Functional: Bugs spawn at path start and reach house
    - Functional: Bugs follow waypoint path precisely (no drift)
    - Functional: Towers blocked from road tile placement
    - Integration: Map selection includes all 30 maps
    - Integration: Random map selection can pick any map 21-30

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Visual feedback from game rendering
    - Bug movement behavior visible on screen
    - Console logs from MapManager showing map selection
    - User experience validation (playability, balance)

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Manual testing time: 5-10 minutes per map (optional spot-checking)
    - Total time: 50-100 minutes for thorough validation of all 10 new maps
    - Can be abbreviated to 3-5 representative maps for time efficiency

  - **Commands:**
    ```bash
    # Run the game application
    swift run BugDefenseApp

    # If running on macOS, app should open in window
    # If running on iOS simulator, use Xcode or xcrun simctl
    ```

  - **Risks & Mitigations:**
    - **Risk:** Manual testing is time-consuming and subjective
      **Mitigation:** This step is optional. Automated tests (Item 1) provide sufficient confidence. Manual testing adds visual/UX validation but not required for task completion.
    - **Risk:** Game might not run if dependencies are missing or platform is unsupported
      **Mitigation:** Check Package.swift platforms (macOS .v13, iOS .v16). If environment doesn't support, skip manual testing and rely on automated tests.
    - **Risk:** Issues found during manual testing might require map redesign
      **Mitigation:** Document issues in Follow-ups section. Severe issues (bugs get stuck, path unreachable) should be fixed in relevant TASK1-10. Minor issues (visual preference) can be noted for future iteration.

## Verification (global)

- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Build project
      swift build

      # Run MapConfigurationTests (targeted)
      swift test --filter MapConfigurationTests

      # Optional: Run all tests to ensure no regression
      swift test
      ```
      **CRITICAL:** Do not run full-project checks beyond test suite. No linting or formatting tools specified in project.

- [ ] All acceptance criteria met (see below)
- [ ] Code follows Swift conventions and XCTest patterns
- [ ] Tests provide clear, descriptive failure messages
- [ ] MapConfigurationTests.swift follows existing test file structure
- [ ] No modifications to existing engine code (test new maps only)

## Acceptance Criteria

From TASK.md - all criteria must be met:

### Unit Tests
- [ ] MapConfigurationTests.swift file created in Tests/BugDefenseTests/ directory
- [ ] testNewMapsPathValidity() implemented and passes
- [ ] testMapCountIncludesNewMaps() implemented and passes
- [ ] testMapRandomSelectionIncludesNewMaps() implemented and passes
- [ ] All 10 new maps (21-30) validated for:
  - [ ] Path has at least 2 waypoints
  - [ ] Path ends at house position GridPosition(x: 10, y: 7)
  - [ ] All waypoints within grid bounds (x: 0-19, y: 0-14)
  - [ ] No intermediate waypoints overlap house position

### Compilation
- [ ] `swift build` completes without errors
- [ ] `swift test` runs without failures

### Integration
- [ ] MapType.allCases contains at least 30 maps
- [ ] All new maps accessible via enum (map21 through map30)
- [ ] Random map selection includes new maps in pool

### Code Quality
- [ ] Test file follows Swift XCTest conventions
- [ ] Test methods have clear, descriptive names
- [ ] Assertions include helpful failure messages with map identifiers
- [ ] Tests focus on new map data, not existing engine systems
- [ ] No redundant tests for unchanged systems
- [ ] Code is clean with clear intent (minimal comments needed for simple validations)

## Impact Analysis

- **Directly impacted:**
  - `Tests/BugDefenseTests/MapConfigurationTests.swift` (new file created)
  - `Sources/BugDefense/MapConfiguration.swift` (validated, not modified)
  - Test suite execution (new tests added to test target)

- **Indirectly impacted:**
  - TASKΩ (final validation) - depends on this task's test suite
  - CI/CD pipelines (if any) - will run new tests automatically
  - Future map additions - test pattern established for validation
  - Regression prevention - tests catch future map implementation bugs

## Follow-ups

- None identified (or document specific issues below):
  - If any tests fail during implementation, document specific map and failure reason
  - If TASK1-10 are incomplete, list missing map implementations
  - If manual testing reveals visual/functional issues, document them with map numbers

## Diff Test Plan

**Purpose:** Confirm new MapConfigurationTests test file works correctly.

**Scope:** Test only the new test file and its interaction with existing MapConfiguration.swift.

### Changed Files/Symbols
- NEW: `Tests/BugDefenseTests/MapConfigurationTests.swift`
  - `testNewMapsPathValidity()` - validates all 10 new map paths
  - `testMapCountIncludesNewMaps()` - validates enum count >= 30
  - `testMapRandomSelectionIncludesNewMaps()` - validates integration

### Test Cases
1. **Happy path:** All new maps (21-30) exist and return valid paths
2. **Happy path:** MapType.allCases count is at least 30
3. **Edge case:** Path with minimum 2 waypoints passes validation
4. **Edge case:** Path ending exactly at GridPosition(x: 10, y: 7) passes
5. **Edge case:** Path with waypoints at grid boundaries (x=0/19, y=0/14) passes
6. **Failure case:** If map path ends at wrong position, test fails with clear message
7. **Failure case:** If map path has waypoint out of bounds, test fails with coordinate

### Coverage
- Target: 100% coverage for new MapConfigurationTests.swift file
- All test methods executed
- All new maps (21-30) validated in testNewMapsPathValidity()

### Execution
```bash
# Run only new tests
swift test --filter MapConfigurationTests
```

### Stop Rules
- All MapConfigurationTests pass twice consistently
- No compilation errors or warnings
- Test output shows clear pass/fail for each test method

### Definition of Done
- [ ] MapConfigurationTests.swift compiles without errors
- [ ] All test methods pass when run via `swift test --filter MapConfigurationTests`
- [ ] Test failures (if any) provide clear diagnostic messages
- [ ] No unrelated test failures in existing test suite
- [ ] Coverage: 100% of new test file executed
- [ ] Short summary: "Created MapConfigurationTests.swift with 3 test methods validating all 10 new maps (21-30) for path correctness, house endpoint, and grid bounds. All tests pass."

Then set first line to `Fully implemented: YES`.
