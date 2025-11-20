Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK7/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK7/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Swift/SpriteKit tech stack and framework
- Project structure and MapConfiguration architecture
- Existing map naming conventions and patterns
- GridPosition coordinate system and waypoint patterns
- Integration points with MapManager and Bug movement system

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Design and Implement Map 27 Figure-8 Pattern**
  - **What to do:**
    1. Design a figure-8 (infinity symbol) waypoint pattern on the 20x15 grid
       - Start from an edge position within safe zone (x:1-18, y:1-13)
       - Create two distinct loops that cross through the center area
       - Ensure crossing point is clearly visible (near or through GridPosition(x: 10, y: 7))
       - End at house position GridPosition(x: 10, y: 7)
       - Target path length: 45-60 waypoints (after expansion)
       - Balance loop sizes (similar radius for both upper and lower loops)
    2. Add new enum case to MapType in `Sources/BugDefense/MapConfiguration.swift`
       - Follow pattern: `case map27 = "Figure Eight"` after map20 (line ~26)
    3. Implement path method `map27Path` following existing pattern
       - Define key waypoint corners that form figure-8 shape
       - Use GridPosition arrays with smooth transitions between loops
       - Path will be auto-expanded by `expandPath()` method (lines 70-103)
       - Reference map7Path (lines 259-277) for figure-eight inspiration, but create distinct pattern
    4. Add switch case in `roadPath` computed property (line ~64)
       - Add `case .map27: basePath = map27Path` to switch statement
    5. Verify pattern visually (sketch on paper or mentally trace):
       ```
       Example figure-8 structure (adapt as needed):
            Start→─╮
                  ╱ ╲
                 ╱   ╲
                │  ╳  │  ← Center crossing
                 ╲   ╱
                  ╲ ╱
                   ╰→End (house)
       ```
    6. Ensure path stays strictly within safe zone boundaries
       - x coordinates: 1-18 (not 0 or 19)
       - y coordinates: 1-13 (not 0 or 14)
    7. Test compilation with `swift build`

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:5-26` — Existing MapType enum cases and naming pattern
    - `Sources/BugDefense/MapConfiguration.swift:40-68` — roadPath switch statement structure
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath() algorithm (understand, don't modify)
    - `Sources/BugDefense/MapConfiguration.swift:259-277` — map7Path (existing Figure Eight for reference)
    - `Sources/BugDefense/MapConfiguration.swift:350-412` — map11Path (Box Spiral - complex path example)
    - `Sources/BugDefense/MapConfiguration.swift:184-201` — map4Path (Double Loop pattern reference)
    - `.claudiomiro/AI_PROMPT.md:39-45` — Grid system and safe zone constraints

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map27 enum case (~line 26)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Implement map27Path method (~line 632, after map20Path)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map27 case to roadPath switch (~line 64)

  - **Interfaces / Contracts:**
    - **MapType enum:** Add `.map27 = "Figure Eight"` case
    - **Path method signature:** `private var map27Path: [GridPosition] { ... }`
    - **Return type:** `[GridPosition]` array of waypoint corners (will be expanded automatically)
    - **Contract requirements:**
      - Path must start within safe zone edge (x:1-18, y:1-13)
      - Path must end at GridPosition(x: 10, y: 7) (house position)
      - All waypoints must be within safe zone
      - Path should form visually distinct figure-8 pattern with center crossing
      - Two loops should be balanced (similar size)

  - **Tests:**
    Type: Unit tests with XCTest framework
    - **Happy path:** Map27 path is valid and ends at house position
      - `testMap27PathValidity()`: Verify path.count >= 2, path.last == GridPosition(x: 10, y: 7)
    - **Edge case:** All waypoints stay within safe zone boundaries
      - `testMap27PathBounds()`: Verify all positions have x:1-18, y:1-13
    - **Edge case:** Figure-8 pattern has two distinct loop segments
      - `testMap27FigureEightPattern()`: Verify path has crossing point and two loops
    - **Integration:** Map27 can be selected randomly
      - `testMapRandomSelectionIncludesMap27()`: Verify MapType.allCases.count >= 27
    - **Happy path:** expandPath() correctly fills intermediate tiles
      - Covered by existing expandPath tests (don't re-test)

  - **Migrations / Data:**
    N/A - No data migrations needed. Map definitions are compile-time constants.

  - **Observability:**
    - Existing MapManager logging will automatically handle map27 selection
    - MapManager.selectMap(_:) logs "🗺️ Selected map: Figure Eight" (line 645)
    - MapManager.selectRandomMap() logs random selection (line 650)
    - No additional logging needed

  - **Security & Permissions:**
    N/A - No security concerns. This is a local game feature with no user input, network access, or sensitive data.

  - **Performance:**
    - Path definition: O(1) - static array initialization
    - Path expansion: O(n) where n = waypoints - handled by existing expandPath() (lines 70-103)
    - Random selection: O(1) - CaseIterable enumeration
    - Memory: Negligible - ~50 GridPosition structs (8 bytes each)
    - Target: Path length 45-60 waypoints after expansion (typical for medium complexity)

  - **Commands:**
    ```bash
    # Build (verify compilation)
    swift build

    # Run tests (only affected path - see next item for test implementation)
    swift test --filter MapConfigurationTests

    # Run full test suite (if needed for validation)
    swift test

    # Manual testing: Run game and observe map27
    swift run
    ```

  - **Risks & Mitigations:**
    - **Risk:** Path goes out of safe zone bounds → bugs spawn off-screen or collide with edges
      **Mitigation:** Manually verify all waypoint coordinates are x:1-18, y:1-13 before committing. Add unit test to validate bounds.
    - **Risk:** Path doesn't reach house position → bugs get stuck or disappear
      **Mitigation:** Ensure final waypoint is exactly GridPosition(x: 10, y: 7). Add assertion test.
    - **Risk:** Figure-8 pattern not visually clear → fails acceptance criteria
      **Mitigation:** Sketch pattern on paper first, ensure two distinct loops with clear center crossing. Test visually in game.
    - **Risk:** Loops are unbalanced (one much larger than other) → looks awkward
      **Mitigation:** Design loops with similar radius/size. Reference map4Path (Double Loop) for balance.
    - **Risk:** Path too short or too long → gameplay balance issues
      **Mitigation:** Aim for 45-60 waypoints after expansion. Count manually or use expandPath result length.

- [ ] **Item 2 — Implement Unit Tests for Map 27**
  - **What to do:**
    1. Create test methods in `Tests/BugDefenseTests/BugDefenseTests.swift`
    2. Follow existing test pattern from lines 125-185 (testBugSpawningWithRoadPath)
    3. Implement test methods:
       - `testMap27PathValidity()`: Verify path ends at house, has min 2 waypoints
       - `testMap27PathBounds()`: Verify all waypoints within x:1-18, y:1-13
       - `testMap27FigureEightPattern()`: Verify path crosses through center area
       - `testMap27IncludedInAllCases()`: Verify MapType.allCases.count == 27
    4. Use XCTAssert* macros following existing patterns in file
    5. Mark methods with `@MainActor` since MapType uses MainActor-isolated MapManager
    6. Run tests to verify all pass

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` — Existing map/path testing pattern
    - `Tests/BugDefenseTests/BugDefenseTests.swift:1-15` — GridPosition test pattern (XCTest assertions)
    - `Sources/BugDefense/MapConfiguration.swift:105-113` — housePosition and spawnPoints logic
    - `.claudiomiro/AI_PROMPT.md:269-338` — Testing philosophy (diff-driven, minimal)

  - **Touched (will modify/create):**
    - MODIFY: `Tests/BugDefenseTests/BugDefenseTests.swift` — Add test methods for map27 (~line 363, end of class)

  - **Interfaces / Contracts:**
    - **Test method signatures:**
      - `@MainActor func testMap27PathValidity()`
      - `@MainActor func testMap27PathBounds()`
      - `@MainActor func testMap27FigureEightPattern()`
      - `@MainActor func testMap27IncludedInAllCases()`
    - **Assertions used:**
      - `XCTAssertEqual(path.last, GridPosition(x: 10, y: 7))` — Path ends at house
      - `XCTAssertGreaterThanOrEqual(path.count, 2)` — Minimum waypoints
      - `XCTAssertTrue(pos.x >= 1 && pos.x <= 18)` — X bounds
      - `XCTAssertTrue(pos.y >= 1 && pos.y <= 13)` — Y bounds
      - `XCTAssertEqual(MapType.allCases.count, 27)` — Enum completeness

  - **Tests:**
    Type: Meta-tests (tests that verify the tests themselves run correctly)
    - **Happy path:** All four test methods pass when map27 is correctly implemented
    - **Failure:** Tests fail if map27 violates any constraint (demonstrates test effectiveness)
    - **Integration:** Tests run as part of `swift test` suite without errors
    - Note: Focus on testing changed code only (map27 definitions), not entire map system

  - **Migrations / Data:**
    N/A - Test-only changes, no production data or migrations.

  - **Observability:**
    - XCTest framework provides automatic test execution logging
    - Test failures will show in console with file:line references
    - No additional logging needed

  - **Security & Permissions:**
    N/A - Test code with no security implications.

  - **Performance:**
    - Each test runs in <10ms (simple assertions on static data)
    - Total test suite overhead: ~40ms for 4 new tests
    - No performance concerns

  - **Commands:**
    ```bash
    # Run only map configuration tests
    swift test --filter BugDefenseTests

    # Run only map27-specific tests (if test names contain "Map27")
    swift test --filter testMap27

    # Run full test suite to ensure no regressions
    swift test

    # Verbose output for debugging
    swift test --verbose
    ```

  - **Risks & Mitigations:**
    - **Risk:** Tests pass but map27 still has visual/gameplay issues
      **Mitigation:** Supplement unit tests with manual playtesting (run game, select map27, observe bug movement).
    - **Risk:** Tests fail due to off-by-one errors in bounds checking
      **Mitigation:** Carefully verify safe zone is x:1-18 and y:1-13 (not 0-based). Reference AI_PROMPT.md:42.
    - **Risk:** @MainActor attribute missing → compilation errors
      **Mitigation:** Add @MainActor to all test methods that access MapType/MapManager (see line 24 for pattern).
    - **Risk:** Tests are too strict → brittle to future changes
      **Mitigation:** Test contracts (ends at house, stays in bounds), not implementation details (exact waypoint sequence).

