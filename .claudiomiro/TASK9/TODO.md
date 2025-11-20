Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK9/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK9/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack and framework versions (Swift 5.x, SpriteKit)
- Project structure and architecture (Entity-Component pattern)
- Coding conventions and patterns (enum-based map system)
- Related code examples with file:line references
- Integration points and dependencies (GameScene, Bug movement)

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Design Starburst/Radial Path Pattern [Implementation + Manual Verification]**
  - **What to do:**
    1. **Design starburst waypoint pattern on paper/sketch (20x15 grid):**
       - Create 3-4 radial arms emanating from or pointing toward the center area
       - Arms should be spoke-like, creating visual symmetry (e.g., NW, NE, SW spokes)
       - Path should weave through/visit multiple arms to approach center from different angles
       - Target: 45-60 waypoints for moderate difficulty

    2. **Define key turning point waypoints as GridPosition array:**
       - Start at an edge position (spawn point) within safe zone x:1-18, y:1-13
       - Create path that:
         a. Enters along one radial arm
         b. Curves to visit 2-3 other arms (creating multi-directional approach)
         c. Spirals or angles toward center
         d. Ends at GridPosition(x: 10, y: 7) - house position (MANDATORY)
       - Use diagonal segments to create spoke angles (vector movement handles smoothness)
       - Ensure waypoints create visual radial symmetry

    3. **Implement in MapConfiguration.swift following exact pattern:**
       - Add enum case: `.map29 = "Starburst"` at line ~24 (after .map28 if exists, or after .map20)
       - Create private method: `private var map29Path: [GridPosition]` following pattern from MapConfiguration.swift:118-137 (map1Path example)
       - Return array of GridPosition waypoints (corners only - expandPath() handles interpolation)
       - Add switch case in `roadPath` computed property at line ~62: `case .map29: basePath = map29Path`

    4. **Example starburst structure (adapt as needed):**
       ```swift
       // Map 29: Starburst - Radial spokes approaching center from multiple angles
       private var map29Path: [GridPosition] {
           return [
               GridPosition(x: 1, y: 3),    // Spawn: left edge
               GridPosition(x: 4, y: 3),    // NW spoke entry
               GridPosition(x: 7, y: 5),    // Curve toward center
               GridPosition(x: 9, y: 3),    // NE spoke
               GridPosition(x: 12, y: 5),   // East spoke
               GridPosition(x: 14, y: 8),   // SE spoke
               GridPosition(x: 11, y: 10),  // South spoke
               GridPosition(x: 8, y: 9),    // Approach center from south
               GridPosition(x: 10, y: 7)    // HOUSE (center) - MANDATORY END
           ]
       }
       ```
       NOTE: This is illustrative - create your own path that achieves radial pattern with 3-4 spokes.

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:4-25` — Enum pattern and existing map cases
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:40-67` — Switch statement structure for roadPath
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:70-103` — Path expansion algorithm (auto-fills between waypoints)
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:105-108` — House position (always center)
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:118-137` — Map 1 example (simple pattern)
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:168-182` — Map 3 S-Curve (diagonal movement example)
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:350-412` — Map 11 Box Spiral (complex pattern example)

  - **Touched (will modify/create):**
    - MODIFY: `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift` — Add enum case `.map29` (~line 24)
    - MODIFY: `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift` — Add method `map29Path` (after last map path definition, before closing brace)
    - MODIFY: `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift` — Add switch case in `roadPath` computed property (~line 62)

  - **Interfaces / Contracts:**
    - **Enum Contract:** `case .map29 = "Starburst"` - must match CaseIterable protocol
    - **Path Method Signature:** `private var map29Path: [GridPosition]` - returns array of waypoints
    - **Path Array Contract:** `[GridPosition]` where:
      - First element = spawn point (edge of safe zone)
      - Last element = GridPosition(x: 10, y: 7) (house position - MANDATORY)
      - All elements within bounds: x ∈ [1, 18], y ∈ [1, 13] (safe zone)
    - **Integration:** MapType.allCases automatically includes .map29 (CaseIterable)

  - **Tests:**
    Type: Manual visual verification (Swift/SpriteKit project - no unit test framework currently used)
    - **Happy path:** Build and run game, select map29 via random selection or forced assignment, verify:
      1. Road tiles render along starburst path
      2. Bugs spawn at first waypoint
      3. Bugs follow path through multiple radial arms
      4. Bugs reach house at center
    - **Edge case:** Diagonal segments - verify bugs move smoothly without stair-stepping (vector movement handles this - Bug.swift:292-300)
    - **Edge case:** Sharp turns between spokes - verify bugs navigate 90+ degree turns precisely
    - **Failure scenario:** Path validation - compile-time check ensures path ends at house (manual code review)

  - **Migrations / Data:**
    N/A - No data migrations. Map definitions are compile-time code in Swift enum.

  - **Observability:**
    N/A - No logging/metrics required for map data definition. Visual verification via game rendering is sufficient.

  - **Security & Permissions:**
    N/A - No security concerns. Single-player game with local map data (no network, no user input processed).

  - **Performance:**
    - **Target:** Map selection O(1) via enum switch - already satisfied by implementation pattern
    - **Constraint:** Path length 45-60 waypoints (moderate) - keeps memory usage minimal
    - **Optimization:** Path expansion computed once at map load (cached in roadPath computed property)
    - **No performance issues expected** - following existing pattern (20 maps already working)

  - **Commands:**
    ```bash
    # Build the Swift project
    swift build

    # Run the game (macOS)
    swift run

    # Alternative: Open in Xcode and run
    open Package.swift
    # Then Cmd+R to build and run in Xcode

    # No automated tests for map definitions - manual visual verification required
    # To test specifically: modify GameScene.swift temporarily to force map29 selection,
    # or wait for random selection during tier progression
    ```

  - **Risks & Mitigations:**
    - **Risk:** Path doesn't create visible starburst/radial pattern
      **Mitigation:** Sketch on paper first (20x15 grid). Use diagonal segments to create spoke angles. Reference Map 3 (S-Curve) for diagonal waypoint examples (MapConfiguration.swift:168-182).

    - **Risk:** Path goes outside safe zone (x:1-18, y:1-13)
      **Mitigation:** Double-check all GridPosition waypoints before implementing. Safe zone constraint is critical (bugs/towers break at edges).

    - **Risk:** Path doesn't end at house GridPosition(x: 10, y: 7)
      **Mitigation:** ALWAYS make last waypoint `GridPosition(x: 10, y: 7)`. Compile and verify before testing.

    - **Risk:** Spokes don't look radial/symmetrical
      **Mitigation:** Plan arms pointing outward from center (e.g., NW at (4,10), NE at (16,10), SW at (4,4), SE at (16,4)). Path can weave between them.

## Verification (global)

- [ ] Run build to ensure code compiles without errors:
      ```bash
      swift build
      ```
      **CRITICAL:** Swift compiler will catch enum/switch mismatches, missing cases, syntax errors.

- [ ] Manual visual verification (run game and observe):
      ```bash
      swift run
      # OR open in Xcode and run (Cmd+R)
      ```
      Test checklist:
      - [ ] Map 29 can be selected (random map pool or force selection)
      - [ ] Road tiles render along starburst path (brown dirt color)
      - [ ] Starburst/radial pattern is visually clear (3-4 spokes visible)
      - [ ] Bugs spawn at first waypoint (edge position)
      - [ ] Bugs follow path through multiple arms
      - [ ] Bugs approach center from different angles (multi-directional)
      - [ ] Bugs reach house at GridPosition(x: 10, y: 7)
      - [ ] No visual gaps in road tiles
      - [ ] Towers cannot be placed on road tiles (blocked correctly)

- [ ] All acceptance criteria met (see below)

- [ ] Code follows Swift/SpriteKit conventions from AI_PROMPT.md:
      - Enum case naming: `.map29 = "Starburst"`
      - Method naming: `private var map29Path: [GridPosition]`
      - Waypoint array structure: start at edge, end at house
      - Safe zone adherence: all positions within x:1-18, y:1-13

- [ ] Integration points verified:
      - MapType.allCases includes .map29 (automatic via CaseIterable)
      - Random map selection can pick map29
      - Path assigned to bugs via GameScene.swift:488-504 (no code change needed)
      - Tower placement blocked on road via GameScene.swift:826-856 (no code change needed)

## Acceptance Criteria

- [ ] **Map 29 enum case added:** `.map29 = "Starburst"` exists in MapType enum (MapConfiguration.swift ~line 24)
- [ ] **Path method implemented:** `private var map29Path: [GridPosition]` defined with waypoint array
- [ ] **Switch case updated:** `case .map29: basePath = map29Path` added to roadPath switch statement
- [ ] **Clear radial/starburst visual pattern:** 3-4 radial arms visible when rendered (verified by running game)
- [ ] **Path visits 3-4 different arms:** Bugs traverse multiple spokes during journey to house
- [ ] **Approaches center from multiple angles:** Path demonstrates multi-directional convergence on house
- [ ] **Path stays within safe zone:** All waypoints satisfy: x ∈ [1, 18] AND y ∈ [1, 13]
- [ ] **Path ends at house:** Final waypoint is GridPosition(x: 10, y: 7) - MANDATORY
- [ ] **Path length 45-60 waypoints:** After expansion, path has moderate length (count roadPath.count)
- [ ] **Code compiles successfully:** `swift build` completes without errors
- [ ] **Bugs navigate correctly:** Bugs spawn, follow path through spokes, reach house without getting stuck
- [ ] **Visual rendering correct:** Road tiles appear along entire path with no gaps
- [ ] **Distinct from existing maps:** Starburst pattern visually unique compared to maps 1-28

## Impact Analysis

- **Directly impacted:**
  - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:24` (enum case addition)
  - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:62` (switch statement update)
  - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:~630+` (new map29Path method)

- **Indirectly impacted:**
  - `MapType.allCases` - automatically includes .map29 via CaseIterable protocol
  - `MapType.random()` - expanded map pool now includes map29 for random selection
  - `MapManager.selectRandomMap()` - can select map29 during tier progression (no code change needed)
  - `GameScene.spawnBug()` - will assign map29 path to bugs when map29 is active (no code change needed)
  - `GameScene.drawGrid()` - will render map29 road tiles (no code change needed)
  - `GameScene.canPlaceStructure()` - will block towers on map29 road tiles (no code change needed)

- **Parallel tasks (TASK1-TASK10):**
  - Each adds one map (21-30) following identical pattern
  - No conflicts expected - separate enum cases and methods
  - TASK11 (integration/testing) depends on all maps being implemented
  - TASKΩ (final validation) depends on all maps being implemented

## Follow-ups

- None identified. Task is self-contained with clear specifications.
- If starburst pattern is unclear after implementation, can reference real-world examples (roundabout with radial roads, bicycle wheel spokes, star/asterisk shape).
