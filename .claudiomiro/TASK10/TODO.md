Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK10/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK10/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack and framework versions (Swift 5.x + SpriteKit)
- Project structure and architecture (Entity-Component pattern)
- Coding conventions and patterns (enum-based map system)
- Related code examples with file:line references
- Integration points and dependencies

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Map 30 Design — Implement Labyrinth Maze Path**
  - **What to do:**
    1. Design a complex labyrinth maze pattern with 70-100 waypoints on paper/sketch (20x15 grid)
       - Create maximum visual complexity with many twists, turns, and apparent dead-ends
       - Pattern should fill the safe zone extensively, using most available grid space
       - Include multiple "branches" that appear to be choices but all converge to house
       - Reference Map 5 (Maze Runner) at `Sources/BugDefense/MapConfiguration.swift:205-239` for maze complexity inspiration
       - Make this the longest and most challenging path in the game

    2. Add enum case to MapType in `Sources/BugDefense/MapConfiguration.swift`
       - Add `case map30 = "Labyrinth Maze"` after line 24 (after map20)

    3. Implement private var `map30Path` method
       - Follow pattern from existing map methods (e.g., map5Path at lines 205-239)
       - Return `[GridPosition]` array with 70-100 waypoint corners
       - Start at edge position (spawn point) - e.g., GridPosition(x: 1, y: 1) or similar
       - End at GridPosition(x: 10, y: 7) - the house position (REQUIRED)
       - Ensure all waypoints stay within safe zone: x:1-18, y:1-13
       - Create intricate path with frequent direction changes

    4. Add switch case to `roadPath` computed property
       - Add `case .map30: basePath = map30Path` to the switch statement (after line 62)

    5. Verify path validity
       - Ensure path is continuous (no gaps between waypoints)
       - Confirm all coordinates within bounds
       - Check that expandPath() will interpolate correctly (uses integer division)
       - Validate visual pattern creates maze-like appearance

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:5-24` — MapType enum definition pattern
    - `Sources/BugDefense/MapConfiguration.swift:40-67` — roadPath switch statement structure
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath() algorithm for path interpolation
    - `Sources/BugDefense/MapConfiguration.swift:104-107` — housePosition definition (always x:10, y:7)
    - `Sources/BugDefense/MapConfiguration.swift:205-239` — Map 5 (Maze Runner) reference pattern
    - `Sources/BugDefense/MapConfiguration.swift:350-412` — Map 11 (Box Spiral) complex long path example
    - `Sources/BugDefense/GameConfiguration.swift` — Grid constants (gridWidth=20, gridHeight=15, tileSize=40)

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add enum case (line ~25)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add switch case (line ~63)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map30Path method (at end of file, line ~640+)

  - **Interfaces / Contracts:**
    - **MapType enum**: Add `.map30 = "Labyrinth Maze"` case
    - **Path method signature**: `private var map30Path: [GridPosition] { return [...] }`
    - **Path contract**: Array starts at edge spawn point, ends at GridPosition(x: 10, y: 7)
    - **Path length**: 70-100 waypoint corners (will expand to more tiles via expandPath)
    - **Grid bounds**: All GridPosition x values in 1-18, y values in 1-13

  - **Tests:**
    Type: Unit tests with XCTest framework
    - Happy path: Map30 path is valid (has waypoints, ends at house, all in bounds)
    - Edge case: Verify path length is 70-100 waypoints (longest map)
    - Edge case: All waypoints within safe zone boundaries (x:1-18, y:1-13)
    - Edge case: Path expansion produces no gaps (continuous road)
    - Integration: MapType.allCases includes map30
    - Integration: MapType.random() can select map30
    - Failure: N/A - compile-time enum ensures correctness

  - **Migrations / Data:**
    N/A - No data changes. Map is compile-time definition added to enum.

  - **Observability:**
    N/A - No special logging required. Map selection already logged via existing game systems.

  - **Security & Permissions:**
    N/A - No security concerns. Static map data, no user input or external data.

  - **Performance:**
    - Path complexity: 70-100 waypoints will expand via expandPath() to ~100-150 tiles
    - Memory: O(n) where n = expanded path length, negligible impact
    - Computation: Path expansion is one-time at map load, O(n*m) where m = steps between waypoints
    - Rendering: SpriteKit handles tile rendering efficiently, no performance concerns
    - Target: Map selection must remain O(1) (achieved via enum switch)

  - **Commands:**
    ```bash
    # Compile and check for errors
    swift build

    # Run tests for map validation (after test implementation)
    swift test --filter MapConfigurationTests

    # Build for macOS (if using Xcode)
    xcodebuild -scheme BugDefense -destination 'platform=macOS'

    # Manual testing: Run the game and verify map30 visually
    swift run BugDefenseApp
    # OR
    open BugDefense.app
    ```

  - **Risks & Mitigations:**
    - **Risk:** Path goes outside safe zone boundaries
      **Mitigation:** Double-check all GridPosition values: x must be 1-18, y must be 1-13

    - **Risk:** Path doesn't reach house position
      **Mitigation:** Ensure last waypoint is exactly GridPosition(x: 10, y: 7)

    - **Risk:** Path has gaps or discontinuities
      **Mitigation:** Use expandPath() algorithm which interpolates between waypoints; ensure waypoints are logically connected

    - **Risk:** Pattern too similar to existing maze maps (Map 5, Map 20)
      **Mitigation:** Create more complex pattern with 2-3x more waypoints than Map 5, use full grid space

    - **Risk:** Path length under 70 waypoints (not hard enough)
      **Mitigation:** Count waypoints during design, add more turns and segments to reach 70-100 range

- [ ] **Map 30 Testing — Unit Tests for Path Validity**
  - **What to do:**
    1. Create test method `testMap30PathValidity()` in `Tests/BugDefenseTests/BugDefenseTests.swift`
       - Follow existing test pattern from lines 6-23 (GridPosition tests)
       - Test that map30 roadPath is not empty
       - Test that path ends at house position GridPosition(x: 10, y: 7)
       - Test that all waypoints are within bounds (x: 0-19, y: 0-14 grid)
       - Test that path length is >= 70 waypoints (hard difficulty requirement)

    2. Add test for MapType.allCases includes map30
       - Verify that MapType.allCases.count == 30 (was 20, now 30 with new map)
       - Verify that MapType.allCases.contains(.map30) == true

    3. Add test for random selection can pick map30
       - Create test that map30 is in allCases and thus eligible for random()

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:6-23` — GridPosition test pattern
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` — Bug spawning and path tests
    - `Sources/BugDefense/MapConfiguration.swift:104-107` — House position definition
    - `.claudiomiro/AI_PROMPT.md:275-306` — Testing approach guidance

  - **Touched (will modify/create):**
    - MODIFY: `Tests/BugDefenseTests/BugDefenseTests.swift` — Add testMap30PathValidity() method
    - MODIFY: `Tests/BugDefenseTests/BugDefenseTests.swift` — Add testMap30InAllCases() method

  - **Interfaces / Contracts:**
    - **Test method signature**: `func testMap30PathValidity() { ... }`
    - **Assertions**: XCTAssert* methods from XCTest framework
    - **Expected values**:
      - Path count >= 70
      - Last waypoint == GridPosition(x: 10, y: 7)
      - All waypoints x in 0-19, y in 0-14

  - **Tests:**
    Type: Unit tests validating new code only
    - Test map30 path is valid and meets requirements
    - Test map30 is in allCases
    - Test path length >= 70 waypoints
    - Test all coordinates in bounds

  - **Migrations / Data:**
    N/A - Test code only

  - **Observability:**
    N/A - Test output provides pass/fail visibility

  - **Security & Permissions:**
    N/A - Test code has no security implications

  - **Performance:**
    - Tests run in <100ms per test case
    - No heavy computation, just array/property checks

  - **Commands:**
    ```bash
    # Run only the new map tests
    swift test --filter testMap30

    # Run all map configuration tests
    swift test --filter MapConfigurationTests

    # Run all tests
    swift test
    ```

  - **Risks & Mitigations:**
    - **Risk:** Test expectations incorrect (wrong house position)
      **Mitigation:** Reference MapConfiguration.swift:106 for correct house position

    - **Risk:** Test passes but map visually broken
      **Mitigation:** Manual testing required (run game and observe map30)

- [ ] **Map 30 Manual Verification — Visual and Gameplay Testing**
  - **What to do:**
    1. Build and run the game application
       - Use `swift run BugDefenseApp` or open BugDefense.app

    2. Force select map30 or wait for random selection
       - May need to trigger map selection via game UI or dev console
       - Alternative: Temporarily modify MapManager.shared.selectRandomMap() to always return .map30

    3. Verify visual rendering
       - Confirm brown road tiles render along entire path
       - Verify no visual gaps in the road
       - Check that path looks like intricate labyrinth maze
       - Ensure house appears at center (GridPosition x:10, y:7)

    4. Verify bug behavior
       - Spawn bugs and watch them follow path
       - Confirm bugs move smoothly through all turns
       - Verify bugs reach house at end of path
       - Check no diagonal drift or stair-stepping

    5. Verify tower placement
       - Try placing towers on road tiles (should be blocked)
       - Verify towers can be placed on grass tiles
       - Confirm house position blocks tower placement

    6. Test map switching
       - Change to different map and back to map30
       - Verify grid redraws correctly
       - Ensure no crashes or visual glitches

  - **Context (read-only):**
    - `Sources/BugDefense/GameScene.swift:237-304` — Grid rendering logic
    - `Sources/BugDefense/GameScene.swift:488-504` — Bug spawning and path assignment
    - `Sources/BugDefense/GameScene.swift:826-856` — Tower placement blocking on roads
    - `Sources/BugDefense/Bug.swift:240-302` — Bug movement and waypoint following

  - **Touched (will modify/create):**
    - No files modified - this is observation only
    - OPTIONAL: Temporarily modify MapManager for forced map selection (revert after testing)

  - **Interfaces / Contracts:**
    - Visual contract: Road tiles render continuously along path
    - Behavioral contract: Bugs follow path precisely to house
    - Interaction contract: Towers cannot be placed on roads or house

  - **Tests:**
    Type: Manual end-to-end testing
    - Visual: Road renders correctly as labyrinth maze
    - Gameplay: Bugs follow path completely without getting stuck
    - Gameplay: Path provides longest/hardest difficulty (70-100 waypoints)
    - Interaction: Tower placement rules enforced
    - Stability: No crashes or performance issues

  - **Migrations / Data:**
    N/A - Testing only

  - **Observability:**
    - Observe console logs for any errors during map rendering
    - Watch bug movement for smoothness and correctness
    - Monitor frame rate (should remain stable ~60 FPS)

  - **Security & Permissions:**
    N/A - Testing only

  - **Performance:**
    - Path complexity should not impact frame rate
    - Bug pathfinding should remain smooth
    - Grid rendering should complete in <100ms

  - **Commands:**
    ```bash
    # Run the game for manual testing
    swift run BugDefenseApp

    # OR if using Xcode build
    open BugDefense.app

    # OR iOS simulator (if testing iOS)
    xcodebuild -scheme BugDefense -destination 'platform=iOS Simulator,name=iPhone 15'
    ```

  - **Risks & Mitigations:**
    - **Risk:** Bug visual drift on diagonal segments
      **Mitigation:** Vector-based movement (Bug.swift:292-300) prevents this; confirmed in TASK1

    - **Risk:** Path visually confusing (too complex)
      **Mitigation:** This is intentional for "hard" difficulty; if truly unplayable, reduce waypoint count

    - **Risk:** Performance degradation with many waypoints
      **Mitigation:** Path expansion is one-time cost; monitor FPS during testing

## Verification (global)

- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Compile check
      swift build

      # Run map tests
      swift test --filter testMap30
      swift test --filter MapConfigurationTests

      # Full test suite (optional, to ensure no regressions)
      swift test
      ```
      **CRITICAL:** Do not run full-project checks if not needed. Focus on map-specific tests.

