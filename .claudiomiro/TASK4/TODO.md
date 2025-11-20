Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack and framework versions (Swift 5.x, SpriteKit, macOS/iOS)
- Project structure and architecture (20 map types, tier progression system)
- Coding conventions and patterns (console logging with emoji prefixes)
- Related code examples with file:line references
- Integration points and dependencies (TASK0-TASK3 implementations)
- Testing approach (manual gameplay testing, no automated test runner for this task)

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Build and Launch Game Application**
  - **What to do:**
    1. Clean any previous builds to ensure fresh start
    2. Build the project using Swift Package Manager
    3. Locate and launch the BugDefense.app bundle
    4. If app bundle is not found, provide instructions for running from Xcode
    5. Verify game launches without crashes
    6. Confirm console output is visible for validation testing

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Package.swift:1-30` — Swift Package Manager configuration
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefenseApp/App.swift` — Application entry point
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:285-289` — Build and run commands
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/PROMPT.md:44-60` — Build instructions

  - **Touched (will modify/create):**
    - No files modified (build-only task)

  - **Interfaces / Contracts:**
    - Application must launch successfully
    - Console output must be accessible for log verification

  - **Tests:**
    Type: Manual validation
    - Happy path: `swift build` completes successfully
    - Happy path: Application launches without errors
    - Edge case: If app bundle not found, fallback to Xcode instructions
    - Failure: Build errors → investigate compiler issues before proceeding

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Verify console logs are visible during gameplay
    - Confirm emoji-prefixed logs display correctly
    - Check for any startup errors or warnings

  - **Security & Permissions:**
    N/A - Local development build only

  - **Performance:**
    N/A - Standard build/launch performance

  - **Commands:**
    ```bash
    # Clean previous builds (optional but recommended)
    swift package clean

    # Build the project
    swift build

    # Locate app bundle (may be in different locations)
    find . -name "BugDefense.app" -type d 2>/dev/null

    # Launch the game (adjust path based on find results)
    open BugDefense.app
    # OR if not found:
    # Open in Xcode and run with Cmd+R
    ```

  - **Risks & Mitigations:**
    - **Risk:** App bundle location may vary based on build configuration
      **Mitigation:** Use find command to locate bundle, provide Xcode fallback instructions
    - **Risk:** macOS may block unsigned app from running
      **Mitigation:** Right-click → Open to bypass Gatekeeper, or build/run from Xcode

- [ ] **Item 2 — Validate Core Functionality (Tower Placement on Roads)**
  - **What to do:**
    1. Start game on default map (Map 1 - Winding Road)
    2. Identify road tiles visually (follow the path from spawn to house)
    3. Attempt to place a tower directly on a road tile
    4. Verify placement is rejected with red preview overlay
    5. Check console for expected message: "❌ Cannot place on road: GridPosition(x: X, y: Y)"
    6. Place tower on a non-road tile adjacent to road
    7. Verify placement succeeds with green preview and tower is placed
    8. Check console for success message: "✅ Can place at: GridPosition(x: X, y: Y)"
    9. Repeat test on 2 additional maps with different geometries:
       - Map 9 (Straight Shot) - simple linear path
       - Map 11 (Box Spiral) - complex geometric path
    10. Document any failures with specific map, position, and observed behavior

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift:866-896` — canPlaceStructure() implementation with road check at lines 880-884
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/MapConfiguration.swift:1-50` — Map type definitions and roadPath property
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:127-131` — AC1 acceptance criteria
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/TASK.md:49-55` — Tower placement test scenarios

  - **Touched (will modify/create):**
    - No files modified (validation-only task)
    - May create test notes/log file if validation issues found

  - **Interfaces / Contracts:**
    - `canPlaceStructure(at: GridPosition) -> Bool` must return false for road positions
    - Console logs must match pattern: "❌ Cannot place on road: GridPosition(x: \(x), y: \(y))"
    - Visual preview must show red indicator for invalid placement

  - **Tests:**
    Type: Manual validation
    - Happy path: Tower placement on non-road tile succeeds
    - Core change: Tower placement on road tile rejected with red preview
    - Core change: Console shows "❌ Cannot place on road" message
    - Edge case: Test on Map 1 (winding), Map 9 (straight), Map 11 (spiral)
    - Failure: Tower can be placed on road → TASK0 incomplete or broken

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Monitor console for placement validation messages
    - Verify message format matches existing patterns (emoji prefix, GridPosition format)
    - Note: Multiple placement attempts will generate multiple console logs

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - `contains()` check on road path array (10-50 waypoints typical)
    - O(n) complexity acceptable for this use case
    - No noticeable performance impact expected

  - **Commands:**
    ```bash
    # No commands needed - interactive gameplay testing
    # Keep terminal visible to monitor console output
    # Test sequence:
    # 1. Move mouse/cursor over road tile
    # 2. Observe preview color (should be red)
    # 3. Click to attempt placement
    # 4. Verify tower is NOT placed
    # 5. Check console for error message
    ```

  - **Risks & Mitigations:**
    - **Risk:** Road path visualization may not be clear in game
      **Mitigation:** Reference MapConfiguration to know exact waypoints, or observe bug movement to identify path
    - **Risk:** TASK0 implementation may be incomplete
      **Mitigation:** If placement on road succeeds, verify GameScene.swift:880-884 has road check

