Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack: Swift 5.x, SpriteKit, Swift Package Manager
- Project structure and architecture
- Grid system: 20x15 tiles, safe zone x:1-18, y:1-13, house at (10,7)
- Coding conventions and patterns
- Related code examples with file:line references
- Integration points and dependencies

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Design Cloverleaf Pattern Layout**
  - **What to do:**
    1. Sketch a cloverleaf pattern on 20x15 grid with house at center (10,7)
    2. Design four arc segments (petals) extending from center area toward quadrants
    3. Plan waypoint sequence: start edge → top-left petal → top-right petal → bottom-right petal → bottom-left petal → spiral to house
    4. Use 3-5 waypoints per petal arc for smooth curves (not angular)
    5. Ensure total path length ~50-70 expanded waypoints (moderate-high difficulty)
    6. Verify all waypoints within safe zone (x:1-18, y:1-13)
    7. Create mental map of strategic tower placement zones around loops

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:115-631` — All existing map path definitions for pattern inspiration
    - `Sources/BugDefense/MapConfiguration.swift:350-412` — Map 11 (Box Spiral) shows complex looping pattern with multiple segments
    - `Sources/BugDefense/MapConfiguration.swift:184-202` — Map 4 (Double Loop) shows circular arc construction
    - `Sources/BugDefense/MapConfiguration.swift:168-182` — Map 3 (S-Curve) shows smooth diagonal transitions
    - `Sources/BugDefense/GameConfiguration.swift:169-185` — GridPosition struct definition and toWorldPosition() method
    - `.claudiomiro/AI_PROMPT.md:39-44` — Grid system specifications and safe zone boundaries

  - **Touched (will modify/create):**
    - NONE (design phase only - no files modified)

  - **Interfaces / Contracts:**
    - Path array must be `[GridPosition]` where GridPosition has x,y Int properties
    - First waypoint: edge position (x=1, x=18, y=1, or y=13)
    - Last waypoint: house position GridPosition(x: 10, y: 7)
    - All intermediate waypoints: within safe zone x:1-18, y:1-13

  - **Tests:**
    Type: Design validation (manual verification)
    - Happy path: Four distinct petal arcs visible in pattern
    - Edge case: All waypoints within safe zone boundaries
    - Edge case: Path doesn't overlap house until final waypoint
    - Edge case: Smooth arcs (not jagged corners) using 3-5 points per petal

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    N/A - Design phase only

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Path length target: 15-20 waypoint corners (expands to 50-70 tiles)
    - Algorithmic complexity: O(1) map selection, O(n) path expansion where n=waypoints
    - Memory: ~20 GridPosition structs (16 bytes each) = ~320 bytes per map

  - **Commands:**
    ```bash
    # No commands for design phase
    # Visual verification: sketch pattern on paper or grid tool
    ```

  - **Risks & Mitigations:**
    - **Risk:** Arcs may look jagged with too few waypoints
      **Mitigation:** Use 3-5 waypoints per petal arc to create smooth curves
    - **Risk:** Path may be too short or too long
      **Mitigation:** Aim for 15-20 waypoint corners which expands to 50-70 tiles (reference: Map 11 has ~60 waypoints)

- [ ] **Item 2 — Implement Map 22 Enum and Path Method**
  - **What to do:**
    1. Open `Sources/BugDefense/MapConfiguration.swift`
    2. Add enum case after line 25: `case map22 = "Cloverleaf Loop"`
    3. Add switch case after line 63: `case .map22: basePath = map22Path`
    4. Implement `map22Path` method after line 631 (after map20Path method, before closing brace)
    5. Follow pattern: `private var map22Path: [GridPosition] { return [...] }`
    6. Define 15-20 waypoint GridPositions creating cloverleaf pattern from design phase
    7. Ensure first waypoint at edge and last at GridPosition(x: 10, y: 7)
    8. Add comment describing pattern: `// Map 22: Cloverleaf Loop - Four-petal arc pattern around center`

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:1-68` — MapType enum structure and roadPath switch statement
    - `Sources/BugDefense/MapConfiguration.swift:117-137` — Map 1 pattern example (simple path method)
    - `Sources/BugDefense/MapConfiguration.swift:350-412` — Map 11 pattern example (complex multi-segment path)
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath() method that fills intermediate tiles
    - `Sources/BugDefense/GameConfiguration.swift:169-185` — GridPosition struct usage

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add enum case (line ~26)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add switch case (line ~64)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map22Path method (line ~632)

  - **Interfaces / Contracts:**
    - Export: MapType.map22 case (CaseIterable automatically includes in allCases)
    - Export: map22Path computed property returning [GridPosition]
    - Contract: Path integrated into roadPath switch, expanded via expandPath()
    - Contract: MapType.random() will include map22 in random selection pool

  - **Tests:**
    Type: Unit tests in new test file
    - Happy path: map22Path returns valid [GridPosition] array
    - Happy path: First waypoint at edge position (x=1 or x=18 or y=1 or y=13)
    - Happy path: Last waypoint equals GridPosition(x: 10, y: 7)
    - Edge case: All waypoints within bounds (x: 0-19, y: 0-14)
    - Edge case: All waypoints within safe zone (x: 1-18, y: 1-13)
    - Edge case: Path count >= 2 waypoints
    - Failure: N/A (compile-time validation)

  - **Migrations / Data:**
    N/A - No data changes (compile-time enum addition)

  - **Observability:**
    - Existing MapManager already logs: "🗺️ Selected map: \(map.displayName)" (MapConfiguration.swift:645)
    - No additional logging needed

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Path definition: O(1) array literal construction
    - Path expansion: O(n*m) where n=waypoints, m=avg distance between waypoints
    - Target: 15-20 waypoints → expands to 50-70 tiles
    - Memory: Negligible (statically defined array)

  - **Commands:**
    ```bash
    # Compile check
    swift build

    # Run tests (after test implementation in Item 3)
    swift test --filter MapConfigurationTests
    ```

  - **Risks & Mitigations:**
    - **Risk:** Typo in GridPosition coordinates could create invalid path
      **Mitigation:** Visual inspection and bounds testing (Item 3)
    - **Risk:** Switch statement not updated causes runtime crash
      **Mitigation:** Compiler will warn about non-exhaustive switch when adding enum case
    - **Risk:** Path doesn't reach house position
      **Mitigation:** Unit test validates last waypoint equals (10,7)

- [ ] **Item 3 — Create Unit Tests for Map 22 Validation**
  - **What to do:**
    1. Create test file: `Tests/BugDefenseTests/MapConfigurationTests.swift`
    2. Import XCTest and @testable import BugDefense
    3. Follow test pattern from `Tests/BugDefenseTests/BugMovementTests.swift:1-26` (imports, @MainActor annotation)
    4. Implement test class: `final class MapConfigurationTests: XCTestCase`
    5. Write test: `testMap22PathValidityAndBounds()` validating:
       - Path count >= 2
       - First waypoint at edge (x=1 or x=18 or y=1 or y=13)
       - Last waypoint = GridPosition(x: 10, y: 7)
       - All waypoints within grid bounds (x: 0-19, y: 0-14)
       - All waypoints within safe zone (x: 1-18, y: 1-13)
    6. Write test: `testMap22IncludedInAllCases()` validating MapType.allCases contains .map22
    7. Write test: `testMap22CanBeRandomlySelected()` validating MapType.random() can return .map22
    8. Use XCTAssert family (XCTAssertEqual, XCTAssertTrue, XCTAssertGreaterThanOrEqual)

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugMovementTests.swift:1-26` — Test file structure and import pattern
    - `Tests/BugDefenseTests/BugMovementTests.swift:16-26` — Example helper function pattern
    - `Tests/BugDefenseTests/BugMovementTests.swift:70-119` — Example test method structure
    - `Sources/BugDefense/MapConfiguration.swift:5-38` — MapType enum and random() method
    - `Sources/BugDefense/GameConfiguration.swift:169-185` — GridPosition equality and properties

  - **Touched (will modify/create):**
    - CREATE: `Tests/BugDefenseTests/MapConfigurationTests.swift`

  - **Interfaces / Contracts:**
    - Test interface: XCTest framework
    - Validates: MapType.map22.roadPath contract
    - Validates: GridPosition bounds contract
    - Validates: CaseIterable.allCases contract

  - **Tests:**
    Type: Unit tests (this item IS the tests)
    - Happy path: Map 22 path is valid with proper start and end
    - Edge case: All waypoints respect bounds and safe zone
    - Edge case: Map 22 appears in allCases and random selection

  - **Migrations / Data:**
    N/A - Test file creation only

  - **Observability:**
    - Test output shows pass/fail for each test case
    - XCTest provides detailed assertion failure messages

  - **Security & Permissions:**
    N/A - No security concerns in tests

  - **Performance:**
    - Test execution: < 100ms (simple array validation)
    - No performance targets (tests are fast)

  - **Commands:**
    ```bash
    # Run only new tests
    swift test --filter MapConfigurationTests

    # Run all tests to ensure no regression
    swift test
    ```

  - **Risks & Mitigations:**
    - **Risk:** Tests may fail if map22Path not implemented correctly
      **Mitigation:** Expected - tests verify correctness, fix path if tests fail
    - **Risk:** Random selection test may be flaky
      **Mitigation:** Use deterministic check (verify map22 in allCases, not random sampling)

