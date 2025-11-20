Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Swift 5.x + SpriteKit tech stack
- 20x15 grid system with safe zone (x:1-18, y:1-13)
- Waypoint-based bug movement using vector normalization
- MapType enum pattern and path expansion system
- House position fixed at GridPosition(x: 10, y: 7)
- Related code examples with file:line references

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Design Map 24 Switchback Pattern**
  - **What to do:**
    1. Design a switchback/hairpin turn pattern featuring 4-6 sharp 180-degree U-turns stacked vertically
    2. Create waypoint array that ascends vertically with tight horizontal segments reversing direction
    3. Start path at left or right edge (y:1-13), create horizontal run, sharp U-turn, reverse horizontal, repeat
    4. Pattern should resemble a mountain road with compact, tight turns (NOT broad zigzags)
    5. Path length target: 35-50 waypoints after expansion
    6. Final waypoint MUST be GridPosition(x: 10, y: 7) - the house position
    7. All waypoints MUST stay within safe zone (x:1-18, y:1-13)
    8. Make turns sharper and more compact than existing map12 "Switchback" to differentiate

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:415-457` - Existing map12 "Switchback" pattern (reference, but make map24 MORE compact)
    - `Sources/BugDefense/MapConfiguration.swift:280-316` - Map8 "U-Turns" shows sharp turn technique
    - `Sources/BugDefense/MapConfiguration.swift:70-103` - Path expansion algorithm (auto-fills intermediate positions)
    - `Sources/BugDefense/MapConfiguration.swift:5-26` - MapType enum pattern to follow
    - `Sources/BugDefense/Bug.swift:240-302` - Vector movement ensures bugs navigate hairpin turns correctly

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` (3 changes):
      1. Add `.map24 = "Mountain Switchback"` enum case after line 25
      2. Add case to roadPath switch statement after line 63
      3. Implement `map24Path` method after line 631 (before closing brace)

  - **Interfaces / Contracts:**
    - Enum case: `.map24 = "Mountain Switchback"`
    - Method signature: `private var map24Path: [GridPosition]`
    - Return type: `[GridPosition]` array of waypoints
    - Integration: Added to `roadPath` computed property switch statement
    - Contract: First waypoint = spawn point (edge), last waypoint = GridPosition(x: 10, y: 7)

  - **Tests:**
    Type: unit tests with XCTest framework
    - Happy path: Map24 path starts at edge, ends at house GridPosition(x: 10, y: 7), contains 4-6 visible U-turn segments
    - Edge case: All waypoints within safe zone boundaries (x:1-18, y:1-13)
    - Edge case: Path is not empty and has at least 10 waypoints (enough for multiple hairpins)
    - Integration: MapType.allCases includes .map24
    - Integration: MapType.random() can select .map24
    - Visual verification: Manual playtest to confirm sharp hairpin aesthetic

  - **Migrations / Data:**
    N/A - No data changes (compile-time map definition)

  - **Observability:**
    - Existing logging: MapManager.selectMap() logs "🗺️ Selected map: Mountain Switchback"
    - Existing logging: MapManager.selectRandomMap() logs "🎲 Randomly selected map: Mountain Switchback"
    N/A - No additional observability requirements

  - **Security & Permissions:**
    N/A - No security concerns (single-player game, no network, no user input)

  - **Performance:**
    - Path array pre-computed at enum access time (O(1) lookup after first access)
    - Expansion algorithm runs once per map access: O(n*m) where n=waypoints, m=max(dx,dy) per segment
    - Target: Expanded path should be 35-50 positions (reasonable for iteration)
    - Memory: Negligible impact (20 maps * ~40 positions * 16 bytes ≈ 12KB total)
    N/A - No performance concerns (follows existing pattern)

  - **Commands:**
    ```bash
    # Build (Swift Package Manager)
    swift build

    # Run game to test visually
    swift run BugDefenseApp

    # Run tests (after test file created in next item)
    swift test --filter MapConfigurationTests

    # Type check only (fast validation)
    swift build --build-tests
    ```

  - **Risks & Mitigations:**
    - **Risk:** Switchback pattern too similar to existing map12
      **Mitigation:** Make U-turns tighter and more vertically stacked, shorter horizontal segments (2-3 tiles vs 4-6)
    - **Risk:** Sharp 180-degree turns might confuse vector movement
      **Mitigation:** Existing Bug.swift:292-300 handles all turn angles via normalized vectors - tested with existing maps
    - **Risk:** Path might exit safe zone with tight turns
      **Mitigation:** Design on paper first, verify all waypoints x:1-18 y:1-13 before implementation