- [ ] **Item 3 — Manual Validation and Visual Verification**
  - **What to do:**
    1. Build and run the game: `swift run`
    2. Select map27 manually or trigger random map selection until map27 appears
    3. Verify visual appearance:
       - Figure-8 pattern is clearly visible on grid
       - Two loops are balanced and similar in size
       - Center crossing point is obvious
       - Road tiles (brown) correctly render along entire path
    4. Spawn bugs and observe movement:
       - Bugs spawn at first waypoint (edge of map)
       - Bugs follow figure-8 path precisely without deviation
       - Bugs navigate the center crossing smoothly
       - Bugs complete both loops and reach house at end
    5. Test tower placement:
       - Cannot place towers on road tiles (map27 path)
       - Can place towers in grass areas between/around loops
       - Strategic placement opportunities around center crossing
    6. Document any issues or adjustments needed
    7. If issues found, iterate on map27Path waypoints and re-test

  - **Context (read-only):**
    - `.claudiomiro/AI_PROMPT.md:77-89` — Visual grid system and road rendering
    - `.claudiomiro/AI_PROMPT.md:56-76` — Bug movement system (waypoint following)
    - `Sources/BugDefense/GameScene.swift:237-304` — Grid rendering logic (visual reference)
    - `Sources/BugDefense/GameScene.swift:488-504` — Bug spawning with road path
    - `Sources/BugDefense/Bug.swift:240-302` — Bug waypoint movement implementation

  - **Touched (will modify/create):**
    - No files modified - this is validation only
    - May iterate on `Sources/BugDefense/MapConfiguration.swift` map27Path if issues found

  - **Interfaces / Contracts:**
    N/A - Manual testing, no code interfaces

  - **Tests:**
    Type: Manual exploratory testing
    - **Happy path:** Complete playthrough with map27 selected, bugs spawn and reach house correctly
    - **Visual:** Figure-8 pattern clearly visible, loops balanced, crossing point obvious
    - **Gameplay:** Towers can be placed strategically around loops, map feels balanced
    - **Edge case:** Map switching works (tier progression changes from/to map27 smoothly)
    - **Failure:** Bugs don't get stuck, don't disappear, don't deviate from path

  - **Migrations / Data:**
    N/A - Manual testing only.

  - **Observability:**
    - Watch console logs for MapManager selection messages
    - `🗺️ Selected map: Figure Eight` confirms map27 loaded
    - Observe bug positions visually on grid
    - No additional instrumentation needed

  - **Security & Permissions:**
    N/A - Local gameplay testing.

  - **Performance:**
    - Visual validation: ~2-5 minutes of playtesting
    - Bug movement should be smooth at 60 FPS (existing engine performance)
    - No specific performance requirements beyond existing game standards

  - **Commands:**
    ```bash
    # Run game for manual testing
    swift run

    # Alternative: Open in Xcode for easier debugging/visualization
    open Package.swift
    # Then build and run in Xcode
    ```

  - **Risks & Mitigations:**
    - **Risk:** Figure-8 pattern not visually obvious → fails acceptance criteria
      **Mitigation:** If unclear, adjust waypoints to create more pronounced loops and crossing. Iterate until visually distinct.
    - **Risk:** Bugs appear to deviate from path or stair-step on diagonals
      **Mitigation:** This should NOT happen (vector movement system prevents it). If observed, report as bug - likely unrelated to map27.
    - **Risk:** Path is too easy or too hard compared to other maps
      **Mitigation:** Adjust path length by adding/removing waypoint corners. Balance against similar medium-difficulty maps (map4, map5).
    - **Risk:** Center crossing creates confusing visuals (paths overlap ambiguously)
      **Mitigation:** Ensure crossing is clean - bugs pass through same point but direction is clear. May need to widen crossing area.