- [ ] **Item 4 — Manual Gameplay Verification**
  - **What to do:**
    1. Build and run the game: `swift build && swift run`
    2. Modify `Sources/BugDefense/MapConfiguration.swift:639` temporarily to start with map22: `private(set) var currentMap: MapType = .map22`
    3. Launch game and observe:
       - Road tiles (brown) render along cloverleaf path
       - Four distinct petal arcs visible
       - Grass tiles (green) fill non-road areas
       - House at center (10,7) with dark green tile
    4. Spawn bugs and verify:
       - Bugs spawn at first waypoint (edge position)
       - Bugs follow path smoothly through all four petals
       - Bugs navigate arcs without diagonal drift
       - Bugs reach house at final waypoint
    5. Test tower placement:
       - Cannot place towers on road tiles (blocked)
       - Can place towers in strategic positions around petals
       - Towers can attack bugs as they loop through petals
    6. Test map switching:
       - Revert temporary change to line 639 (restore `.map1`)
       - Verify MapManager.shared.selectRandomMap() can select map22
       - Verify grid redraws correctly when switching to/from map22
    7. Document any visual or gameplay issues found

  - **Context (read-only):**
    - `Sources/BugDefense/GameScene.swift:237-304` — Grid rendering system (road/grass tiles)
    - `Sources/BugDefense/GameScene.swift:488-504` — Bug spawning and path assignment
    - `Sources/BugDefense/Bug.swift:240-302` — Bug waypoint following movement logic
    - `Sources/BugDefense/GameScene.swift:826-856` — Tower placement validation (canPlaceStructure)
    - `Sources/BugDefense/MapConfiguration.swift:634-664` — MapManager selection logic
    - `.claudiomiro/AI_PROMPT.md:75-89` — Visual grid system description

  - **Touched (will modify/create):**
    - MODIFY (temporarily): `Sources/BugDefense/MapConfiguration.swift:639` — Change to .map22 for testing, then revert
    - NONE (permanent) — Manual testing only, no code changes

  - **Interfaces / Contracts:**
    - Visual contract: Road tiles render along path
    - Gameplay contract: Bugs follow path precisely
    - UI contract: Tower placement blocked on roads
    - System contract: Map switching triggers grid redraw

  - **Tests:**
    Type: Manual integration and visual verification
    - Happy path: Cloverleaf pattern renders correctly with four visible petals
    - Happy path: Bugs complete full path from spawn to house
    - Happy path: Towers can be placed strategically around loops
    - Edge case: Smooth arc navigation (no stair-stepping on diagonals)
    - Edge case: Map switching works without crashes or orphaned bugs
    - Failure: Tower placement correctly rejected on road tiles

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Observe console logs: "🛣️ Using predefined road path for..." (GameScene.swift:499)
    - Observe console logs: "🗺️ Selected map: Cloverleaf Loop" (MapConfiguration.swift:645)
    - Visual observation of bug movement and tile rendering

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Visual performance: 60 FPS gameplay (no degradation expected)
    - Path following: Bugs should move smoothly at expected speed
    - Grid redraw: Should be instant when switching maps

  - **Commands:**
    ```bash
    # Build and run game
    swift build
    swift run

    # Or if on macOS with Xcode:
    open BugDefense.xcodeproj
    # Then Run in Xcode (Cmd+R)
    ```

  - **Risks & Mitigations:**
    - **Risk:** Visual bugs (gaps in road, wrong tiles)
      **Mitigation:** Indicates path definition issue - fix waypoints in map22Path
    - **Risk:** Bugs get stuck or oscillate
      **Mitigation:** Check waypoint spacing - may need to adjust positions
    - **Risk:** Path doesn't look like cloverleaf
      **Mitigation:** Redesign waypoints to better match four-petal pattern
    - **Risk:** Game crashes on map22 selection
      **Mitigation:** Indicates enum/switch mismatch - verify all three locations updated

