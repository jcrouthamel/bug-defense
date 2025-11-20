Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK8/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK8/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack and framework versions (Swift 5.x, SpriteKit, Swift Package Manager)
- Project structure and architecture (Entity-Component pattern)
- Coding conventions and patterns (enum cases, path methods, switch statements)
- Related code examples with file:line references
- Integration points and dependencies (MapType enum, expandPath, roadPath switch)

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Design and Implement Map 28 Wave Pattern**
  - **What to do:**
    1. Design a horizontal wave pattern resembling sine/cosine waves with 2-3 complete cycles
    2. Add `.map28 = "Wave Flow"` enum case to MapType in `Sources/BugDefense/MapConfiguration.swift:26`
    3. Implement `map28Path` method returning `[GridPosition]` array with waypoints forming smooth wave curves
    4. Add `case .map28: basePath = map28Path` to the roadPath switch statement at line ~64
    5. Create waypoints that form smooth peaks and troughs, avoiding sharp angles
    6. Ensure path starts at a grid edge (spawn point), stays within safe zone (x:1-18, y:1-13), and ends at GridPosition(x: 10, y: 7)
    7. Target 40-55 waypoints for smooth curves (more waypoints = smoother waves)
    8. Example wave structure: Start low, curve up to peak, curve down to trough, repeat 2-3 times, converge to house

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:5-26` — MapType enum definition and existing cases (maps 1-20)
    - `Sources/BugDefense/MapConfiguration.swift:41-68` — roadPath switch statement pattern to follow
    - `Sources/BugDefense/MapConfiguration.swift:70-103` — expandPath() algorithm (understand how waypoints are interpolated)
    - `Sources/BugDefense/MapConfiguration.swift:105-113` — housePosition and spawnPoints implementation
    - `Sources/BugDefense/MapConfiguration.swift:334-347` — Map 10: Wave Pattern (existing wave pattern for reference)
    - `Sources/BugDefense/MapConfiguration.swift:168-182` — Map 3: S-Curve (smooth diagonal curves pattern)
    - `Sources/BugDefense/MapConfiguration.swift:139-166` — Map 2: Zigzag (contrast: angular vs smooth)
    - `AI_PROMPT.md:39-44` — Grid system specifications (20x15 tiles, safe zone boundaries)

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift:26` — Add `.map28 = "Wave Flow"` after `.map20`
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift:~631` — Add `private var map28Path: [GridPosition]` method (after map20Path)
    - MODIFY: `Sources/BugDefense/MapConfiguration.swift:64` — Add `case .map28: basePath = map28Path` in switch statement

  - **Interfaces / Contracts:**
    - MapType enum: Must add new case `.map28` with String raw value "Wave Flow"
    - Path method signature: `private var map28Path: [GridPosition] { return [...] }`
    - Return type: Array of GridPosition structs with x and y coordinates
    - Path constraints:
      - First waypoint: Edge position (e.g., x:1 or x:2, y:variable)
      - Last waypoint: GridPosition(x: 10, y: 7) — house position (mandatory)
      - All waypoints: x:1-18, y:1-13 (safe zone)
      - Length: 40-55 waypoints for smooth wave curves
    - Integration: MapType.allCases automatically includes new case (CaseIterable protocol)

  - **Tests:**
    Type: Unit tests with XCTest framework
    - Happy path: Map28 path is valid, starts at edge, ends at house (x:10, y:7)
    - Happy path: Map28 path stays within safe zone (all x:1-18, y:1-13)
    - Happy path: Path has 40+ waypoints for smooth curves
    - Edge case: Map28 can be selected via MapType.random()
    - Edge case: Map28 included in MapType.allCases count (>= 21)
    - Visual verification: Run game, select Map 28, observe smooth wave pattern
    - Visual verification: Bugs follow wave path precisely without drift
    - Visual verification: Road tiles render continuously along wave path

  - **Migrations / Data:**
    N/A - No data changes. Maps are compile-time enum definitions.

  - **Observability:**
    - Existing MapManager logging will output: "🗺️ Selected map: Wave Flow" when map28 selected
    - No additional logging required for this map-specific implementation
    - Debug: Manually test by adding `MapManager.shared.selectMap(.map28)` in GameScene if needed

  - **Security & Permissions:**
    N/A - No security concerns. This is local game data with no user input or external data sources.

  - **Performance:**
    - Path array memory: ~40-55 GridPosition structs (8 bytes each) = ~320-440 bytes
    - Path expansion: O(n*m) where n=waypoints, m=max distance between waypoints (handled by existing expandPath)
    - Performance target: Same as existing maps (no special optimization needed)
    - Algorithmic complexity: O(1) access via enum switch statement
    - No runtime generation - all paths pre-computed at compile time

  - **Commands:**
    ```bash
    # Build the project
    swift build

    # Run tests for MapConfiguration (if test file exists)
    swift test --filter MapConfigurationTests

    # Run all tests to ensure no regressions
    swift test

    # Run the game to visually verify
    swift run BugDefenseApp

    # For manual verification in-game, modify GameScene.swift temporarily:
    # In GameScene.init(), add: MapManager.shared.selectMap(.map28)
    # Then run: swift run BugDefenseApp
    ```

  - **Risks & Mitigations:**
    - **Risk:** Wave pattern too steep, bugs might appear to jump or glitch
      **Mitigation:** Use smooth curves with gradual Y-axis changes. Reference Map 10 wave pattern (lines 334-347) which uses 1-2 grid unit vertical changes per waypoint. Test with 3-5 waypoints per wave peak/trough.

    - **Risk:** Path goes outside safe zone boundaries
      **Mitigation:** Verify all waypoints have x:1-18 and y:1-13 before committing. Use map10Path as reference for safe wave amplitude.

    - **Risk:** Path length too short (choppy waves) or too long (performance)
      **Mitigation:** Target 40-55 waypoints. Compare to existing paths: map10 has ~9 waypoints, map5 (complex) has ~31. Waves need more for smoothness, but expandPath() will interpolate intermediate tiles.

    - **Risk:** Final waypoint doesn't reach house
      **Mitigation:** Always end with `GridPosition(x: 10, y: 7)`. Double-check last element in array.

    - **Risk:** Pattern looks identical to existing Map 10 wave pattern
      **Mitigation:** Map 10 has 1 wave cycle. Map 28 must have 2-3 cycles with visible peaks and troughs. Differentiate by having more oscillations or different wave amplitude.

## Verification (global)
- [ ] Run targeted tests ONLY for changed code:
      ```bash
      # Compile check - ensure no syntax errors
      swift build

      # Run tests to verify map integration
      swift test --filter MapConfigurationTests
      # If MapConfigurationTests doesn't exist yet, run all tests:
      swift test

      # Manual verification - run game and select map 28
      swift run BugDefenseApp
      # Then in-game: Force map28 by modifying GameScene.init() temporarily
      # Or: Wait for random selection to pick map28
      ```
      **CRITICAL:** Do not run full-project linters or formatters - only verify compilation and tests pass
- [ ] All acceptance criteria met (see below)
- [ ] Code follows conventions from AI_PROMPT.md and TASK.md:
      - Enum case follows `.map## = "Name"` pattern
      - Method follows `private var map##Path: [GridPosition]` pattern
      - Switch case added in correct location
      - Waypoints use GridPosition struct (not CGPoint)