- [ ] **Item 3 — Validate Bug Path Following (Ground and Flying Bugs)**
  - **What to do:**
    1. Start a wave to spawn bugs (ground bugs: ant, beetle)
    2. Observe bug movement from spawn point to house
    3. Verify bugs follow the visible road path without deviation
    4. Check console for spawn message: "🛣️ Road is clear! Using predefined road path for [bugType]"
    5. Verify console does NOT show: "🚧 Road is blocked! Using A* pathfinding"
    6. Progress to a wave that spawns flying bugs (mosquito or wasp)
    7. Observe flying bug movement
    8. Verify flying bugs follow road path (NOT direct line to house)
    9. Confirm smooth waypoint-to-waypoint movement with axis locking
    10. Test on multiple maps to ensure path following works across different geometries

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift:510-544` — spawnBug() function (should NOT use A* fallback after TASK1)
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/Bug.swift:254-316` — Bug movement logic with axis locking
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/Bug.swift:106-113` — canFly property definition
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:139-150` — AC3 and AC4 acceptance criteria
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/TASK.md:62-67` — Flying bug test scenarios

  - **Touched (will modify/create):**
    - No files modified (validation-only task)

  - **Interfaces / Contracts:**
    - `spawnBug()` must always assign roadPath to bugs (no conditional A* logic)
    - Bug.setPath() receives roadPath array from MapManager
    - Flying bugs use same path as ground bugs (canFly property unused for pathing)

  - **Tests:**
    Type: Manual validation
    - Happy path: Ground bug spawns and follows road to house
    - Core change: Console shows "🛣️ Road is clear!" message (not "🚧 Road is blocked!")
    - Core change: Flying bugs follow road path (not direct line)
    - Edge case: Bugs maintain smooth movement with axis locking
    - Edge case: Test across maps with different path geometries
    - Failure: Bug deviates from road → TASK1 incomplete or A* fallback still active

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Monitor console for bug spawn messages
    - Verify "🛣️ Road is clear!" appears (not "🚧 Road is blocked!")
    - Visual observation of bug movement along road path
    - Note: Smooth movement should match existing behavior (no changes to Bug.swift)

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Bug movement should maintain existing smoothness
    - No performance degradation expected (removing A* actually improves performance)

  - **Commands:**
    ```bash
    # No commands needed - interactive gameplay testing
    # Test sequence:
    # 1. Click "Start Wave" to spawn bugs
    # 2. Observe bug movement visually
    # 3. Watch console for spawn messages
    # 4. Progress through waves to spawn different bug types
    # 5. Specifically test mosquito and wasp (flying types)
    ```

  - **Risks & Mitigations:**
    - **Risk:** TASK1 may not be complete (A* fallback still present)
      **Mitigation:** If console shows "🚧 Road is blocked!", verify GameScene.swift:522-528 has been removed/simplified
    - **Risk:** Flying bugs may have special behavior code elsewhere
      **Mitigation:** Check Bug.swift for any canFly conditionals in movement logic

- [ ] **Item 4 — Validate Map Transitions (Tier Progression)**
  - **What to do:**
    1. Progress through waves 1-9 on initial map
    2. Complete wave 10 to trigger map transition (tier progression)
    3. Observe new map loads with different road path
    4. Immediately attempt to place tower on new map's road
    5. Verify placement is rejected (road protection carries over)
    6. If bugs are alive during transition, observe path recalculation
    7. Verify recalculated paths follow new map's road (not A* fallback)
    8. Check console for recalculation messages: "🛣️ [Recalc] Road is clear!"
    9. Verify console does NOT show: "🚧 [Recalc] Road is blocked!"
    10. Confirm towers placed before map change remain (not removed)

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift:1062-1087` — recalculateBugPaths() function (should NOT use A* fallback after TASK2)
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/TierProgressionSystem.swift` — Map change logic every 10 waves
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:149-151` — AC5 acceptance criteria
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:154-157` — EC1 edge case
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/TASK.md:69-76` — Map transition test scenarios

  - **Touched (will modify/create):**
    - No files modified (validation-only task)

  - **Interfaces / Contracts:**
    - `recalculateBugPaths()` must always assign roadPath (no conditional A* logic)
    - Map transition preserves road protection for new map
    - Existing structures remain after map change (handled by resetAllTowers)

  - **Tests:**
    Type: Manual validation
    - Happy path: Map changes at wave 10, new road is protected
    - Core change: Console shows "🛣️ [Recalc] Road is clear!" (not blocked message)
    - Core change: Bugs recalculate to new road path if alive during transition
    - Edge case: Towers placed before transition remain
    - Edge case: New map's unique path geometry is protected
    - Failure: Road blocking message appears → TASK2 incomplete or A* still active

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Monitor console during wave 10 completion
    - Watch for tier progression messages
    - Verify recalculation messages show road path usage
    - Visual confirmation: new map loads, bugs follow new path

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    - Path recalculation should be instantaneous (array assignment)
    - No performance impact from removing A* overhead

  - **Commands:**
    ```bash
    # No commands needed - interactive gameplay testing
    # Test sequence:
    # 1. Complete waves 1-9
    # 2. Observe wave 10 completion → map change
    # 3. Watch console for recalculation messages
    # 4. Test tower placement on new map's road
    # 5. Observe bug behavior if any are alive
    ```

  - **Risks & Mitigations:**
    - **Risk:** TASK2 may not be complete (A* fallback in recalculateBugPaths)
      **Mitigation:** If blocked message appears, verify GameScene.swift:1070-1076 has been removed/simplified
    - **Risk:** Map progression may take significant time to reach wave 10
      **Mitigation:** Use admin mode or modify wave progression for faster testing if available

