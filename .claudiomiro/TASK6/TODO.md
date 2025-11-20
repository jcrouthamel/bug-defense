Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK6/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK6/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack: Swift 5.x with SpriteKit on macOS/iOS
- Project structure: Sources/BugDefense/ with MapConfiguration.swift as primary file
- Coding conventions: Private path methods, GridPosition arrays, expandPath() usage
- Related code examples with file:line references
- Integration points: MapType enum, MapManager, GameScene

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Design and Implement Map 26 Perimeter Loop Path + Tests**
  - **What to do:**
    1. Design a perimeter loop path that travels around the outer edges of the safe zone
    2. Add `.map26` enum case to `MapType` enum with display name "Perimeter Loop"
    3. Implement `map26Path` private property returning `[GridPosition]` array
    4. Add case to `roadPath` switch statement to return `map26Path`
    5. Design pattern:
       - Start at edge position (safe zone boundary: x:1-18, y:1-13)
       - Travel clockwise or counter-clockwise around the perimeter
       - Create a long path (60-80 waypoints as specified)
       - Final segment spirals inward to house at GridPosition(x: 10, y: 7)
       - Pattern should be straightforward (easy difficulty) despite long length
    6. Ensure path does not overlap with house position until final waypoint
    7. Write unit tests to validate path properties

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:5-24` — MapType enum pattern (see map1 through map20)
    - `Sources/BugDefense/MapConfiguration.swift:40-67` — roadPath switch statement pattern
    - `Sources/BugDefense/MapConfiguration.swift:118-137` — Map 1 (Winding Road) example structure
    - `Sources/BugDefense/MapConfiguration.swift:350-412` — Map 11 (Box Spiral) perimeter pattern reference
    - `Sources/BugDefense/MapConfiguration.swift:415-456` — Map 12 (Switchback) long path example
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath() algorithm (handles interpolation)
    - `Sources/BugDefense/MapConfiguration.swift:105-113` — housePosition and spawnPoints pattern
    - `Sources/BugDefense/GameConfiguration.swift:64-71` — Grid constants (20x15, tileSize=40, safe zone)
    - `.claudiomiro/AI_PROMPT.md:40-44` — House position fixed at center (10, 7)

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map26 enum case (~line 24)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add map26Path private property (~line 631, after map20Path)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift` — Add case .map26 to roadPath switch (~line 62)
    - CREATE: `Tests/BugDefenseTests/MapConfigurationTests.swift` — New test file for map validation

  - **Interfaces / Contracts:**
    - **MapType enum**: Add `.map26 = "Perimeter Loop"` case (follows CaseIterable protocol)
    - **Path method signature**: `private var map26Path: [GridPosition] { return [...] }`
    - **Path requirements**:
      - Type: `[GridPosition]` array (GridPosition struct from GameConfiguration.swift:169-194)
      - First element: Spawn point at safe zone edge (x:1-18, y:1-13 boundaries)
      - Last element: Must be `GridPosition(x: 10, y: 7)` (house position)
      - Length: 60-80 waypoints for long but easy gameplay
      - All positions must be within grid bounds (x:0-19, y:0-14)
      - All positions should stay within safe zone (x:1-18, y:1-13)
    - **Switch statement**: `case .map26: basePath = map26Path` (line ~62)

  - **Tests:**
    Type: Unit tests with XCTest framework
    - **Happy path**: Map26 path has 60-80 waypoints and ends at house position
    - **Edge case**: All waypoints are within safe zone boundaries (x:1-18, y:1-13)
    - **Edge case**: First waypoint is at an edge position (x=1 or x=18 or y=1 or y=13)
    - **Edge case**: Path does not overlap house position except at final waypoint
    - **Edge case**: Last waypoint equals GridPosition(x: 10, y: 7)
    - **Integration**: MapType.allCases includes .map26 (CaseIterable automatic)
    - **Integration**: MapType.random() can select .map26
    - **Integration**: roadPath switch statement handles .map26 case

  - **Migrations / Data:**
    N/A - No data changes. MapType is compile-time enum, no persistence layer affected.

  - **Observability:**
    - Add inline comment above `map26Path` describing the perimeter loop pattern
    - MapManager.selectMap() already logs map selection via print statement (MapConfiguration.swift:645)
    - No additional logging needed for this map-only addition

  - **Security & Permissions:**
    N/A - No security concerns. This is a game map definition with no external inputs or user data.

  - **Performance:**
    - Path length: 60-80 waypoints (target range for "long but easy" gameplay)
    - Memory: Single array allocation, negligible impact
    - Path expansion via `expandPath()` runs once at property access (lazy evaluation implicit in switch)
    - No performance concerns - similar to existing Map 11 (62 waypoints) and Map 12 (38 waypoints)

  - **Commands:**
    ```bash
    # Build project (verify compilation)
    swift build

    # Run tests (new map validation tests only)
    swift test --filter MapConfigurationTests

    # Run all tests (verify no regression)
    swift test

    # Manual playtesting (build and run game)
    swift run

    # Alternative: Open in Xcode for visual debugging
    open Package.swift
    ```

  - **Risks & Mitigations:**
    - **Risk:** Path goes outside safe zone (x:1-18, y:1-13)
      **Mitigation:** Manually verify each waypoint during design. Write test case asserting all positions within bounds.

    - **Risk:** Path is too short (<60 waypoints) or too long (>80 waypoints)
      **Mitigation:** Use `expandPath()` correctly by defining key turning points only. Test verifies final expanded path length. Count waypoints manually during design.

    - **Risk:** Path doesn't reach house or ends at wrong position
      **Mitigation:** Always set last waypoint to `GridPosition(x: 10, y: 7)`. Test verifies `path.last == housePosition`.

    - **Risk:** Bugs get stuck or exhibit diagonal drift
      **Mitigation:** Vector-based movement in Bug.swift:292-300 is already implemented and tested. No changes to movement logic needed. Follow existing path patterns (straight lines and 90-degree turns).

    - **Risk:** Spiral inward segment is too complex or unclear
      **Mitigation:** Reference Map 11 (Box Spiral) lines 350-412 for working spiral pattern. Keep spiral simple with straight segments.

