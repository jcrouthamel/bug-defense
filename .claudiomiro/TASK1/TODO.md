Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Swift 5.x + SpriteKit architecture and conventions
- Grid system (20x15 tiles, 40pt tile size, safe zone x:1-18, y:1-13)
- MapType enum pattern and waypoint system implementation
- Bug vector-based movement logic (normalized direction vectors)
- Integration points with GameScene and MapManager
- Existing map design patterns and complexity levels

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Design Map 21 (Zigzag Lightning) Pattern and Implement in MapConfiguration.swift**
  - **What to do:**
    1. Design a zigzag/lightning-bolt pattern on a 20x15 grid that creates 3-5 sharp horizontal direction changes
    2. Choose spawn point at grid edge (x=1, x=18, y=1, or y=13) within safe zone
    3. Create waypoint array with key turning points that form a distinctive zigzag pattern
    4. Ensure path ends at house position GridPosition(x: 10, y: 7)
    5. Add enum case `case map21 = "Zigzag Lightning"` to MapType (after line 25)
    6. Implement `private var map21Path: [GridPosition]` method (before line 632, after map20Path)
    7. Add switch case `case .map21: basePath = map21Path` to roadPath computed property (after line 63)
    8. Verify all waypoints are within safe zone (x:1-18, y:1-13) and path length is 8-15 waypoints (will expand to 30-45 tiles)

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:5-26` — MapType enum structure and naming pattern
    - `Sources/BugDefense/MapConfiguration.swift:42-64` — roadPath switch statement pattern
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath() method that interpolates intermediate tiles
    - `Sources/BugDefense/MapConfiguration.swift:105-113` — housePosition and spawnPoints computed properties
    - `Sources/BugDefense/MapConfiguration.swift:140-166` — Map 2 (Zigzag) existing pattern for reference
    - `Sources/BugDefense/MapConfiguration.swift:480-505` — Map 14 (Lightning) existing pattern for reference
    - `Sources/BugDefense/MapConfiguration.swift:280-318` — Map 8 (U-Turns) sharp turn pattern reference
    - `Sources/BugDefense/MapConfiguration.swift:614-631` — Map 20 (last existing map) for placement reference
    - `Sources/BugDefense/GameConfiguration.swift:64-67` — Grid dimensions and tile size constants
    - `Sources/BugDefense/Bug.swift:240-302` — Bug waypoint following logic (setPath and update methods)

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map21 enum case (after line 25)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map21Path method (before line 632)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add switch case (after line 63)

  - **Interfaces / Contracts:**
    - MapType enum: New case `.map21` with rawValue "Zigzag Lightning"
    - Path method signature: `private var map21Path: [GridPosition]` returning array of waypoint GridPositions
    - Return type: `[GridPosition]` where each GridPosition has `x: Int, y: Int` properties
    - Integration: MapType.allCases automatically includes map21 (CaseIterable protocol)
    - Integration: MapType.random() will include map21 in random selection pool
    - Integration: roadPath computed property routes .map21 through expandPath(map21Path)
    - Contract: First waypoint = spawn point, last waypoint = GridPosition(x: 10, y: 7) (house)

  - **Tests:**
    Type: Unit tests with XCTest framework
    - Happy path: Map21 enum case exists and returns valid non-empty path array
    - Happy path: map21Path returns array with at least 2 waypoints
    - Validation: All waypoints in map21Path are within safe zone bounds (x:1-18, y:1-13)
    - Validation: Last waypoint equals housePosition GridPosition(x: 10, y: 7)
    - Validation: First waypoint is at grid edge (x=1 or x=18 or y=1 or y=13)
    - Edge case: expandPath(map21Path) produces continuous path without gaps
    - Integration: MapType.allCases contains map21 (count >= 21)
    - Integration: MapType.random() can select map21 (verify it's in the pool)

  - **Migrations / Data:**
    N/A - No data changes (compile-time enum definition)

  - **Observability:**
    - MapManager logs map selection: "🗺️ Selected map: Zigzag Lightning" (existing logging in MapManager.swift:645)
    - MapManager logs random selection: "🎲 Randomly selected map: Zigzag Lightning" (existing logging in MapManager.swift:650)
    - No additional logging required (waypoint following is already instrumented in Bug.swift)

  - **Security & Permissions:**
    N/A - No security concerns (single-player local game, no network, no user input validation needed)

  - **Performance:**
    - Map path definition is O(1) constant time (pre-computed array)
    - expandPath() runs once per map selection: O(n*m) where n=waypoints, m=max(dx,dy) per segment
    - Expected expanded path length: 30-45 tiles (moderate, within acceptable range)
    - Memory: ~20 GridPosition structs (8 bytes each) = ~160 bytes per map definition
    - Target: No measurable performance impact (map paths are cached in enum computed property)

  - **Commands:**
    ```bash
    # Compilation check
    swift build

    # Run all tests
    swift test

    # Run only map-related tests
    swift test --filter MapConfigurationTests

    # Run the game (manual testing)
    swift run BugDefenseApp

    # Optional: Check specific test
    swift test --filter testNewMapsPathValidity
    ```

  - **Risks & Mitigations:**
    - **Risk:** Path waypoints outside safe zone (x:1-18, y:1-13) causing visual issues or bugs leaving grid
      **Mitigation:** Manually verify each waypoint coordinate before implementation, add unit test to validate bounds
    - **Risk:** Path doesn't reach house position, bugs get stuck or game becomes unwinnable
      **Mitigation:** Ensure last waypoint is exactly GridPosition(x: 10, y: 7), add unit test to verify
    - **Risk:** Pattern too similar to existing Map 2 (Zigzag) or Map 14 (Lightning), lacking visual distinctiveness
      **Mitigation:** Study both existing maps carefully, design pattern with different spacing/direction changes
    - **Risk:** Path too short (too easy) or too long (too hard), breaking game balance
      **Mitigation:** Target 8-15 waypoints (expands to 30-45 tiles), compare to existing maps for length reference

- [ ] **Item 2 — Create Unit Tests for Map 21 Path Validity**
  - **What to do:**
    1. Create test file `Tests/BugDefenseTests/MapConfigurationTests.swift` (if it doesn't exist)
    2. Add `import XCTest` and `@testable import BugDefense` at top
    3. Implement test class `final class MapConfigurationTests: XCTestCase`
    4. Write `testMap21PathValidity()` to verify:
       - Path has at least 2 waypoints
       - All waypoints are within bounds (0 <= x < 20, 0 <= y < 15)
       - All waypoints are in safe zone (1 <= x <= 18, 1 <= y <= 13)
       - Last waypoint equals GridPosition(x: 10, y: 7)
       - First waypoint is at grid edge
    5. Write `testMapTypeAllCasesIncludesMap21()` to verify map21 in allCases
    6. Write `testMap21ExpandedPathIsContinuous()` to verify no gaps after expansion
    7. Follow test pattern from `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` for reference

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:1-363` — Existing test patterns and XCTest usage
    - `Tests/BugDefenseTests/BugDefenseTests.swift:6-22` — GridPosition conversion and distance tests
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` — Bug path assignment tests
    - `Tests/BugDefenseTests/BugMovementTests.swift` — Additional movement test examples
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath algorithm to understand continuous path
    - `Package.swift:26-28` — Test target configuration

  - **Touched (will modify/create):**
    - CREATE: `Tests/BugDefenseTests/MapConfigurationTests.swift` (new file)

  - **Interfaces / Contracts:**
    - Test class: `final class MapConfigurationTests: XCTestCase` with @MainActor if needed
    - Test methods: Standard XCTest pattern `func testMethodName() { ... }`
    - Assertions: XCTAssertEqual, XCTAssertTrue, XCTAssertGreaterThanOrEqual, XCTAssertNotNil
    - Import: `@testable import BugDefense` for access to internal types

  - **Tests:**
    Type: Unit tests testing the tests (meta-testing not required)
    - Verify tests compile and run successfully
    - All assertions pass for map21 implementation
    - Tests fail appropriately if map21 is not implemented correctly (validate test effectiveness)

  - **Migrations / Data:**
    N/A - Test file creation only

  - **Observability:**
    - XCTest framework provides test execution logging
    - Use descriptive test names and failure messages for clarity
    - Example: `XCTAssertEqual(path.last, housePosition, "Map 21 path must end at house position")`

  - **Security & Permissions:**
    N/A - No security concerns in tests

  - **Performance:**
    - All tests should complete in < 100ms (simple property checks)
    - No I/O operations, no sleeps, no network calls
    - Tests are deterministic and repeatable

  - **Commands:**
    ```bash
    # Run all tests
    swift test

    # Run only new MapConfiguration tests
    swift test --filter MapConfigurationTests

    # Run specific test method
    swift test --filter MapConfigurationTests.testMap21PathValidity

    # Verbose test output
    swift test --verbose
    ```

  - **Risks & Mitigations:**
    - **Risk:** Tests pass even with incorrect implementation (false positives)
      **Mitigation:** Write tests before verifying implementation, ensure tests fail if map21 doesn't exist
    - **Risk:** Tests are too brittle and fail on valid alternative implementations
      **Mitigation:** Test contracts and requirements, not implementation details
    - **Risk:** @MainActor requirement missing causing async test failures
      **Mitigation:** Follow pattern from BugDefenseTests.swift (some tests use @MainActor, check if MapType needs it)

- [ ] **Item 3 — Manual Testing and Visual Verification**
  - **What to do:**
    1. Build and run the game: `swift run BugDefenseApp`
    2. Use MapManager to select map21 (or wait for random selection)
    3. Verify visual rendering:
       - Road tiles (brown) render along entire zigzag path
       - Grass tiles (green) render on buildable areas
       - House tile (darker green) renders at center
       - No visual gaps in road path
       - Path has distinctive zigzag pattern with 3-5 horizontal segments
    4. Spawn bugs (start wave) and verify:
       - Bugs spawn at first waypoint (edge of map)
       - Bugs follow zigzag path precisely without deviation
       - Bugs move smoothly through sharp turns
       - Bugs reach house at end of path
       - No bugs get stuck or oscillate at waypoints
    5. Test tower placement:
       - Towers cannot be placed on road tiles
       - Towers can be placed on grass between path segments
       - Tower placement zones are sufficient for strategy
    6. Test map switching:
       - Change to another map and back to map21
       - Grid redraws correctly
       - No crashes or visual glitches
    7. Document any issues found in this TODO.md (if any)

  - **Context (read-only):**
    - `Sources/BugDefense/GameScene.swift:237-304` — Grid rendering implementation
    - `Sources/BugDefense/GameScene.swift:305-314` — redrawGrid() method
    - `Sources/BugDefense/GameScene.swift:488-504` — spawnBug() and path assignment
    - `Sources/BugDefense/GameScene.swift:826-856` — canPlaceStructure() tower placement blocking
    - `Sources/BugDefense/MapConfiguration.swift:634-664` — MapManager implementation
    - `.claudiomiro/AI_PROMPT.md:76-89` — Visual grid system description

  - **Touched (will modify/create):**
    - N/A - Manual testing only (no code changes)

  - **Interfaces / Contracts:**
    - Visual contract: Road path must be visually distinct and complete
    - Gameplay contract: Bugs must reach house following the path
    - UI contract: Tower placement blocked on road tiles
    - Integration contract: Map switching works without errors

  - **Tests:**
    Type: Manual exploratory testing (not automated)
    - Visual test: Path renders correctly as brown dirt road
    - Behavioral test: Bugs spawn at start and reach house at end
    - Behavioral test: Bugs don't deviate from path (use normalized vector movement)
    - Edge case: Sharp turns (90-degree) are navigated smoothly
    - Edge case: Long horizontal segments don't cause drift
    - Integration test: Map selection includes map21 in random pool
    - Integration test: Switching maps updates grid correctly

  - **Migrations / Data:**
    N/A - Testing only

  - **Observability:**
    - Watch console output for map selection logs:
      - "🗺️ Selected map: Zigzag Lightning"
      - "🎲 Randomly selected map: Zigzag Lightning"
    - Observe bug positions visually (SpriteKit debug rendering if enabled)
    - No additional logging needed for manual testing

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Monitor frame rate during bug movement on map21
    - Should maintain 60 FPS with 10+ bugs on screen
    - No stuttering or lag during path following
    - Map switching should be instant (< 100ms)

  - **Commands:**
    ```bash
    # Run the game
    swift run BugDefenseApp

    # If using Xcode
    open BugDefense.xcodeproj
    # Then: Product > Run (Cmd+R)

    # For iOS testing
    cd BugDefenseIOS
    # Open Xcode project and run on simulator
    ```

  - **Risks & Mitigations:**
    - **Risk:** Visual bugs not caught by unit tests (gaps in path, incorrect colors)
      **Mitigation:** Thorough manual visual inspection, compare to other maps
    - **Risk:** Bug movement issues only appear at runtime (stutter, oscillation, stuck)
      **Mitigation:** Spawn multiple bug types, test at different game speeds, observe full path traversal
    - **Risk:** Edge cases not covered in automated tests (specific turn sequences, boundary waypoints)
      **Mitigation:** Test all sharp turns and edge waypoints carefully, cycle through map multiple times
    - **Risk:** Performance degradation on complex path
      **Mitigation:** Monitor FPS, spawn 20+ bugs to stress test

## Verification (global)
- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Compile the project
      swift build

      # Run all tests (focus on MapConfiguration and Bug tests)
      swift test

      # Run specific MapConfiguration tests
      swift test --filter MapConfigurationTests

      # Run existing bug movement tests to ensure no regression
      swift test --filter BugMovementTests

      # Run full test suite to ensure no breaking changes
      swift test --verbose
      ```
      **CRITICAL:** Do not run full project checks beyond test suite