- [ ] Integration points properly implemented:
      - MapType.allCases includes .map28 automatically (CaseIterable)
      - roadPath switch returns map28Path for .map28 case
      - expandPath() handles wave waypoints correctly (no code change needed)
- [ ] Visual verification (manual):
      - Wave pattern visible with 2-3 cycles
      - Smooth curves, not angular
      - Bugs follow path precisely
      - Road tiles render continuously

## Acceptance Criteria
- [ ] Map 28 added to MapType enum with name "Wave Flow"
- [ ] map28Path method implemented returning [GridPosition] array
- [ ] roadPath switch statement updated with .map28 case
- [ ] Wave pattern has 2-3 complete cycles (peaks and troughs)
- [ ] Path creates smooth curves using multiple waypoints (not angular zigzags)
- [ ] All waypoints within safe zone (x:1-18, y:1-13)
- [ ] Path starts at edge position (spawn point)
- [ ] Path ends at GridPosition(x: 10, y: 7) - house position
- [ ] Path length is 40-55 waypoints (before expansion) for smooth curves
- [ ] Code compiles without errors: `swift build` succeeds
- [ ] Visual verification: Wave pattern visible and distinct from existing maps
- [ ] Bugs navigate smoothly along wave path without jumping or glitching
- [ ] Pattern differs from Map 10 by having 2-3 cycles instead of 1

## Impact Analysis
- **Directly impacted:**
  - `Sources/BugDefense/MapConfiguration.swift:26` — Add .map28 enum case
  - `Sources/BugDefense/MapConfiguration.swift:~631` — Add map28Path method
  - `Sources/BugDefense/MapConfiguration.swift:64` — Update roadPath switch statement
  - MapType.allCases count increases from 20 to 21
  - MapType.random() pool expands to include map28

- **Indirectly impacted:**
  - `GameScene.swift` — Will be able to render map28 via existing grid drawing logic
  - `Bug.swift` — Will receive map28 path via existing setPath() mechanism
  - `MapManager` — Can select map28 via selectRandomMap()
  - Future tasks TASK9, TASK10 (parallel map implementations) — Same pattern
  - TASK11 (likely map consolidation/testing) — Will need to include map28
  - TASKΩ (final validation) — Will test map28 integration

## Follow-ups
- None identified. Requirements are clear:
  - Wave pattern design specifications provided
  - Safe zone boundaries defined
  - Path length target specified (40-55 waypoints)
  - End position fixed (house at 10, 7)
  - Reference patterns available (Map 10 wave, Map 3 S-curve)
