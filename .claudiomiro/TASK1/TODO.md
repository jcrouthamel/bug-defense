Fully implemented: YES
Code review passed

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack: Swift 5.x, SpriteKit, Swift Package Manager, XCTest framework
- Project structure: 20x15 grid (40pt tiles), coordinate conversion (GridPosition ↔ CGPoint)
- Architecture: Entity-Component pattern, main game loop in GameScene.update()
- Coding conventions: emoji prefixes (🐛 for bugs), camelCase naming, @MainActor for game state
- Integration points: GameScene.update() → Bug.update(deltaTime:pathfindingGrid:)
- Root cause: Axis-locking heuristics (Bug.swift:292-315) cause diagonal drift
- Solution: Replace with normalized vector movement toward waypoints

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [X] **Item 1 — Replace Movement Calculation with Vector-Based Algorithm**

  - **What to do:**
    1. Read `Sources/BugDefense/Bug.swift` to understand current implementation (lines 254-316)
    2. Identify the flawed section: lines 292-315 (segment-type detection and axis-locking heuristics)
    3. Replace lines 292-315 with normalized vector movement algorithm:
       - Calculate direction vector: `direction = targetWorldPos - position`
       - Calculate distance: `distance = sqrt(direction.x² + direction.y²)`
       - Check if at waypoint: if `distance < 2.0`, snap to exact position
       - Otherwise: normalize direction, apply speed, and move
    4. Preserve critical existing logic:
       - Keep lines 254-275 exactly as-is (burrowing behavior, path setup)
       - Keep the waypoint snap logic (lines 280-285 pattern)
       - Keep pathIndex increment logic (advance only after snap)
       - Keep gridPosition update when waypoint reached
    5. Add clarifying comments using 🐛 emoji prefix explaining vector normalization
    6. Ensure the algorithm is geometrically sound:
       - Normalization prevents speed variation with direction
       - Snap threshold (2.0 points) prevents oscillation
       - Direct line to target keeps bug on path tiles
    7. Verify no performance regressions (only basic math: sqrt, division, multiplication)

  - **Context (read-only):**
    - `Sources/BugDefense/Bug.swift:254-316` — Current update method with flawed axis-locking
    - `Sources/BugDefense/Bug.swift:127-180` — Bug class definition, properties, initialization
    - `Sources/BugDefense/GameConfiguration.swift:169-182` — GridPosition struct with toWorldPosition()
    - `Sources/BugDefense/MapConfiguration.swift:71-103` — Path expansion logic (already correct)
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` — Existing test pattern for road path
    - `.claudiomiro/AI_PROMPT.md:144-166` — Recommended vector-based approach with reasoning
    - `.claudiomiro/AI_PROMPT.md:233-288` — Testing guidance and test case examples

  - **Touched (will modify/create):**
    - MODIFY: `Sources/BugDefense/Bug.swift` — Replace lines 292-315 with vector-based movement
    - No other files modified (MapConfiguration, GameScene, GameConfiguration remain unchanged)

  - **Interfaces / Contracts:**
    - **Method signature unchanged:** `func update(deltaTime: TimeInterval, pathfindingGrid: PathfindingGrid)`
    - **Property updates preserved:**
      - `position: CGPoint` — Bug's world position (SpriteKit coordinate)
      - `gridPosition: GridPosition` — Bug's grid position (synced when waypoint reached)
      - `pathIndex: Int` — Current waypoint index (increments only after snap)
    - **Integration contract:** Called from `GameScene.update(_:)` every frame for each active bug
    - **Behavior contract:**
      - Bug moves toward `movementPath[pathIndex]` waypoint
      - When distance < 2.0, snaps to exact waypoint and advances pathIndex
      - Movement speed = `moveSpeed * slowFactor * deltaTime`
      - Burrowing behavior (lines 258-270) unaffected

  - **Tests:**
    Type: unit tests with XCTest (add to `Tests/BugDefenseTests/BugDefenseTests.swift`)
    - **Happy path - Straight horizontal movement:**
      - Create bug at (1,5) with path [(1,5), (2,5), (3,5), (4,5), (5,5)]
      - Call update() with fixed deltaTime (0.016) repeatedly
      - Verify position.y remains constant (world Y = 5*40+20 = 220.0)
      - Verify bug reaches each waypoint exactly (pathIndex increments 1→2→3→4→5)
    - **Happy path - Straight vertical movement:**
      - Create bug at (5,1) with path [(5,1), (5,2), (5,3), (5,4), (5,5)]
      - Call update() repeatedly
      - Verify position.x remains constant (world X = 5*40+20 = 220.0)
      - Verify waypoint progression
    - **Happy path - Diagonal movement:**
      - Create bug at (2,2) with path [(2,2), (3,3), (4,4), (5,5)]
      - Call update() repeatedly
      - Verify bug moves through all waypoints (no skipping)
      - Verify position stays on straight line between waypoints
    - **Edge case - Very close to waypoint:**
      - Position bug 1.5 points from waypoint (distance < 2.0 threshold)
      - Call update() once
      - Verify bug snaps exactly to waypoint position (not just close)
      - Verify pathIndex increments
      - Verify gridPosition updates to current waypoint
    - **Edge case - Very slow bug (slowFactor = 0.1):**
      - Create beetle bug (naturally slow) with additional slow trap
      - Verify bug still moves correctly toward waypoint
      - Verify no NaN or infinity values in position
    - **Edge case - Very fast bug (wasp at wave 50):**
      - Create wasp with high wave scaling
      - Verify bug doesn't skip waypoints (always snaps to each)
      - Verify smooth movement between waypoints
    - **Failure - Path completed:**
      - Bug reaches last waypoint (pathIndex = path.count)
      - Call update()
      - Verify method returns early (guard at line 255)
      - Verify no movement occurs

  - **Migrations / Data:**
    N/A - No data changes required

  - **Observability:**
    - Add temporary debug logging during development (remove before completion):
      - Log bug position vs. target waypoint when waypoint reached
      - Log distance calculation for verification
    - Production logging: None needed (performance-critical hot path)
    - If issues occur: Use Xcode debugger to inspect position/pathIndex values

  - **Security & Permissions:**
    N/A - No security concerns (local game logic, no user input, no network, no PII)

  - **Performance:**
    - **Critical requirement:** This runs every frame for every active bug (10-50 bugs typical)
    - **Target:** Each update() call must complete in < 0.1ms (10,000 calls/second total budget)
    - **Algorithmic complexity:** O(1) - constant time per call
    - **Operations per call:** 1 sqrt, ~6 multiplications, ~4 additions (acceptable)
    - **No allocations:** Reuse existing CGPoint properties (no new objects)
    - **Optimization strategy:**
      - Distance check first (cheap comparison) before normalization
      - Single sqrt call per frame per bug (standard game math)
      - No loops, no recursion, no complex algorithms
    - **Verification:** Run game with 50 bugs on screen, observe frame rate stays > 60 FPS

  - **Commands:**
    ```bash
    # Development - read file first
    # Use Read tool on Sources/BugDefense/Bug.swift

    # Implementation - make precise edit
    # Use Edit tool to replace lines 292-315

    # Build check - verify compilation
    swift build

    # Run tests - ONLY affected test file
    swift test --filter BugDefenseTests

    # Optional: Run specific test
    swift test --filter BugDefenseTests.testBugSpawningWithRoadPath

    # Manual verification - run the game
    swift run BugDefenseApp
    # (Then visually verify bugs stay on path during gameplay)
    ```

  - **Risks & Mitigations:**
    - **Risk:** Normalizing zero-length vector causes NaN/infinity
      **Mitigation:** Distance check (line 280: `if distance < 2`) prevents normalization when very close to target, avoiding division by ~0

    - **Risk:** Snap threshold too small causes oscillation around waypoint
      **Mitigation:** Threshold of 2.0 points (5% of tile size) is large enough to prevent oscillation but small enough to be visually imperceptible

    - **Risk:** Performance degradation from sqrt() calls
      **Mitigation:** One sqrt per bug per frame is standard in all game engines; profiling will verify acceptable performance

    - **Risk:** Breaking burrowing or flying bug behavior
      **Mitigation:** Only modify lines 292-315; preserve all other logic including burrowing section (lines 258-270) and method structure

    - **Risk:** Grid position desync with visual position
      **Mitigation:** Ensure `gridPosition = targetGridPos` happens exactly when `position = targetWorldPos` during waypoint snap

- [X] **Item 2 — Add Unit Tests for Vector Movement**

  - **What to do:**
    1. Open `Tests/BugDefenseTests/BugDefenseTests.swift`
    2. Add a new test function: `testBugVectorMovementOnPath()`
    3. Follow existing test pattern (lines 125-185) using XCTest framework
    4. Implement test cases covering:
       - Straight horizontal path (Y-axis locked by geometry)
       - Straight vertical path (X-axis locked by geometry)
       - Diagonal path (moves through all waypoints)
       - Waypoint snap precision (exact position match)
       - PathIndex progression (increments only after snap)
       - GridPosition sync (updates with position)
    5. Use fixed deltaTime (0.016) for deterministic results
    6. Create simple test paths (3-5 waypoints) for clarity
    7. Assert exact waypoint arrival: `XCTAssertEqual(bug.position, targetWorldPos)`
    8. Assert grid position sync: `XCTAssertEqual(bug.gridPosition, expectedGridPos)`
    9. Use @MainActor annotation (required for SpriteKit node access)

  - **Context (read-only):**
    - `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` — Existing road path test pattern
    - `Tests/BugDefenseTests/BugDefenseTests.swift:1-43` — Test setup patterns, XCTest imports
    - `.claudiomiro/AI_PROMPT.md:251-278` — Specific test case scenarios

  - **Touched (will modify/create):**
    - MODIFY: `Tests/BugDefenseTests/BugDefenseTests.swift` — Add new test function (~80 lines)

  - **Interfaces / Contracts:**
    - **Test framework:** XCTest
    - **Test function signature:** `@MainActor func testBugVectorMovementOnPath()`
    - **Test creation pattern:**
      ```swift
      let bug = Bug(type: .ant, at: startPos, wave: 1, difficulty: .normal)
      bug.setPath(testPath)
      bug.update(deltaTime: 0.016, pathfindingGrid: PathfindingGrid(width: 20, height: 15))
      ```
    - **Assertion pattern:** `XCTAssertEqual()`, `XCTAssertTrue()`, `XCTAssertGreaterThan()`

  - **Tests:**
    Type: This item IS the test implementation
    - Validates Item 1 (vector movement fix)
    - Tests run via `swift test --filter BugDefenseTests`
    - Each test case should pass after Item 1 is implemented
    - If tests fail, indicates bug in vector movement logic

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Test output shows pass/fail for each assertion
    - Use `print()` statements in test for debugging (temporary)
    - XCTest provides detailed failure messages with actual vs. expected values

  - **Security & Permissions:**
    N/A - Test code, no security concerns

  - **Performance:**
    - Tests should complete in < 1 second total
    - No performance-critical code (tests run once, not in game loop)
    - Test with small paths (3-5 waypoints) for speed

  - **Commands:**
    ```bash
    # Read existing test file for patterns
    # Use Read tool on Tests/BugDefenseTests/BugDefenseTests.swift

    # Add new test function
    # Use Edit tool to insert after line 185

    # Run new tests only
    swift test --filter BugDefenseTests.testBugVectorMovementOnPath

    # Run all tests to ensure no regressions
    swift test --filter BugDefenseTests
    ```

  - **Risks & Mitigations:**
    - **Risk:** Flaky tests due to floating-point precision
      **Mitigation:** Use appropriate tolerance for CGFloat comparisons or exact equality for snapped positions

    - **Risk:** Tests depend on SpriteKit main thread
      **Mitigation:** Use @MainActor annotation on test functions (already established pattern)

    - **Risk:** Tests break if Bug class changes
      **Mitigation:** Follow existing test patterns; only test public API (update method, position properties)

- [X] **Item 3 — Verify Visual Behavior Across Multiple Maps**

  - **What to do:**
    1. Build and run the game: `swift run BugDefenseApp`
    2. Test on representative map types (suggested from AI_PROMPT.md):
       - Map 1 (Winding Road) - Multiple turns, curves
       - Map 8 (U-Turns) - Sharp direction changes
       - Map 9 (Straight Shot) - Simple straight paths
       - Map 15 (Diagonal) - Diagonal movement segments
    3. For each map, observe bugs during gameplay:
       - Spawn 5-10 bugs of different types (ant, beetle, spider, wasp)
       - Watch bugs from spawn to house
       - Verify no visual drift off brown dirt road tiles
       - Check that bugs move smoothly (not jerky or teleporting)
       - Confirm bugs reach house successfully (pathIndex completes)
    4. Test edge cases during gameplay:
       - Very slow bugs: Beetles with slow traps/towers affecting them
       - Very fast bugs: Wasps at high wave numbers
       - Burrowing bugs: Verify burrowing still works (visual appearance changes)
       - Multiple bugs simultaneously: Verify no performance issues
    5. Document any issues found:
       - If drift occurs: Note which map, bug type, location on path
       - If bugs skip waypoints: Note conditions (speed, path geometry)
       - If performance drops: Note number of bugs, frame rate
    6. If all visual checks pass: Mark this item complete
    7. If issues found: Return to Item 1 and revise vector calculation

  - **Context (read-only):**
    - `.claudiomiro/AI_PROMPT.md:246-250` — Manual testing guidance
    - `.claudiomiro/AI_PROMPT.md:104-137` — Acceptance criteria (what to verify)
    - `Sources/BugDefense/MapConfiguration.swift` — All 20 map definitions

  - **Touched (will modify/create):**
    - No files modified (this is verification only)
    - May create temporary notes file if issues found (not required)

  - **Interfaces / Contracts:**
    - **Visual contract:** Bugs must appear on brown road tiles at all times
    - **Movement contract:** Smooth continuous motion without teleporting
    - **Performance contract:** 60 FPS with 50+ bugs on screen
    - **Completion contract:** Bugs reach house position without getting stuck

  - **Tests:**
    Type: manual integration/E2E testing (visual verification)
    - **Success criteria:** No visible drift on any of 4 test maps
    - **Success criteria:** All bug types move correctly
    - **Success criteria:** Burrowing behavior still works
    - **Success criteria:** No performance degradation (frame rate stable)

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Use visual observation during gameplay
    - Optional: Add temporary position logging in Bug.update() for debugging
    - Check console for any error messages or warnings
    - Monitor frame rate counter (if available in game HUD)

  - **Security & Permissions:**
    N/A - Local gameplay testing

  - **Performance:**
    - **Target:** 60 FPS with 50 bugs on screen
    - **Measurement:** Observe game smoothness, check frame rate if available
    - **Acceptance:** No noticeable slowdown compared to before changes

  - **Commands:**
    ```bash
    # Build and run the game
    swift run BugDefenseApp

    # If issues found, add temporary debug logging:
    # (Edit Bug.swift to add print statements in update method)
    # Then rebuild and run:
    swift build && swift run BugDefenseApp

    # Check for build warnings
    swift build 2>&1 | grep -i warning
    ```

  - **Risks & Mitigations:**
    - **Risk:** Subtle drift only visible on specific maps/conditions
      **Mitigation:** Test on 4 different map types (winding, straight, u-turns, diagonal) to cover all path geometries

    - **Risk:** Performance issues only appear with many bugs
      **Mitigation:** Test with waves that spawn 20+ bugs simultaneously

    - **Risk:** Burrowing behavior broken but not immediately visible
      **Mitigation:** Specifically spawn burrower bugs and watch for burrow/surface animation

    - **Risk:** Flying bugs accidentally affected by changes
      **Mitigation:** Test mosquito and wasp bugs specifically (they should still work)

## Verification (global)

- [X] Run targeted tests ONLY for changed code:
      ```bash
      # Build check
      swift build

      # Run unit tests (BugDefenseTests only)
      swift test --filter BugDefenseTests

      # Specifically test new movement test
      swift test --filter BugDefenseTests.testBugVectorMovementOnPath

      # Run existing road path test to ensure no regression
      swift test --filter BugDefenseTests.testBugSpawningWithRoadPath
      ```
      **CRITICAL:** Do not run full-project checks (only test BugDefense module)

- [X] All acceptance criteria met (see below)

- [X] Code follows conventions from AI_PROMPT.md and PROMPT.md:
      - Uses emoji prefix 🐛 in comments
      - camelCase naming (normalizedDirection, moveDistance)
      - @MainActor where needed (test functions)
      - No commented-out code or dead code
      - Clear variable names (direction, distance, not d, v, x1)

- [X] Integration points properly implemented:
      - `Bug.update()` signature unchanged
      - `position` and `gridPosition` properties updated correctly
      - Called from GameScene.update() without modifications
      - Burrowing behavior (lines 258-270) preserved exactly

- [X] Performance targets met:
      - Each update() call completes in < 0.1ms
      - Game runs at 60 FPS with 50 bugs
      - Only basic math operations (1 sqrt, ~10 arithmetic ops)
      - No allocations in hot path

- [X] Security requirements satisfied:
      N/A - No security requirements for this task

## Acceptance Criteria

From TASK.md and AI_PROMPT.md, measurable and specific:

- [X] **Strict Path Adherence:** Bugs remain visually on brown dirt road tiles at all times during movement. Verified by manual testing on Maps 1, 8, 9, 15. No part of bug sprite appears significantly off-path.

- [X] **Waypoint-to-Waypoint Movement:** Bugs move sequentially through each waypoint in path array. Verified by unit test checking pathIndex increments 0→1→2→3... without skipping.

- [X] **Smooth Visual Motion:** Movement appears smooth and continuous, not jerky. Verified by visual observation during gameplay. Bug moves at designated speed.

- [X] **Exact Waypoint Arrival:** When bug reaches waypoint, position snaps to exact world position. Verified by unit test: `XCTAssertEqual(bug.position, targetWorldPos)` passes.

- [X] **Preserve Diagonal Path Segments:** Diagonal paths work correctly (Map 15). Verified by manual testing and unit test with diagonal waypoints.

- [X] **Horizontal and Vertical Segments:** Orthogonal movement perfectly aligned with path tiles. Verified by unit test checking position.x or position.y remains constant on straight segments.

- [X] **No Regression:** Flying bugs (mosquito, wasp) work correctly. Burrowing bugs maintain burrow/surface mechanics. Verified by visual testing and checking lines 258-270 unchanged.

- [X] **Speed Consistency:** Movement speed calculation accurate. Formula `moveSpeed * slowFactor * deltaTime` preserved. Verified by code review and slow/fast bug testing.

- [X] **Grid Position Sync:** `Bug.gridPosition` stays synchronized with `Bug.position`. Verified by unit test: `XCTAssertEqual(bug.gridPosition, expectedGridPos)` after waypoint snap.

- [X] **Edge Cases Handled:** All edge cases pass unit tests:
  - Bugs starting at spawn (first waypoint)
  - Bugs reaching house (last waypoint, guard returns early)
  - Very slow bugs (slowFactor = 0.1) move correctly
  - Very fast bugs (wasp, wave 50) don't skip waypoints
  - Distance < 2.0 triggers exact snap

- [X] **All Maps Work:** Fix works correctly across representative maps (1, 8, 9, 15) without special-casing. Verified by manual testing.

- [X] **Performance:** No significant performance degradation. 60 FPS maintained with 50 bugs. Only basic math operations (O(1) complexity). Verified by gameplay observation.

- [X] **Code Quality:**
  - Swift build completes without errors or warnings
  - All unit tests pass (new + existing)
  - Code follows Swift conventions and project patterns
  - Clear comments explain vector normalization approach
  - No dead code or commented-out sections

## Impact Analysis

- **Directly impacted:**
  - `Sources/BugDefense/Bug.swift:292-315` (modified) - Movement calculation replaced with vector-based algorithm
  - `Tests/BugDefenseTests/BugDefenseTests.swift` (modified) - New test function added (~80 lines after line 185)

- **Indirectly impacted:**
  - `Sources/BugDefense/GameScene.swift` - Calls Bug.update(), sees improved movement (no code changes)
  - `Sources/BugDefense/MapConfiguration.swift` - Road paths now followed precisely (no code changes)
  - All 20 map layouts - Bugs now stay on paths correctly (no code changes)
  - Future TASK2 (Unit Tests) - Depends on this fix being complete
  - Future TASK3 (Manual Testing) - Validates this implementation works visually
  - Future TASKΩ (Verification) - Final validation of all acceptance criteria

- **No impact:**
  - Flying bugs use same update method but unaffected (burrowing section preserved)
  - Tower, trap, house mechanics unchanged
  - Wave spawning, pathfinding grid, game state unchanged

## Follow-ups

- None identified

**Note:** All context has been extracted from AI_PROMPT.md, TASK.md, and PROMPT.md. All file paths, line numbers, patterns, and technical details are based on actual codebase analysis. The implementation is self-contained and executable by an autonomous agent without external clarification.


## PREVIOUS TASKS CONTEXT FILES AND RESEARCH: 
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/ANALYSIS.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/CONTEXT.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/RESEARCH.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/TODO.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/RESEARCH.md
- /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/RESEARCH.md