- [ ] **Item 5 — Validate Edge Cases and Code Quality**
  - **What to do:**
    1. Test house position protection (existing functionality):
       - Attempt to place tower on house tile → should fail with "❌ Cannot place on house"
    2. Test out-of-bounds placement (existing functionality):
       - Attempt to place tower outside grid → should fail with "❌ Out of bounds"
    3. Test existing structure collision (existing functionality):
       - Place tower at position A
       - Attempt to place another tower at position A → should fail with "❌ Structure already exists"
    4. Test road adjacency:
       - Place towers in all 4 cardinal directions adjacent to road (not on it) → all should succeed
    5. Spot-check additional map types (quick validation):
       - Test tower placement rejection on Maps 5, 10, 15, 20
       - Confirm diverse path geometries are all protected
    6. Code inspection (verify TASK3 cleanup):
       - Open GameScene.swift and search for "isRoadPathBlocked"
       - Verify function is either removed or marked as deprecated/unused
       - Confirm no A* fallback code exists in spawnBug or recalculateBugPaths
    7. Console logging verification:
       - Review all console messages collected during testing
       - Verify emoji prefixes used consistently (❌ for errors, ✅ for success, 🛣️ for road usage)
       - Confirm no unexpected errors or warnings

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift:866-896` — canPlaceStructure() with all validation checks
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift:1049-1060` — isRoadPathBlocked() function (should be unused after TASK3)
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:152-169` — EC1-EC4 and CQ1-CQ3 acceptance criteria
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/TASK.md:78-94` — Edge case test scenarios

  - **Touched (will modify/create):**
    - No files modified (validation-only task)

  - **Interfaces / Contracts:**
    - All existing validation checks must remain functional
    - Validation order: bounds → house → road → existing structures
    - Console messages must follow established emoji prefix patterns

  - **Tests:**
    Type: Manual validation
    - Edge case: House position protection preserved
    - Edge case: Out-of-bounds rejection preserved
    - Edge case: Existing structure collision preserved
    - Edge case: Road adjacency placement succeeds
    - Edge case: All 5 spot-check maps enforce road protection (Maps 1, 5, 10, 15, 20)
    - Code quality: isRoadPathBlocked() unused or removed (TASK3)
    - Code quality: No A* fallback code in spawnBug or recalculateBugPaths
    - Code quality: Console logs consistent with established patterns

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Comprehensive console log review
    - Verify no error messages during normal gameplay
    - Confirm all placement validation messages clear and consistent

  - **Security & Permissions:**
    N/A - No security concerns

  - **Performance:**
    N/A - Validation checks minimal overhead

  - **Commands:**
    ```bash
    # Code inspection commands (run in terminal while game is open)
    # Search for A* fallback code
    grep -n "isRoadPathBlocked" /Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift

    # Should show:
    # - Line 1049: function definition (may be present but unused)
    # - Lines 522, 1070: should NOT exist (if TASK1/TASK2 complete)

    # If lines 522 or 1070 still exist, TASK1/TASK2 are incomplete
    # If only line 1049 exists, function is unused (TASK3 may mark as deprecated)
    # If no lines found, function has been removed (TASK3 complete)

    # Interactive testing: follow test sequence above
    ```

  - **Risks & Mitigations:**
    - **Risk:** Previous tasks (TASK0-TASK3) may be partially incomplete
      **Mitigation:** Code inspection will reveal if A* fallback still exists; document specific issues
    - **Risk:** Console message patterns may vary across different game states
      **Mitigation:** Test multiple scenarios to ensure consistency