- [ ] All acceptance criteria met (see below)

- [ ] Code follows conventions from AI_PROMPT.md and PROMPT.md:
      - Enum case naming: `.map30 = "Labyrinth Maze"`
      - Method naming: `private var map30Path`
      - GridPosition usage for waypoints
      - Path ends at house position

- [ ] Integration points properly implemented:
      - map30 case added to MapType enum
      - map30 case added to roadPath switch
      - Path expansion via expandPath() works correctly

- [ ] Performance targets met:
      - Map selection remains O(1)
      - Path expansion completes in <100ms
      - No frame rate impact during gameplay

- [ ] Security requirements satisfied:
      N/A - No security requirements for this task

## Acceptance Criteria

- [ ] Complex maze-like pattern with many turns (70-100 waypoints)
- [ ] Path length 70-100 waypoints (longest map, hardest difficulty)
- [ ] Visually intricate and challenging labyrinth appearance
- [ ] All waypoints within safe zone (x:1-18, y:1-13)
- [ ] Path reaches house correctly at GridPosition(x: 10, y: 7)
- [ ] Compiles successfully: `swift build` exits with code 0
- [ ] Tests pass: testMap30PathValidity() and related tests pass
- [ ] Pattern is distinct from Map 5 (Maze Runner) and Map 20 (Labyrinth) - more complex
- [ ] Path is continuous despite complexity (no actual dead ends)
- [ ] Code follows naming pattern from MapConfiguration.swift:116-631
- [ ] MapType.allCases includes map30 (count == 30)
- [ ] MapType.random() can select map30