- [ ] **Implement Map 24 in MapConfiguration.swift**
  - **What to do:**
    1. Open `Sources/BugDefense/MapConfiguration.swift`
    2. Add enum case after line 25: `case map24 = "Mountain Switchback"`
    3. Add switch case after line 63: `case .map24: basePath = map24Path`
    4. Implement method after line 631 (before final closing brace):
       ```swift
       // Map 24: Mountain Switchback - Tight hairpin turns ascending vertically
       private var map24Path: [GridPosition] {
           return [
               // Start at left edge, ascend with U-turns
               GridPosition(x: 1, y: 2),
               GridPosition(x: 2, y: 2),
               GridPosition(x: 3, y: 2),
               GridPosition(x: 3, y: 3),
               GridPosition(x: 3, y: 4),
               GridPosition(x: 2, y: 4),
               GridPosition(x: 1, y: 4),
               GridPosition(x: 1, y: 5),
               GridPosition(x: 1, y: 6),
               GridPosition(x: 2, y: 6),
               GridPosition(x: 3, y: 6),
               GridPosition(x: 4, y: 6),
               GridPosition(x: 4, y: 7),
               GridPosition(x: 4, y: 8),
               GridPosition(x: 3, y: 8),
               GridPosition(x: 2, y: 8),
               GridPosition(x: 1, y: 8),
               GridPosition(x: 1, y: 9),
               GridPosition(x: 1, y: 10),
               GridPosition(x: 2, y: 10),
               GridPosition(x: 3, y: 10),
               GridPosition(x: 4, y: 10),
               GridPosition(x: 5, y: 10),
               GridPosition(x: 6, y: 10),
               GridPosition(x: 6, y: 9),
               GridPosition(x: 6, y: 8),
               GridPosition(x: 7, y: 8),
               GridPosition(x: 8, y: 8),
               GridPosition(x: 9, y: 8),
               GridPosition(x: 10, y: 8),
               GridPosition(x: 10, y: 7)  // House position (end)
           ]
       }
       ```
       This creates 4 distinct hairpin turns with vertical progression.
    5. Save file

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:415-457` - Reference existing switchback for structure
    - `Sources/BugDefense/MapConfiguration.swift:5-26` - Enum case naming pattern
    - `Sources/BugDefense/MapConfiguration.swift:40-68` - Switch statement integration pattern

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift`:
      - Line ~25: Add enum case
      - Line ~63: Add switch case
      - Line ~632: Add map24Path method

  - **Interfaces / Contracts:**
    (Same as item 1 - implementation follows design)

  - **Tests:**
    Type: Compilation test (immediate)
    - Happy path: Code compiles without errors (`swift build`)
    - Edge case: No syntax errors in Swift
    - Integration: MapType.allCases count increased to 21 (from 20)

  - **Migrations / Data:**
    N/A - Compile-time change only

  - **Observability:**
    N/A - Implementation follows existing observable pattern

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    N/A - Same performance profile as existing maps

  - **Commands:**
    ```bash
    # Verify syntax and build
    swift build

    # Quick type check without full build
    swift build --build-tests
    ```

  - **Risks & Mitigations:**
    - **Risk:** Typo in GridPosition coordinates
      **Mitigation:** Verify each waypoint manually, test with visual playthrough
    - **Risk:** Forgot to update switch statement
      **Mitigation:** Compiler will error "Switch must be exhaustive" if CaseIterable detects missing case
    - **Risk:** Path doesn't reach house
      **Mitigation:** Last waypoint explicitly set to GridPosition(x: 10, y: 7), verified in tests

