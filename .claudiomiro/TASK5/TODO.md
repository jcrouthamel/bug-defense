Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK5/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK5/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack and framework versions (Swift 5.x, SpriteKit)
- Project structure and architecture (Entity-Component pattern)
- Coding conventions and patterns (enum-based map definitions)
- Related code examples with file:line references (existing 20 maps)
- Integration points and dependencies (waypoint system from TASK0)

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Design and Implement Map 25 with Diagonal Cross (X) Pattern**
  - **What to do:**
    1. Design a diagonal X-shaped path on paper/sketch (20x15 grid, safe zone x:1-18, y:1-13)
       - Create an X pattern where bugs traverse diagonally from one corner through the center
       - Path should emphasize diagonal movement (tests vector movement system from TASK1)
       - End at house position: GridPosition(x: 10, y: 7)
       - Target path length: 25-40 waypoints (easier/shorter difficulty)

    2. Open `Sources/BugDefense/MapConfiguration.swift` and add `.map25` enum case
       - Add to MapType enum after `.map20` (line ~24): `case map25 = "Diagonal Cross"`

    3. Implement `map25Path` private computed property (after map20Path, line ~631)
       - Follow pattern from `map15Path` (line 507-519) which shows clean diagonal movement
       - Create waypoint array starting from an edge corner (e.g., x:1-2, y:1-3 or y:11-13)
       - Design diagonal segments crossing through or near center (x:10, y:7)
       - Each waypoint should be GridPosition(x: Int, y: Int)
       - Example diagonal segments: move +1 x and +1 y per waypoint for 45° diagonal
       - Ensure strong diagonal movement (multiple consecutive diagonal waypoints)
       - End exactly at GridPosition(x: 10, y: 7)

    4. Add case to `roadPath` switch statement (line 43-63)
       - Add after `case .map20:`: `case .map25: basePath = map25Path`

    5. Design considerations:
       - X-pattern can be: corner→center, then angle to house OR slash/backslash diagonal
       - Verify no waypoints go outside safe zone (x must be 1-18, y must be 1-13)
       - Path should be visually distinct (clear diagonal appearance when rendered)
       - The expandPath() method (line 70-103) will automatically fill intermediate tiles

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:4-24` — MapType enum definition pattern
    - `Sources/BugDefense/MapConfiguration.swift:39-67` — roadPath switch statement structure
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath() algorithm (handles diagonal interpolation)
    - `Sources/BugDefense/MapConfiguration.swift:105-108` — housePosition definition (always x:10, y:7)
    - `Sources/BugDefense/MapConfiguration.swift:507-519` — map15Path (diagonal example)
    - `Sources/BugDefense/MapConfiguration.swift:118-137` — map1Path (typical waypoint structure)
    - `Sources/BugDefense/MapConfiguration.swift:614-631` — map20Path (last existing map, add after this)
    - `Sources/BugDefense/GameConfiguration.swift:169-183` — GridPosition struct (x, y coordinates)
    - `Tests/BugDefenseTests/BugMovementTests.swift:174-220` — Diagonal path test (shows diagonal movement works)

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add .map25 enum case (line ~24)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add case .map25 to switch (line ~62)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map25Path method (line ~631)

  - **Interfaces / Contracts:**
    - **Enum Case:** `.map25 = "Diagonal Cross"` (String raw value for display)
    - **Path Method:** `private var map25Path: [GridPosition]` returns array of waypoints
    - **Contract:** First waypoint = spawn point (edge), last waypoint = GridPosition(x: 10, y: 7)
    - **Grid Bounds:** All positions must satisfy: x ∈ [1,18], y ∈ [1,13]
    - **Path Length:** 25-40 waypoints (key turning points before expansion)
    - **Integration:** MapType.allCases automatically includes .map25 (via CaseIterable)

  - **Tests:**
    Type: unit tests with XCTest (Swift testing framework)
    - **Path validity:** Map25 path has at least 2 waypoints
    - **End point:** Last waypoint equals house position GridPosition(x: 10, y: 7)
    - **Bounds check:** All waypoints within safe zone (x: 1-18, y: 1-13)
    - **Diagonal segments:** Verify at least 5+ consecutive diagonal waypoints (Δx=Δy per step)
    - **Compilation:** Code compiles without errors (`swift build`)
    - **Visual verification (manual):** Run game and select map25 to verify X-pattern visible

  - **Migrations / Data:**
    N/A - No data changes (compile-time map definition)

  - **Observability:**
    N/A - No observability requirements (static map data)

  - **Security & Permissions:**
    N/A - No security concerns (local game data)

  - **Performance:**
    - Path definition is O(1) - returns pre-computed array
    - Path expansion (expandPath) is O(n) where n = waypoints, runs once at map load
    - Target: Path length 25-40 waypoints (before expansion) = ~40-80 tiles after expansion
    - Keep waypoint count reasonable to avoid excessive path rendering

  - **Commands:**
    ```bash
    # Development - Compile and verify no syntax errors
    swift build

    # Run app to visually test map (macOS)
    swift run BugDefenseApp

    # Unit tests - After adding test cases in Item 2
    swift test --filter MapConfigurationTests
    ```

  - **Risks & Mitigations:**
    - **Risk:** Path goes outside safe zone (x<1, x>18, y<1, or y>13)
      **Mitigation:** Double-check every waypoint coordinate against bounds. Use existing maps as reference.

    - **Risk:** Path doesn't create clear X-pattern visually
      **Mitigation:** Sketch on paper first. Ensure diagonal segments have consistent Δx=Δy movement.

    - **Risk:** Path doesn't end at house position (x:10, y:7)
      **Mitigation:** Always set last waypoint to `GridPosition(x: 10, y: 7)` explicitly.

    - **Risk:** Diagonal movement causes stair-stepping
      **Mitigation:** Vector movement system (TASK1) handles this. Use consistent diagonal waypoints (e.g., (2,2)→(3,3)→(4,4)).

- [ ] **Item 2 — Add Unit Test for Map 25 Path Validity**
  - **What to do:**
    1. Open `Tests/BugDefenseTests/BugDefenseTests.swift` or create new `MapConfigurationTests.swift`
       - If creating new file, follow pattern from `BugMovementTests.swift:1-5` (import XCTest, @testable import BugDefense, @MainActor, class declaration)

    2. Add test method `testMap25PathValidity()`
       - Get map25 path: `let path = MapType.map25.roadPath`
       - Assert: `XCTAssertGreaterThanOrEqual(path.count, 2, "Map25 must have at least 2 waypoints")`
       - Assert: `XCTAssertEqual(path.last, GridPosition(x: 10, y: 7), "Map25 must end at house")`
       - Loop through all waypoints and assert bounds:
         ```swift
         for pos in path {
             XCTAssertTrue(pos.x >= 1 && pos.x <= 18, "Waypoint \(pos) x out of bounds")
             XCTAssertTrue(pos.y >= 1 && pos.y <= 13, "Waypoint \(pos) y out of bounds")
         }
         ```

    3. Add test method `testMap25HasDiagonalSegments()`
       - Iterate through consecutive waypoint pairs
       - Count segments where |Δx| == |Δy| (diagonal movement)
       - Assert at least 5 diagonal segments exist (to verify X-pattern emphasis)

    4. Add test method `testMap25InMapTypeAllCases()`
       - Assert: `XCTAssertTrue(MapType.allCases.contains(.map25), "Map25 must be in allCases")`
       - Assert: `XCTAssertGreaterThanOrEqual(MapType.allCases.count, 21, "Should have 21+ maps")`

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugMovementTests.swift:1-26` — Test file structure and helper patterns
    - `Tests/BugDefenseTests/BugMovementTests.swift:70-119` — Example path validation test structure
    - `Sources/BugDefense/MapConfiguration.swift:4-24` — MapType enum (CaseIterable)
    - `Sources/BugDefense/GameConfiguration.swift:169-183` — GridPosition definition

  - **Touched (will modify/create):**
    - CREATE: `Tests/BugDefenseTests/MapConfigurationTests.swift` (recommended) OR
    - MODIFY: `Tests/BugDefenseTests/BugDefenseTests.swift` — Add test methods

  - **Interfaces / Contracts:**
    - **Test Class:** `@MainActor final class MapConfigurationTests: XCTestCase`
    - **Test Methods:** `func testMap25PathValidity()`, `func testMap25HasDiagonalSegments()`, `func testMap25InMapTypeAllCases()`
    - **Assertions:** Use XCTest assertions (XCTAssertEqual, XCTAssertTrue, etc.)

  - **Tests:**
    Type: unit tests with XCTest
    - **Happy path:** Map25 path is valid (bounds, end point, diagonal segments)
    - **Edge case:** Path has minimum 2 waypoints
    - **Edge case:** All waypoints within safe zone (no x=0, x=19, y=0, y=14)
    - **Integration:** Map25 appears in MapType.allCases (CaseIterable)

  - **Migrations / Data:**
    N/A - Test code only

  - **Observability:**
    N/A - Test output via XCTest framework

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Tests should complete in <100ms (trivial array operations)
    - No performance requirements

  - **Commands:**
    ```bash
    # Run only map configuration tests
    swift test --filter MapConfigurationTests

    # Run all tests (if modifying existing test file)
    swift test

    # Build before testing (ensure compilation)
    swift build
    ```

  - **Risks & Mitigations:**
    - **Risk:** Test file not found or doesn't compile
      **Mitigation:** Follow exact pattern from BugMovementTests.swift. Use @MainActor, import @testable import BugDefense.

    - **Risk:** Tests fail due to incorrect bounds or end point
      **Mitigation:** Fix map25Path implementation in Item 1. Re-verify waypoint coordinates.

    - **Risk:** Diagonal segment detection too strict (no diagonals detected)
      **Mitigation:** Check Δx == Δy logic. May need to count waypoint pairs where dx==dy and both != 0.