## Impact Analysis

- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift:~25` — Added enum case `.map30 = "Labyrinth Maze"`
  - `Sources/BugDefense/MapConfiguration.swift:~63` — Added switch case `case .map30: basePath = map30Path`
  - `Sources/BugDefense/MapConfiguration.swift:~640+` — Added `private var map30Path` method (70-100 waypoints)
  - `Tests/BugDefenseTests/BugDefenseTests.swift` — Added test methods for map30 validation

- **Indirectly impacted:**
  - `MapType.allCases` — Now returns 30 maps instead of 20
  - `MapType.random()` — Can now select map30 from pool
  - `MapManager.shared.selectRandomMap()` — Can select map30 for tier progression
  - Game difficulty curve — Map30 provides hardest/longest path option
  - Player experience — More map variety, especially for high-difficulty preference

## Follow-ups

None identified. Task scope is clear:
- Design pattern: Follow Map 5 (Maze Runner) complexity, but longer
- Path length: 70-100 waypoints (hard difficulty)
- Constraints: Safe zone x:1-18, y:1-13, end at house GridPosition(x:10, y:7)
- Implementation: Add enum case, switch case, and path method

## Diff Test Plan

**Purpose:** Confirm Map 30 implementation works correctly with minimal sufficient testing.

**Changed Files:**
1. `Sources/BugDefense/MapConfiguration.swift` — Added map30 enum case, switch case, path method
2. `Tests/BugDefenseTests/BugDefenseTests.swift` — Added map30 unit tests

**Test Coverage Plan:**

1. **Unit: Map30 Path Validity**
   - Arrange: Access MapType.map30.roadPath
   - Act: Read path array and house position
   - Assert:
     - Path count >= 70 waypoints
     - Last waypoint == GridPosition(x: 10, y: 7)
     - All waypoints x in 1-18, y in 1-13
   - Expected: All assertions pass

2. **Unit: Map30 In AllCases**
   - Arrange: Access MapType.allCases
   - Act: Check count and contains
   - Assert:
     - allCases.count == 30
     - allCases.contains(.map30) == true
   - Expected: All assertions pass

3. **Integration: Path Expansion**
   - Arrange: Get map30Path waypoints
   - Act: Call expandPath() (automatic in roadPath)
   - Assert: Expanded path is continuous, no gaps
   - Expected: Path tiles are contiguous

4. **Manual E2E: Visual Rendering**
   - Arrange: Run game, select map30
   - Act: Observe grid rendering
   - Assert: Road tiles render as labyrinth, no visual gaps
   - Expected: Visual labyrinth appearance, continuous road

5. **Manual E2E: Bug Movement**
   - Arrange: Run game, spawn bug on map30
   - Act: Watch bug follow path
   - Assert: Bug reaches house, no stuck/drift
   - Expected: Bug completes path smoothly

**Coverage Target:**
- 100% of new map30 code (enum case, switch case, path method)
- Integration with existing expandPath() and roadPath systems
- No testing of unchanged code (Bug movement, grid rendering already tested)

**Stop Rules:**
- All unit tests pass twice consistently
- Manual testing shows correct visual and behavioral output
- No compilation errors or warnings
- No performance degradation observed

**Out-of-Scope:**
- Re-testing Bug.swift movement logic (unchanged, covered by TASK1)
- Re-testing expandPath() algorithm (unchanged, working for 20 maps)
- Re-testing GameScene rendering (unchanged, working for existing maps)
- Performance benchmarking (path length within normal range)

When all tests pass and manual verification succeeds, set first line to `Fully implemented: YES`.