- [ ] **Create Unit Tests for Map 24**
  - **What to do:**
    1. Create new test file: `Tests/BugDefenseTests/MapConfigurationTests.swift`
    2. Import XCTest and @testable import BugDefense
    3. Create test class: `final class MapConfigurationTests: XCTestCase`
    4. Implement test methods:
       - `testMap24PathValidity()` - Verify path ends at house, stays in bounds, has sufficient length
       - `testMap24EnumIntegration()` - Verify .map24 in MapType.allCases and can be selected
       - `testMap24WaypointDistribution()` - Verify path creates visible hairpin pattern (direction changes)
    5. Follow pattern from existing tests in `Tests/BugDefenseTests/BugDefenseTests.swift:125-185`

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` - Map testing pattern (testBugSpawningWithRoadPath)
    - `Tests/BugDefenseTests/BugDefenseTests.swift:1-15` - XCTest import and structure
    - `Package.swift:26-28` - Test target configuration

  - **Touched (will modify/create):**
    - CREATE: `Tests/BugDefenseTests/MapConfigurationTests.swift`

  - **Interfaces / Contracts:**
    - Test framework: XCTest (Apple's testing framework)
    - Test class: `MapConfigurationTests: XCTestCase`
    - Test method prefix: `test` (XCTest convention)
    - Assertions: XCTAssertEqual, XCTAssertTrue, XCTAssertGreaterThan, XCTAssertNotNil

  - **Tests:**
    Type: unit tests validating map24 implementation
    - Happy path: Map24 path is valid (testMap24PathValidity)
      - Path.last == GridPosition(x: 10, y: 7)
      - All positions within bounds x:1-18, y:1-13
      - Path.count >= 10 (sufficient for hairpins)
    - Edge case: Map24 included in allCases (testMap24EnumIntegration)
      - MapType.allCases.contains(.map24) == true
      - MapType.allCases.count == 21
    - Edge case: Hairpin pattern detected (testMap24WaypointDistribution)
      - Detect at least 4 direction reversals in horizontal movement
    - Integration: MapType.random() can return .map24 (statistical test or enum check)

  - **Migrations / Data:**
    N/A - Test file creation only

  - **Observability:**
    - Test output shows pass/fail for each test method
    - Xcode/console logs test execution results

  - **Security & Permissions:**
    N/A - Test code, no security concerns

  - **Performance:**
    - Unit tests should complete in <100ms total
    - No performance-intensive operations (simple array validation)

  - **Commands:**
    ```bash
    # Run all tests
    swift test

    # Run only MapConfigurationTests
    swift test --filter MapConfigurationTests

    # Run specific test
    swift test --filter MapConfigurationTests.testMap24PathValidity

    # Verbose output
    swift test -v
    ```

  - **Risks & Mitigations:**
    - **Risk:** Tests fail due to incorrect expected values
      **Mitigation:** Verify house position is GridPosition(x: 10, y: 7), safe zone is x:1-18 y:1-13
    - **Risk:** Direction reversal detection too strict/loose
      **Mitigation:** Count x-direction sign changes (left-to-right vs right-to-left), expect 4+ reversals

- [ ] **Manual Verification and Visual Testing**
  - **What to do:**
    1. Build and run the game: `swift run BugDefenseApp`
    2. Use developer console or modify code temporarily to select map24: `MapManager.shared.selectMap(.map24)`
    3. Start a wave and observe bugs:
       - Spawn at first waypoint (left edge around y:2)
       - Follow hairpin turns precisely without deviation
       - Navigate sharp 180-degree turns smoothly
       - Reach house at center GridPosition(x: 10, y: 7)
    4. Verify visual rendering:
       - Brown road tiles render along entire path
       - No gaps in road path
       - Green grass tiles on non-road areas
       - House renders at center with dark green
       - Hairpin pattern is visually distinct and clear
    5. Test tower placement:
       - Cannot place towers on road path tiles
       - Can place towers in areas between hairpin segments
    6. Test random map selection:
       - Restart game multiple times or advance tiers
       - Verify map24 appears in rotation

  - **Context (read-only):**
    - `Sources/BugDefense/GameScene.swift:237-304` - Grid rendering (visual verification)
    - `Sources/BugDefense/GameScene.swift:488-504` - Bug spawning with road path
    - `Sources/BugDefense/GameScene.swift:826-856` - Tower placement blocking on roads
    - `.claudiomiro/AI_PROMPT.md:113-118` - Constraints and validation criteria

  - **Touched (will modify/create):**
    N/A - Read-only verification (no code changes)

  - **Interfaces / Contracts:**
    N/A - Visual validation only

  - **Tests:**
    Type: manual integration and visual testing
    - Happy path: Bugs spawn and complete path to house
    - Happy path: Road tiles render correctly along hairpin pattern
    - Edge case: Sharp 180-degree turns navigate correctly (no stuck bugs)
    - Edge case: Tower placement blocked on road tiles
    - Integration: Map24 appears in random map selection
    - Visual: Hairpin pattern is aesthetically distinct from other maps

  - **Migrations / Data:**
    N/A - Manual testing only

  - **Observability:**
    - Console logs: "🗺️ Selected map: Mountain Switchback"
    - Console logs: "🎲 Randomly selected map: Mountain Switchback" (if random)
    - Visual confirmation: Road path, bugs moving, house position

  - **Security & Permissions:**
    N/A - Manual testing, no security concerns

  - **Performance:**
    - Observe frame rate during bug movement (should be smooth 60 FPS)
    - No lag or stuttering on hairpin turns
    - Path rendering should be instant (pre-computed)

  - **Commands:**
    ```bash
    # Build and run game
    swift run BugDefenseApp

    # Optional: Run in release mode for performance testing
    swift run -c release BugDefenseApp
    ```

  - **Risks & Mitigations:**
    - **Risk:** Bugs get stuck on sharp turns
      **Mitigation:** Vector movement (Bug.swift:292-300) handles all angles; existing maps have sharp turns
    - **Risk:** Visual gaps in road rendering
      **Mitigation:** Path expansion (MapConfiguration.swift:70-103) fills all intermediate tiles
    - **Risk:** Map24 never selected randomly
      **Mitigation:** MapType.random() uses allCases.randomElement() - if enum is correct, will be included

## Verification (global)

- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Build to verify compilation
      swift build

      # Run map configuration tests
      swift test --filter MapConfigurationTests

      # Type check (fast validation)
      swift build --build-tests

      # Optional: Run all tests to ensure no regression
      swift test
      ```
      **CRITICAL:** Do not run full-project checks beyond these commands