## Verification (global)

- [ ] Run targeted code inspection to verify TASK0-TASK3 completion:
      ```bash
      # Check road placement validation implementation
      grep -A 5 "Cannot place on road" /Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift

      # Check for A* fallback code (should be removed)
      grep -n "isRoadPathBlocked" /Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/GameScene.swift

      # Expected results:
      # 1. Road placement check exists in canPlaceStructure (lines 880-884)
      # 2. isRoadPathBlocked either removed or only definition exists (not called)
      ```

- [ ] All acceptance criteria met (see below)
- [ ] Code follows conventions from AI_PROMPT.md and PROMPT.md
  - Console logs use emoji prefixes (❌, ✅, 🛣️)
  - GridPosition format in messages: "GridPosition(x: X, y: Y)"
  - No breaking changes to existing systems
- [ ] Integration points properly implemented (all TASK0-TASK3 changes functional)
- [ ] Performance targets met (no noticeable gameplay impact from validation checks)
- [ ] Security requirements satisfied (N/A for this task)

## Acceptance Criteria

**Primary Requirements (AC1-AC5):**

- [ ] **AC1:** Players cannot place towers on any road tile
  - Tested on Map 1 (Winding Road) - complex path
  - Tested on Map 9 (Straight Shot) - simple linear path
  - Tested on Map 11 (Box Spiral) - geometric complexity
  - Console message: "❌ Cannot place on road: GridPosition(...)" appears
  - Visual feedback: Red preview overlay when hovering over road

- [ ] **AC2:** Placement preview shows visual feedback for invalid road placement
  - Preview turns red when hovering over road tiles
  - Verified in mouseMoved() (macOS) and/or touchesMoved() (iOS) handlers
  - Consistent with existing invalid placement behavior

- [ ] **AC3:** Remove A* pathfinding fallback for all bugs
  - `spawnBug()` no longer checks `isRoadPathBlocked()`
  - All bugs receive `roadPath` directly without conditional logic
  - A* path assignment code block removed or commented out (GameScene.swift:522-528)
  - Console shows "🛣️ Road is clear!" message (NOT "🚧 Road is blocked!")