## Verification (global)
- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Build to verify compilation
      swift build

      # Run only MapConfigurationTests (new tests)
      swift test --filter MapConfigurationTests

      # Optional: Run all tests to verify no regression
      swift test
      ```
      **CRITICAL:** Do not run full-project checks beyond swift build and swift test.

- [ ] All acceptance criteria met (see below)
- [ ] Code follows conventions from AI_PROMPT.md and PROMPT.md:
  - MapType enum case naming: `.map26 = "Descriptive Name"`
  - Private path method: `private var map26Path: [GridPosition]`
  - Switch statement pattern: `case .map26: basePath = map26Path`
  - Inline comment documenting pattern
- [ ] Integration points properly implemented:
  - MapType enum includes .map26 (automatic via CaseIterable)
  - roadPath switch handles .map26 case
  - No changes needed to MapManager, GameScene, or Bug.swift
- [ ] Performance targets met:
  - Path length: 60-80 waypoints (counted in test)
  - Compilation time: negligible increase
- [ ] No security issues (none applicable to this task)

## Acceptance Criteria
- [ ] Map 26 enum case added to MapType with name "Perimeter Loop"
- [ ] map26Path private property implemented returning [GridPosition] array
- [ ] Switch statement in roadPath updated with .map26 case
- [ ] Path follows perimeter of safe zone (travels around edges x:1-18, y:1-13)
- [ ] Path length is 60-80 waypoints (long but straightforward)
- [ ] Path spirals inward to house at GridPosition(x: 10, y: 7)
- [ ] All waypoints within grid bounds (x:0-19, y:0-14) and safe zone (x:1-18, y:1-13)
- [ ] First waypoint is at edge position (spawn point)
- [ ] Last waypoint equals house position GridPosition(x: 10, y: 7)
- [ ] Project compiles without errors: `swift build` succeeds
- [ ] Unit tests pass: `swift test --filter MapConfigurationTests` succeeds
- [ ] Pattern follows existing map conventions (see MapConfiguration.swift:118-631)
- [ ] Code coverage: 100% of new map26Path code tested (path validity assertions)
- [ ] Inline comment documents perimeter loop pattern

## Impact Analysis
- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift` (new enum case, new path method, switch update)
    - Line ~24: Add `.map26 = "Perimeter Loop"` to MapType enum
    - Line ~62: Add `case .map26: basePath = map26Path` to roadPath switch
    - Line ~631: Add `private var map26Path: [GridPosition] { ... }` method
  - `Tests/BugDefenseTests/MapConfigurationTests.swift` (new test file)

- **Indirectly impacted:**
  - `MapType.allCases` (automatic update via CaseIterable protocol)
  - `MapType.random()` (can now select map26)
  - `MapManager.selectRandomMap()` (can now randomly assign map26)
  - GameScene.swift (no code changes, but can now use map26)
  - Future TASK11 (map selection testing task) will verify map26 integration
  - TASKΩ (final validation) will include map26 in comprehensive testing

## Follow-ups
None identified. Task is well-defined with clear constraints, existing patterns to follow, and established testing infrastructure.

## Diff Test Plan

**Changed symbols:**
- MapType enum: +1 case (.map26)
- MapType: +1 private property (map26Path)
- roadPath switch: +1 case branch

**Test cases (per changed code):**

1. **MapType.map26 enum case:**
   - Happy path: `.map26.rawValue == "Perimeter Loop"`
   - Integration: `MapType.allCases.contains(.map26)`
   - Integration: `MapType.random()` can return `.map26`

2. **map26Path property:**
   - Happy path: Returns non-empty array ending at house position
   - Edge case: All positions within grid bounds (x:0-19, y:0-14)
   - Edge case: All positions within safe zone (x:1-18, y:1-13)
   - Edge case: First position is at edge (x=1 or x=18 or y=1 or y=13)
   - Edge case: Last position equals GridPosition(x: 10, y: 7)
   - Edge case: Path length is 60-80 waypoints (after expandPath())
   - Edge case: No position overlaps house except final waypoint

3. **roadPath switch case:**
   - Happy path: `.map26.roadPath` returns expanded map26Path
   - Integration: Result passes through expandPath() correctly

**Coverage target:** 100% of new lines (enum case, property, switch case)

**Out of scope (unchanged code):**
- expandPath() algorithm (tested in existing tests)
- Bug vector movement (tested in BugMovementTests.swift)
- MapManager selection logic (unchanged)
- GameScene integration (unchanged)

**Test execution:**
```bash
swift test --filter MapConfigurationTests
```

**Success criteria:**
- All new test cases pass twice consecutively
- 100% coverage of new map26 code paths
- No regression in existing tests (swift test passes)
- No unrelated failures
