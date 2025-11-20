Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack: Swift 5.x, SpriteKit, Swift Package Manager
- Project structure and architecture (Entity-Component pattern)
- Coding conventions and patterns
- Grid system: 20x15 tiles, safe zone x:1-18, y:1-13
- House position: GridPosition(x: 10, y: 7) (center)
- Map pattern examples and waypoint system
- Integration points and dependencies

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Design and Implement Map 23 (Double Helix Pattern)**
  - **What to do:**
    1. Design the double helix path pattern on paper/mentally using 20x15 grid
       - Create 3-4 smooth S-curve segments that appear to interweave
       - Start from edge position (e.g., left or bottom edge)
       - Flow vertically or horizontally with alternating curves
       - End at GridPosition(x: 10, y: 7) (the house)
       - Target 40-55 waypoint positions for moderate difficulty
       - Use gradual turns (4-6 waypoints per curve segment for smoothness)

    2. Add `.map23` enum case to MapType in `Sources/BugDefense/MapConfiguration.swift`
       - Follow pattern: `case map23 = "Double Helix"`
       - Add after line 24 (after `case map20 = "Labyrinth"`)

    3. Implement `map23Path` private computed property
       - Add after existing map path methods (around line 630, before closing brace)
       - Follow pattern from existing maps (see map1Path at lines 117-136)
       - Return array of GridPosition waypoints defining the S-curve pattern
       - First waypoint: edge position (spawn point)
       - Last waypoint: GridPosition(x: 10, y: 7) (house)
       - All intermediate waypoints within safe zone (x:1-18, y:1-13)

    4. Add case to `roadPath` switch statement
       - Add `case .map23: basePath = map23Path` in the switch (around line 62)
       - Follow alphabetical order after map20

    5. Verify implementation:
       - All coordinates within bounds (x:0-19, y:0-14, preferably safe zone x:1-18, y:1-13)
       - Path creates smooth S-curves (not jagged or angular)
       - Visual weaving effect (curves alternate left-right or up-down)
       - Adequate waypoints for smooth curves (no big gaps between waypoints)

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:4-24` — MapType enum definition pattern
    - `Sources/BugDefense/MapConfiguration.swift:40-67` — roadPath switch statement pattern
    - `Sources/BugDefense/MapConfiguration.swift:117-136` — Map 1 (Winding Road) serpentine pattern reference
    - `Sources/BugDefense/MapConfiguration.swift:169-181` — Map 3 (S-Curve) smooth curve pattern reference
    - `Sources/BugDefense/MapConfiguration.swift:334-346` — Map 10 (Wave Pattern) wavy pattern reference
    - `Sources/BugDefense/MapConfiguration.swift:70-102` — expandPath() method (automatic path expansion)
    - `Sources/BugDefense/GameConfiguration.swift:64-67` — Grid dimensions and tile size
    - `Sources/BugDefense/GameConfiguration.swift:169-194` — GridPosition struct definition

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add enum case (line ~25)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add switch case (line ~63)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map23Path method (line ~630)

  - **Interfaces / Contracts:**
    - **MapType enum:** New case `.map23 = "Double Helix"` conforms to `String, CaseIterable`
    - **Path method signature:** `private var map23Path: [GridPosition]`
    - **Return value:** Array of GridPosition structs (each has x: Int, y: Int properties)
    - **Contract:** First waypoint is spawn (edge), last waypoint is GridPosition(x: 10, y: 7)
    - **Integration:** MapManager.shared.getCurrentRoadPath() will return expanded path
    - **Consumer:** Bug.setPath() receives the road path array for waypoint following

  - **Tests:**
    Type: Unit tests with XCTest framework
    - **Happy path:** Map23 path is valid, starts at edge, ends at house, all waypoints in bounds
    - **Edge case:** Path has sufficient waypoints (>= 40 and <= 60 for smooth curves)
    - **Edge case:** All waypoints within grid bounds (x: 0-19, y: 0-14)
    - **Edge case:** Path creates S-curve visual pattern (alternating direction changes)
    - **Integration:** MapType.allCases includes .map23
    - **Integration:** MapType.random() can return .map23
    - **Failure:** N/A - compile-time validation prevents invalid paths

  - **Migrations / Data:**
    N/A - No data migrations needed. Map definitions are compile-time Swift code.

  - **Observability:**
    - Console logging already exists in MapManager.selectMap() at line 645
    - When map23 is selected, will log: "🗺️ Selected map: Double Helix"
    - No additional logging required for this task

  - **Security & Permissions:**
    N/A - No security concerns. Local game logic, no user input, no network, no PII.

  - **Performance:**
    - Path array stored in computed property (lazy evaluation)
    - expandPath() called once when roadPath accessed (O(n*m) where n=waypoint count, m=steps between waypoints)
    - Target 40-55 waypoints for moderate path length (performance negligible)
    - No runtime path generation - all predefined at compile time
    - Memory: ~40-55 GridPosition structs (each 2 Int = 16 bytes) = ~880 bytes
    - Performance target: Path expansion < 1ms (existing maps meet this)

  - **Commands:**
    ```bash
    # Build the project (verify compilation)
    swift build

    # Run tests (only affected path - new map validation tests)
    swift test --filter BugDefenseTests.testNewMapsPathValidity
    swift test --filter BugDefenseTests.testMapRandomSelectionIncludesNewMaps

    # Run all tests (verify no regressions)
    swift test

    # Optional: Build and run the app for visual verification
    swift run BugDefenseApp
    # Then manually select Map 23 in-game to verify:
    # - Road tiles render correctly along the S-curve path
    # - Bugs spawn at start and follow the double helix pattern
    # - Bugs reach the house at the end
    # - Tower placement is blocked on road tiles
    ```

  - **Risks & Mitigations:**
    - **Risk:** Path waypoints too far apart causing visual gaps in road tiles
      **Mitigation:** Use 4-6 waypoints per curve segment; expandPath() fills intermediate tiles automatically

    - **Risk:** Path doesn't create clear "double helix" visual effect
      **Mitigation:** Ensure S-curves alternate direction smoothly; reference Map 3 (S-Curve) and Map 10 (Wave Pattern) for inspiration; test visually in-game

    - **Risk:** Path too short or too long (difficulty imbalance)
      **Mitigation:** Target 40-55 waypoints (moderate difficulty); compare with Map 1 (16 waypoints, easy) and Map 11 (62 waypoints, hard)

    - **Risk:** Path crosses itself or creates confusing layout
      **Mitigation:** Sketch path first; ensure S-curves flow naturally without self-intersection; use safe zone margins

## Verification (global)
- [ ] Run targeted tests for Map 23 validation:
      ```bash
      # Build verification
      swift build

      # Unit tests for new map
      swift test --filter MapConfigurationTests

      # Full test suite (verify no regressions)
      swift test
      ```
      **CRITICAL:** Tests should verify path validity, bounds checking, and integration

- [ ] All acceptance criteria met (see below)
- [ ] Code follows Swift conventions from AI_PROMPT.md and existing MapConfiguration.swift patterns
- [ ] Integration points properly implemented:
      - MapType enum includes .map23
      - roadPath switch includes case .map23
      - map23Path method returns valid GridPosition array
- [ ] Visual verification (manual playtesting):
      - Build and run game: `swift run BugDefenseApp`
      - Select Map 23 (use random selection or manual selection)
      - Verify road tiles form smooth double helix pattern
      - Verify bugs follow path precisely from spawn to house
      - Verify tower placement blocked on road tiles

## Acceptance Criteria
- [ ] Map 23 enum case added to MapType (exact: `case map23 = "Double Helix"`)
- [ ] map23Path method implemented with double helix pattern (private computed property returning [GridPosition])
- [ ] Path added to roadPath switch statement (case .map23: basePath = map23Path)
- [ ] All waypoints within safe zone (x:1-18, y:1-13) verified by bounds checking
- [ ] Path starts at edge (x=1 or y=1 or similar edge position) and ends at GridPosition(x: 10, y: 7)
- [ ] Pattern creates 3-4 visible S-curve segments (alternating direction changes)
- [ ] Code compiles without errors (`swift build` succeeds)
- [ ] Bugs navigate smoothly along curves (verified by manual testing or existing bug movement tests)
- [ ] Road tiles form continuous weaving pattern (visual verification in-game)
- [ ] Visual effect resembles DNA helix or interweaving strands (subjective but clear S-pattern)
- [ ] Path length between 40-55 waypoints (moderate difficulty)
- [ ] Curves are smooth with adequate waypoints (4-6 per curve segment)
- [ ] MapType.allCases includes .map23 (automatic via CaseIterable)
- [ ] MapType.random() can select .map23 (automatic via allCases.randomElement())

## Impact Analysis
- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift:24` (new enum case)
  - `Sources/BugDefense/MapConfiguration.swift:62` (new switch case)
  - `Sources/BugDefense/MapConfiguration.swift:630` (new path method)