## Verification (global)

- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Unit tests for new map validation
      swift test --filter MapConfigurationTests

      # Compile check (entire project)
      swift build

      # Full test suite (ensure no regression)
      swift test
      ```
      **CRITICAL:** Do not run full-project checks beyond compilation and test suite
- [ ] All acceptance criteria met (see below)
- [ ] Code follows Swift conventions: camelCase, private methods, descriptive names
- [ ] Integration points working: enum case, switch statement, path method all in sync
- [ ] Map 22 appears in MapType.allCases and random selection pool
- [ ] Visual verification: cloverleaf pattern renders with four distinct petals
- [ ] Gameplay verification: bugs navigate path correctly, towers placeable around loops

## Acceptance Criteria

- [ ] Map 22 enum case added to MapType in MapConfiguration.swift
- [ ] map22Path method implemented with cloverleaf pattern
- [ ] Path added to roadPath switch statement
- [ ] All waypoints within safe zone (x:1-18, y:1-13)
- [ ] Path starts at edge position (x=1 or x=18 or y=1 or y=13)
- [ ] Path ends at house position GridPosition(x: 10, y: 7)
- [ ] Pattern creates 4 distinct arc segments (four petals)
- [ ] Arcs are smooth (use 3-5 waypoints per petal, not angular)
- [ ] Code compiles without errors: `swift build` succeeds
- [ ] Unit tests pass: testMap22PathValidityAndBounds, testMap22IncludedInAllCases
- [ ] Manual test: bugs navigate path correctly from spawn to house
- [ ] Manual test: road tiles render forming recognizable cloverleaf shape
- [ ] Manual test: towers can be placed in strategic positions around loops
- [ ] Manual test: tower placement correctly blocked on road tiles
- [ ] Path length ~50-70 expanded waypoints (moderate-high difficulty)
- [ ] Map 22 can be randomly selected via MapType.random()

## Impact Analysis

- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift:5-26` — MapType enum (new .map22 case)
  - `Sources/BugDefense/MapConfiguration.swift:43-64` — roadPath switch (new .map22 case)
  - `Sources/BugDefense/MapConfiguration.swift:632` — new map22Path method after map20Path
  - `Tests/BugDefenseTests/MapConfigurationTests.swift` — new test file

- **Indirectly impacted:**
  - `MapType.allCases` — automatically includes .map22 (CaseIterable protocol)
  - `MapType.random()` — now can return .map22 (uses allCases.randomElement())
  - `MapManager.selectRandomMap()` — can select map22 from expanded pool
  - `GameScene.spawnBug()` — will use map22 path when map is selected
  - Grid rendering system — will render cloverleaf road tiles when map22 active
  - Tower placement validation — will block placement on map22 road tiles
  - Future TASK11 (Integration) and TASKΩ (Final validation) depend on this map

## Follow-ups

- None identified - requirements are clear and complete
- If visual verification reveals path looks different than intended, adjust waypoint positions in map22Path method
- If performance issues occur (unlikely), consider reducing waypoint count