- [ ] **Item 3 — Manual Visual Verification and Bug Navigation Test**
  - **What to do:**
    1. Build and run the game application
       ```bash
       swift build
       swift run BugDefenseApp
       ```

    2. Force map25 selection (if random selection doesn't pick it immediately)
       - Option A: Modify `MapManager.shared.currentMap = .map25` in GameScene.swift temporarily
       - Option B: Add debug code to force map25 in GameScene.swift init or setupMap()
       - Option C: Restart game multiple times until map25 loads (random selection)

    3. Visual verification checklist:
       - [ ] Road tiles (brown) render along diagonal X-pattern
       - [ ] Path is clearly visible as X-shape or diagonal slash
       - [ ] No visual gaps in road rendering
       - [ ] House (dark green) is at center position
       - [ ] Path stays within visible grid bounds (no off-screen tiles)

    4. Bug navigation verification:
       - [ ] Start a wave and spawn bugs
       - [ ] Observe bugs follow diagonal path smoothly (no stair-stepping)
       - [ ] Bugs navigate corners/turns precisely
       - [ ] Bugs reach house at end of path
       - [ ] No bugs get stuck or oscillate
       - [ ] Diagonal movement is smooth (tests vector movement from TASK1)

    5. Tower placement verification:
       - [ ] Cannot place towers on road tiles (blocked)
       - [ ] Can place towers on grass tiles around path
       - [ ] Strategic placement areas exist around diagonal segments

    6. Document results:
       - Take screenshot or note visual appearance
       - Confirm diagonal movement works without issues
       - Report any anomalies (stuck bugs, visual gaps, etc.)

  - **Context (read-only):**
    - `Sources/BugDefense/GameScene.swift:237-304` — Grid rendering system
    - `Sources/BugDefense/GameScene.swift:488-504` — Bug spawning and path assignment
    - `Sources/BugDefense/GameScene.swift:826-856` — Tower placement validation
    - `Sources/BugDefense/Bug.swift:240-302` — Bug movement logic (waypoint following)
    - `.claudiomiro/AI_PROMPT.md:57-76` — Vector movement implementation details

  - **Touched (will modify/create):**
    - TEMPORARY MODIFY: `Sources/BugDefense/GameScene.swift` — Force map25 for testing (revert after)
    - Or: No modifications (use random selection)

  - **Interfaces / Contracts:**
    - Manual testing - no code contracts
    - Visual verification against design criteria from TASK.md

  - **Tests:**
    Type: manual integration/e2e testing
    - **Visual:** X-pattern clearly visible on grid
    - **Navigation:** Bugs traverse diagonal segments smoothly
    - **Completion:** Bugs reach house at path end
    - **Gameplay:** Towers can be placed strategically around path

  - **Migrations / Data:**
    N/A - Manual testing only

  - **Observability:**
    - Observe console logs for any errors during map load
    - Watch for SpriteKit warnings about missing nodes or positions

  - **Security & Permissions:**
    N/A - Local app testing

  - **Performance:**
    - Observe frame rate (should maintain 60 FPS on macOS)
    - No lag during bug spawning or movement
    - Grid rendering should be instantaneous

  - **Commands:**
    ```bash
    # Build for testing
    swift build

    # Run application (macOS)
    swift run BugDefenseApp

    # If using iOS simulator (if applicable)
    # Note: May need Xcode for simulator, Package.swift supports iOS target
    open BugDefense.xcodeproj  # If project file exists
    ```

  - **Risks & Mitigations:**
    - **Risk:** Map25 doesn't load (random selection picks other maps)
      **Mitigation:** Temporarily force map25 in code OR restart multiple times. Verify .map25 in allCases.

    - **Risk:** Diagonal segments show stair-stepping (visual artifact)
      **Mitigation:** Vector movement (TASK1) should prevent this. If occurs, verify waypoint spacing is consistent.

    - **Risk:** Bugs get stuck or don't reach house
      **Mitigation:** Check last waypoint is exactly GridPosition(x: 10, y: 7). Verify no duplicate/backwards waypoints.

    - **Risk:** Visual gaps in road rendering
      **Mitigation:** expandPath() should fill gaps. If gaps exist, verify waypoints are connected (no jumps >1 tile apart in dense areas).

## Verification (global)

- [ ] Run targeted tests for Map 25 implementation:
      ```bash
      # Build first to catch compilation errors
      swift build

      # Run map configuration tests (if created new test file)
      swift test --filter MapConfigurationTests

      # Run all tests to ensure no regressions
      swift test
      ```
      **CRITICAL:** Do not run full-project checks beyond `swift build` and `swift test`

- [ ] All acceptance criteria met (see below)
- [ ] Code follows Swift conventions from AI_PROMPT.md (enum pattern, private computed properties)
- [ ] Integration points properly implemented:
  - [ ] .map25 in MapType enum
  - [ ] map25Path returns valid [GridPosition] array
  - [ ] Switch case added to roadPath
  - [ ] MapType.allCases includes .map25 automatically
- [ ] Compilation succeeds without errors or warnings
- [ ] Visual verification completed (X-pattern visible, bugs navigate smoothly)

## Acceptance Criteria

- [ ] Map 25 added with diagonal cross (X-shaped) pattern clearly visible
- [ ] Path emphasizes diagonal movement with strong diagonal segments
- [ ] All waypoints within safe zone (x: 1-18, y: 1-13)
- [ ] Path ends at house position GridPosition(x: 10, y: 7)
- [ ] Path length is 25-40 waypoints (easier/shorter difficulty)
- [ ] Code compiles successfully (`swift build` exits 0)
- [ ] Bugs navigate diagonal segments smoothly without stair-stepping
- [ ] Road tiles render along entire path without visual gaps
- [ ] Map25 appears in MapType.allCases and can be selected
- [ ] Unit tests pass (path validity, bounds, diagonal segments)
- [ ] Manual testing confirms visual X-pattern and smooth bug movement
- [ ] No stair-stepping on diagonal segments (vector movement works)
- [ ] Pattern is visually distinct from existing 20 maps

## Impact Analysis

- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift:24` (new enum case .map25)
  - `Sources/BugDefense/MapConfiguration.swift:62` (new switch case)
  - `Sources/BugDefense/MapConfiguration.swift:631+` (new map25Path method)
  - `Tests/BugDefenseTests/MapConfigurationTests.swift` (new test file) OR `Tests/BugDefenseTests/BugDefenseTests.swift` (new test methods)

- **Indirectly impacted:**
  - `MapType.allCases` — Automatically includes .map25 (CaseIterable protocol)
  - `MapManager.selectRandomMap()` — Can now select map25 randomly
  - `GameScene.swift:237-304` — Grid rendering will render map25 road tiles
  - `GameScene.swift:488-504` — Bug spawning will use map25 path when selected
  - Future TASK6-TASK10 (parallel map implementations) — Follow same pattern
  - TASK11 (depends on TASK5) — Will test/use map25
  - TASKΩ (final validation) — Will verify map25 works correctly

## Follow-ups

None identified. Task scope is clear with well-defined patterns to follow from existing 20 maps.

## Diff Test Plan

**Changed files:**
- `Sources/BugDefense/MapConfiguration.swift` — Added .map25 enum, switch case, map25Path method
- `Tests/BugDefenseTests/MapConfigurationTests.swift` — New test file (or modified BugDefenseTests.swift)

**Tests to prove correctness:**

1. **Unit: Map25 path validity**
   - Arrange: Get MapType.map25.roadPath
   - Act: Check path properties (count, bounds, end point)
   - Assert: Path has ≥2 waypoints, ends at house, all within bounds
   - Expected: All assertions pass

2. **Unit: Map25 has diagonal segments**
   - Arrange: Get map25Path waypoints
   - Act: Count consecutive pairs where |Δx| == |Δy|
   - Assert: At least 5 diagonal segments exist
   - Expected: Count ≥ 5

3. **Unit: Map25 in allCases**
   - Arrange: Get MapType.allCases
   - Act: Check contains .map25
   - Assert: .map25 in allCases, count ≥ 21
   - Expected: True

4. **Integration (manual): Visual X-pattern**
   - Arrange: Run app, load map25
   - Act: Observe grid rendering
   - Assert: X-pattern visible, road tiles along diagonals
   - Expected: Clear diagonal cross pattern

5. **Integration (manual): Smooth diagonal movement**
   - Arrange: Run app, spawn bugs on map25
   - Act: Observe bug movement along diagonal path
   - Assert: No stair-stepping, smooth diagonal traversal
   - Expected: Bugs move in straight diagonal lines

**Coverage target:** 100% of new code (map25Path method, enum case, switch case, tests)

**Unrelated failures:** If other maps fail tests, document as "Known Out-of-Scope" (not caused by map25 changes)

**Stop rule:** All 5 tests pass twice consistently, visual verification confirms X-pattern and smooth movement