- [ ] All acceptance criteria met (see below)
- [ ] Code follows Swift conventions from AI_PROMPT.md:
      - Enum naming pattern matches existing maps
      - Method naming follows private var pattern
      - GridPosition coordinates use integer literals
      - Switch statement updated correctly
- [ ] Integration points properly implemented:
      - MapType.allCases includes map21 (automatic via CaseIterable)
      - roadPath switch routes to map21Path correctly
      - expandPath() handles map21Path waypoints without issues
- [ ] Performance targets met:
      - Map selection remains O(1)
      - expandPath() runs in acceptable time (< 10ms)
      - No memory leaks or excessive allocations
- [ ] Manual testing confirms visual and gameplay correctness

## Acceptance Criteria
- [ ] Map 21 enum case (`case map21 = "Zigzag Lightning"`) added to MapType after line 25
- [ ] `private var map21Path: [GridPosition]` method implemented before line 632
- [ ] Switch case `case .map21: basePath = map21Path` added after line 63
- [ ] All map21Path waypoints are within safe zone (1 <= x <= 18, 1 <= y <= 13)
- [ ] Path starts at grid edge position (x=1, x=18, y=1, or y=13)
- [ ] Path ends at house position GridPosition(x: 10, y: 7)
- [ ] Path creates distinctive zigzag/lightning-bolt pattern with 3-5 horizontal direction changes
- [ ] Path length is 8-15 key waypoints (expands to approximately 30-45 tiles)
- [ ] Code compiles without errors: `swift build` succeeds
- [ ] Unit tests created in MapConfigurationTests.swift covering path validity
- [ ] All tests pass: `swift test` succeeds with 0 failures
- [ ] Bugs spawn at first waypoint and reach house following zigzag path (manual test)
- [ ] Road tiles (brown) render correctly along entire path (visual verification)
- [ ] Towers cannot be placed on road tiles (gameplay verification)
- [ ] MapType.allCases contains 21 maps (count check)
- [ ] MapType.random() can select map21 (integration verification)
- [ ] Pattern is visually distinct from existing Map 2 (Zigzag) and Map 14 (Lightning)
- [ ] No regression: existing maps still work correctly

## Impact Analysis
- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift` (3 additions: enum case, path method, switch case)
  - `Tests/BugDefenseTests/MapConfigurationTests.swift` (new test file)

- **Indirectly impacted:**
  - `MapType.allCases` — count increases to 21 (automatic via CaseIterable)
  - `MapType.random()` — selection pool expands to include map21 (automatic)
  - `MapManager.selectRandomMap()` — can now select map21
  - `GameScene.spawnBug()` — will assign map21Path when map21 is active
  - Future TASK2-TASK10 — parallel tasks adding maps 22-30 (same pattern)
  - TASK11 — aggregation task may depend on all maps being implemented
  - TASKΩ — final validation may test all maps including map21

## Follow-ups
- None identified - task is well-defined with clear requirements and patterns to follow
- Note: This is one of 10 parallel map design tasks (TASK1-TASK10)
- Pattern established here applies to remaining map tasks (TASK2-TASK10)
- Consider adding map difficulty ratings in future enhancement (not in current scope)