- [ ] **AC4:** Flying bugs follow road paths
  - Mosquito bugs use same road path as ground bugs
  - Wasp bugs use same road path as ground bugs
  - No special flying behavior active (canFly property unused for pathing)
  - Verified by spawning and observing mosquito/wasp movement

- [ ] **AC5:** Path recalculation logic simplified
  - `recalculateBugPaths()` removes road blocking check (GameScene.swift:1062-1087)
  - All bugs always receive `roadPath` on recalculation
  - Function still called during map changes (tier transitions)
  - Console shows "🛣️ [Recalc] Road is clear!" (NOT blocked message)

**Edge Cases (EC1-EC4):**

- [ ] **EC1:** Map transitions preserve road protection
  - When map changes (every 10 waves), new map's road path is protected
  - Towers placed before map change are not removed (verified to remain)
  - Tested by completing wave 10 and observing map transition

- [ ] **EC2:** House position remains protected
  - Existing house position check in place (GameScene.swift:875-878)
  - House placement rejection message: "❌ Cannot place on house: GridPosition(...)"
  - Both house check and road check function independently

- [ ] **EC3:** Out-of-bounds placement still rejected
  - Bounds checking happens before road checking (GameScene.swift:868-872)
  - Validation order preserved: bounds → house → road → existing structures
  - Out-of-bounds message: "❌ Out of bounds: GridPosition(...)"

- [ ] **EC4:** All 20 maps enforce road protection
  - Spot-checked Maps 1, 5, 10, 15, 20 (diverse sample)
  - Each map's unique path geometry correctly protected
  - Road placement rejection consistent across all tested maps

**Code Quality (CQ1-CQ3):**

- [ ] **CQ1:** Console logging consistency
  - Uses existing print patterns: "❌" for failures, "✅" for success
  - Matches verbosity of existing placement logs
  - All messages follow GridPosition format: "GridPosition(x: X, y: Y)"

- [ ] **CQ2:** No breaking changes to existing systems
  - Bug movement logic (Bug.swift:254-316) unchanged and functional
  - Tower attack behavior unaffected
  - Map path definitions remain identical
  - All existing gameplay systems work as before

- [ ] **CQ3:** Dead code removed or deprecated
  - `isRoadPathBlocked()` no longer called in spawnBug or recalculateBugPaths
  - Function either removed or marked as deprecated (TASK3 responsibility)
  - All orphaned A* path assignment logic cleaned up

## Impact Analysis

**Directly impacted:**
- No files directly modified by this task (validation-only)
- Validates implementations from:
  - `Sources/BugDefense/GameScene.swift` (canPlaceStructure, spawnBug, recalculateBugPaths)
  - All 20 map types in `Sources/BugDefense/MapConfiguration.swift`

**Indirectly impacted:**
- Player experience: more predictable bug paths, clearer strategic choices
- Game difficulty: slightly easier (can't accidentally block paths)
- Code maintainability: simpler logic after removing A* fallback
- Future development: establishes road-only movement as core mechanic

**Testing validation confirms:**
- TASK0: Tower placement validation on roads ✓
- TASK1: Bug spawn path assignment without A* ✓
- TASK2: Path recalculation simplified ✓
- TASK3: Dead code cleanup ✓

**Dependencies verified:**
- All previous tasks (TASK0-TASK3) must be complete before this validation
- This task blocks TASKΩ (final integration/documentation)

## Follow-ups

**If all acceptance criteria pass:**
- Mark first line as "Fully implemented: YES"
- No follow-up actions needed
- Feature is complete and validated

**If any acceptance criteria fail:**
- Document specific failures with:
  - Which criterion failed (AC1-AC5, EC1-EC4, or CQ1-CQ3)
  - Observed behavior vs. expected behavior
  - Map type and scenario where failure occurred
  - Console messages captured
  - Suspected incomplete task (TASK0, TASK1, TASK2, or TASK3)
- Return to incomplete task for fixes before re-validating
- Do NOT mark as "Fully implemented: YES" until all criteria pass

**Ambiguities identified:**
- None - all requirements clearly defined in AI_PROMPT.md and TASK.md
- Testing approach is manual gameplay validation (no automated tests for this task)
- Success/failure criteria are measurable and observable