## Verification (global)

- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Test only map configuration (includes map27 tests)
      swift test --filter BugDefenseTests

      # Alternatively, filter by specific test methods
      swift test --filter testMap27

      # CRITICAL: Do not run unrelated tests or full project checks
      # These commands are sufficient for map27 validation
      ```
- [ ] All acceptance criteria met (see below)
- [ ] Code follows Swift conventions and existing MapConfiguration patterns
  - Enum case naming: `.map27 = "Figure Eight"`
  - Path method naming: `private var map27Path`
  - GridPosition array format consistent with other maps
  - Switch statement updated correctly
- [ ] Integration points properly implemented
  - MapType.allCases automatically includes map27 (CaseIterable)
  - MapType.random() can select map27
  - roadPath computed property returns expanded map27Path
  - MapManager works with map27 without modification
- [ ] Performance targets met
  - Path expansion completes in <1ms (existing algorithm)
  - No impact on game loop performance
  - Memory usage negligible
- [ ] No security requirements (local game feature)
- [ ] Manual visual validation confirms figure-8 pattern is clear and balanced

## Acceptance Criteria

From TASK.md and PROMPT.md - all must be measurable and verifiable:

- [ ] **Clear figure-8 or infinity pattern:** Path forms two distinct loops that cross through center area
  - Measurable: Visual inspection shows two loops with obvious crossing point
  - Verification: Manual playtesting confirms pattern recognition
- [ ] **Path crosses through center:** Crossing point is at or near GridPosition(x: 10, y: 7)
  - Measurable: At least one waypoint is within 2 tiles of center (x:8-12, y:5-9)
  - Verification: Code inspection of map27Path waypoints
- [ ] **Two distinct loop segments:** Upper and lower loops are clearly separable
  - Measurable: Path has distinct upper half and lower half sections
  - Verification: Visual grid rendering shows two loops, not chaotic path
- [ ] **Compiles and tests successfully:** No compilation errors or test failures
  - Measurable: `swift build` exits with code 0
  - Measurable: `swift test --filter BugDefenseTests` shows all tests passed
  - Verification: Run commands and observe output
- [ ] **Loops are balanced (similar size):** Both loops have similar radius/waypoint count
  - Measurable: Difference in loop sizes < 30% (e.g., if one loop is 20 waypoints, other is 14-26)
  - Verification: Manual count of waypoints in upper vs lower loops
- [ ] **Center crossing is clear:** Bugs visibly cross through the same point twice
  - Measurable: Path includes waypoints that overlap/intersect near center
  - Verification: Watch bugs during playtesting - should cross center area twice
- [ ] **Path stays within safe zone:** All waypoints have x:1-18, y:1-13
  - Measurable: Unit test `testMap27PathBounds()` passes
  - Verification: Automated test assertion
- [ ] **Path ends at house:** Final waypoint is GridPosition(x: 10, y: 7)
  - Measurable: Unit test `testMap27PathValidity()` passes
  - Verification: Automated test assertion `XCTAssertEqual(path.last, ...)`
- [ ] **Path length appropriate:** Expanded path has 45-60 waypoints (medium complexity)
  - Measurable: `MapType.map27.roadPath.count` is between 45-60
  - Verification: Print statement or unit test assertion
- [ ] **Follows existing patterns:** Code structure matches map1-map20 implementations
  - Measurable: Code review confirms same enum/method/switch pattern
  - Verification: Compare map27 code to map7Path (similar figure-eight reference)

## Impact Analysis

**Directly impacted:**
- `Sources/BugDefense/MapConfiguration.swift:26` (new enum case)
- `Sources/BugDefense/MapConfiguration.swift:64` (new switch case)
- `Sources/BugDefense/MapConfiguration.swift:632+` (new map27Path method)
- `Tests/BugDefenseTests/BugDefenseTests.swift:363+` (new test methods)

**Indirectly impacted:**
- `MapType.allCases` — Automatically includes map27 (CaseIterable protocol)
- `MapType.random()` — Can now select map27 (line 36-38)
- `MapManager.selectRandomMap()` — Expanded map pool includes map27
- Future tasks TASK11 and TASKΩ — May depend on map27 being available
- Game balance — Medium-difficulty map pool increases by one
- Player experience — More variety in map selection

**No impact:**
- Bug movement system (uses existing waypoint infrastructure)
- Path expansion algorithm (unchanged)
- Grid rendering (automatically handles new path)
- Tower placement logic (automatically blocks new road positions)
- Save/load system (maps are compile-time, not saved)
- Other maps (map1-map20 unaffected)

## Follow-ups

**Ambiguities identified:**
- None - Task specification is clear

**Potential future enhancements (NOT in scope for this task):**
- Could add difficulty rating to maps (easy/medium/hard classification)
- Could implement map preview/thumbnail system
- Could allow players to manually select maps (currently random only)
- Could add map-specific achievements or scoring multipliers

**Known constraints confirmed:**
- Map27 must be figure-8 pattern (specified in TASK.md)
- Path length target: 45-60 waypoints (medium complexity per TASK.md)
- House position is fixed at GridPosition(x: 10, y: 7) for ALL maps (per AI_PROMPT.md:43)
- Safe zone boundaries are strict: x:1-18, y:1-13 (per AI_PROMPT.md:42)
- No commits or git operations allowed (per PROMPT.md:34)