- **Indirectly impacted:**
  - `MapType.allCases` property (automatically updated via CaseIterable)
  - `MapType.random()` method (will include new map in random selection pool)
  - `MapManager.selectRandomMap()` (can now select map23)
  - Game tier progression system (map23 can be selected at tier boundaries)
  - Visual grid rendering in `GameScene.swift:237-304` (will render map23 road tiles)
  - Bug spawning in `GameScene.swift:488-504` (will assign map23 path to bugs)
  - Tower placement validation in `GameScene.swift:826-856` (will block towers on map23 road)
  - Future tasks TASK11 (integration testing) and TASKΩ (final validation) depend on this

## Diff Test Plan
**Changed code:**
- MapConfiguration.swift: +1 enum case, +1 switch case, +1 path method (~20-30 lines total)

**Test coverage for changed code:**
1. **Enum case addition:**
   - Verify MapType.allCases.count == 21 (20 existing + 1 new)
   - Verify MapType.map23.rawValue == "Double Helix"
   - Verify MapType.map23.displayName == "Double Helix"

2. **Path method implementation:**
   - Verify map23Path.count >= 40 && <= 60
   - Verify map23Path.first is edge position (x <= 2 || y <= 2 || x >= 17 || y >= 12)
   - Verify map23Path.last == GridPosition(x: 10, y: 7)
   - Verify all waypoints: pos.x >= 0 && pos.x < 20 && pos.y >= 0 && pos.y < 15
   - Verify smooth curves: no gaps > 2 grid units between consecutive waypoints

3. **Switch case integration:**
   - Verify MapType.map23.roadPath returns non-empty array
   - Verify expanded path includes all intermediate tiles (expandPath works)
   - Verify first and last positions preserved after expansion

**Test file:** `Tests/BugDefenseTests/MapConfigurationTests.swift` (create if doesn't exist)

**Execution:**
```bash
swift test --filter MapConfigurationTests
```

**Stop rule:** All tests pass twice consecutively, 100% coverage of new map23 code, no unrelated test failures.

## Follow-ups
- None identified. Task scope is clear and well-defined. All necessary context provided in AI_PROMPT.md, TASK.md, and PROMPT.md.