- [ ] All acceptance criteria met (see below)
- [ ] Code follows Swift conventions from AI_PROMPT.md and PROMPT.md:
  - Enum naming: `.map24 = "Mountain Switchback"`
  - Method naming: `private var map24Path`
  - GridPosition array pattern
  - Comment style for map description
- [ ] Integration points properly implemented:
  - MapType.allCases includes .map24 (automatic via CaseIterable)
  - roadPath switch statement includes .map24 case
  - MapManager can select and use map24
- [ ] Performance targets met:
  - Compilation successful without warnings
  - Path expansion completes instantly
  - 35-50 waypoints after expansion (reasonable size)
- [ ] Security requirements satisfied: N/A (single-player game)
- [ ] Visual verification complete (manual playtest)

## Acceptance Criteria

- [ ] Map 24 "Mountain Switchback" added to MapType enum in `Sources/BugDefense/MapConfiguration.swift:~25`
- [ ] map24Path method implemented with 4-6 visible U-turn/hairpin segments in `Sources/BugDefense/MapConfiguration.swift:~632`
- [ ] Path follows switchback pattern: vertical ascent with tight horizontal reversals
- [ ] All waypoints within safe zone (x:1-18, y:1-13)
- [ ] Path starts at edge position (spawn point)
- [ ] Path ends at GridPosition(x: 10, y: 7) - house position
- [ ] Pattern visually distinct from existing map12 "Switchback" (tighter, more compact turns)
- [ ] Code compiles successfully: `swift build` exits with code 0
- [ ] MapType.allCases includes .map24 (verified in tests)
- [ ] Bugs navigate hairpin turns correctly (manual verification)
- [ ] Road tiles render along entire path without gaps (visual verification)
- [ ] Towers cannot be placed on road path tiles (integration verification)
- [ ] Unit tests pass: `swift test --filter MapConfigurationTests` exits with code 0
- [ ] Map 24 appears in random map selection rotation (manual verification)

## Impact Analysis

- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift` (modified):
    - Line ~25: Added `.map24` enum case
    - Line ~63: Added `case .map24: basePath = map24Path` to switch
    - Line ~632: Added `map24Path` method implementation
  - `Tests/BugDefenseTests/MapConfigurationTests.swift` (created):
    - New test file with 3+ test methods validating map24

- **Indirectly impacted:**
  - MapManager: Can now select and return map24 data
  - GameScene: Will render map24 road tiles and spawn bugs on map24 path
  - Bug movement: Will navigate map24 hairpin turns (existing vector movement handles this)
  - Random map selection: Pool increased from 20 to 21 maps (slightly changes probability)
  - Future tasks: TASK5-TASK10 will add more maps following this same pattern
  - TASK11: Will integrate all new maps (including map24)
  - TASKΩ: Will validate entire map collection including map24

## Follow-ups

- None identified. Task is well-defined with clear acceptance criteria and implementation pattern established by existing 20 maps.
