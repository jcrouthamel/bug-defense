Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack (Swift 5.x + SpriteKit, macOS/iOS tower defense game)
- Project structure (Sources/BugDefense/, 20x15 grid, 40pt tiles)
- Map system (20 maps: map1-map20 with different path geometries)
- Bug types (ant, beetle, spider, mosquito, wasp with different speeds)
- Wave mechanics (wave scaling affects bug speed)
- Movement fix from TASK1 (vector normalization in Bug.swift:254-316)

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Build and Launch Game**
  - **What to do:**
    1. Build the game using Swift Package Manager: `swift build` in project root
    2. Verify build succeeds with no compilation errors (TASK1 changes should be included)
    3. Launch the game executable: `swift run` or `open BugDefense.app` (if app bundle exists)
    4. Verify game starts successfully and UI is functional
    5. Familiarize yourself with game controls:
       - Map selection UI
       - Wave start button
       - Tower placement (if needed to create slow traps)
       - Pause/resume controls

  - **Context (read-only):**
    - `Sources/BugDefense/GameScene.swift:488-504` — Bug spawning logic with road path assignment
    - `Sources/BugDefense/Bug.swift:254-316` — Movement update logic (TASK1 fix)
    - `Sources/BugDefense/MapConfiguration.swift:6-25` — Map definitions (map1-map20)
    - `Package.swift:1-30` — Build configuration (Swift Package Manager)

  - **Touched (will modify/create):**
    - CREATE: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md`
    - NO CODE CHANGES (observation task only)

  - **Interfaces / Contracts:**
    N/A - No code interfaces, this is manual testing only

  - **Tests:**
    Type: Manual visual testing (human observation)
    - Build success: Game compiles without errors
    - Launch success: Game starts and UI is responsive
    - Controls functional: Can select maps and start waves

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Observe console logs during game execution (bug spawning messages from GameScene.swift:496-503)
    - Watch for any runtime errors or warnings in console
    - Note any visual glitches or anomalies during gameplay

  - **Security & Permissions:**
    N/A - Local game execution only

  - **Performance:**
    - Game should run smoothly at 60 FPS (SpriteKit default)
    - No lag or stuttering during bug movement
    - Performance should match pre-fix baseline (TASK1 changes should not degrade performance)

  - **Commands:**
    ```bash
    # Build the game
    cd /Users/jrc/Code/bug-defense/bug-defense-main
    swift build

    # Run the game (choose one method)
    swift run
    # OR
    open BugDefense.app
    # OR (if using Xcode)
    open BugDefenseIOS.xcodeproj
    # Then press Cmd+R to run
    ```

  - **Risks & Mitigations:**
    - **Risk:** Build fails due to TASK1 changes
      **Mitigation:** Review TASK1 changes in Bug.swift, ensure syntax is correct, check for missing imports
    - **Risk:** Game doesn't launch (app bundle missing)
      **Mitigation:** Use `swift run` instead, or rebuild app bundle with Xcode


- [ ] **Item 2 — Test Map 1 (Winding Road) with Normal, Slow, and Fast Bugs**
  - **What to do:**
    1. Select Map 1 (Winding Road) from the map selection UI
    2. Start wave 1 (spawns normal speed ants)
    3. **Observe closely:** Watch bugs move along the winding path from spawn to house
    4. **Verify visual alignment:** Bug sprites should remain centered on brown dirt road tiles at all times
    5. **Verify curve handling:** On curved sections, bugs should follow the path tile-by-tile (not cut diagonally across curves)
    6. **Verify smooth movement:** Movement should be continuous and smooth, not jerky or teleporting
    7. **Test slow bugs:** Advance to a wave with beetles OR place slow traps near the path to slow bugs down
    8. **Observe slow movement:** Even at slow speed, bugs should stay on path with no jittering or position correction artifacts
    9. **Test fast bugs:** Advance to wave 10+ (wave scaling increases speed) OR test with spider/wasp bug types
    10. **Observe fast movement:** Fast bugs should not skip tiles, cut corners, or drift off path despite high speed
    11. **Document findings:** In MANUAL_TEST_REPORT.md, record PASS/FAIL for each scenario with specific observations

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:44-45` — Map 1 path definition (winding road)
    - `Sources/BugDefense/Bug.swift:254-316` — Movement logic being tested
    - `Sources/BugDefense/GameState.swift` — Wave progression and difficulty scaling
    - `.claudiomiro/AI_PROMPT.md` Section 4 — Edge cases (slow bugs, fast bugs, curves)

  - **Touched (will modify/create):**
    - MODIFY: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md` — Add Map 1 test results

  - **Interfaces / Contracts:**
    Visual contract: Bugs MUST remain on brown dirt road tiles at all times (per AI_PROMPT.md Section 4)

  - **Tests:**
    Type: Manual visual observation tests
    - Normal speed (ants, wave 1-5): Bugs stay on path during winding curves
    - Slow speed (beetles or trapped bugs): No jittering, smooth slow movement on path
    - Fast speed (spiders, wave 10+): No tile skipping, no corner cutting, no drift
    - Curve handling: Bugs follow tiles sequentially, not cutting diagonally
    - Visual quality: Smooth continuous movement, no teleporting

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Watch bugs visually as they traverse the map
    - Note any visual drift (bug sprite appearing off brown road tiles)
    - Note any jerky movement or position snapping
    - Check console logs for any error messages during movement

  - **Security & Permissions:**
    N/A - Manual testing only

  - **Performance:**
    - Observe frame rate during bug movement (should be 60 FPS)
    - Multiple bugs on screen should not cause lag
    - Fast bugs should maintain smooth movement at high speed

  - **Commands:**
    ```bash
    # Game should already be running from Item 1
    # If not, restart with:
    swift run
    # OR
    open BugDefense.app
    ```

  - **Risks & Mitigations:**
    - **Risk:** Visual drift observed on curves (TASK1 fix not working)
      **Mitigation:** Document exact scenario (location on map, bug type, speed) in MANUAL_TEST_REPORT.md - DO NOT attempt to fix, report findings only
    - **Risk:** Bugs skip waypoints at high speed
      **Mitigation:** Document scenario - this would indicate TASK1 fix needs revision


- [ ] **Item 3 — Test Map 8 (U-Turns), Map 9 (Straight Shot), and Map 15 (Diagonal)**
  - **What to do:**
    1. **Map 8 (U-Turns) - Sharp direction changes:**
       - Select Map 8 from map selection UI
       - Start waves and observe bugs making 180-degree U-turns
       - **Verify:** Bugs reach the corner tile exactly before turning (no overshoot)
       - **Verify:** Bugs don't cut corners or drift during sharp turns
       - **Verify:** Movement through U-turn is smooth and precise

    2. **Map 9 (Straight Shot) - Baseline test:**
       - Select Map 9 from map selection UI
       - Start waves and observe simple straight-line movement (horizontal/vertical)
       - **Verify:** Bugs move in perfectly straight lines along path
       - **Verify:** Position locks to path axis (X or Y constant during horizontal/vertical segments)
       - **Baseline confirmation:** Simple paths work correctly (this validates basic movement)

    3. **Map 15 (Diagonal) - Diagonal path segments:**
       - Select Map 15 from map selection UI
       - Start waves and observe bugs moving diagonally across the grid
       - **Verify:** Diagonal movement stays on diagonal path tiles
       - **Verify:** Bugs move through each diagonal tile sequentially (e.g., (2,2) → (3,3) → (4,4))
       - **Verify:** No drift toward orthogonal directions (horizontal/vertical)

    4. **Document findings:** Record PASS/FAIL for each map with specific observations in MANUAL_TEST_REPORT.md

  - **Context (read-only):**
    - `Sources/BugDefense/MapConfiguration.swift:51-52` — Map 8 (U-Turns) path
    - `Sources/BugDefense/MapConfiguration.swift:52-53` — Map 9 (Straight Shot) path
    - `Sources/BugDefense/MapConfiguration.swift:58-59` — Map 15 (Diagonal) path
    - `Sources/BugDefense/Bug.swift:292-314` — Movement calculation logic for diagonal vs orthogonal
    - `.claudiomiro/AI_PROMPT.md` Section 5.1 — Testing guidance for different map types

  - **Touched (will modify/create):**
    - MODIFY: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md` — Add Map 8, 9, 15 test results

  - **Interfaces / Contracts:**
    Visual contract: Bugs follow path precisely for all path geometries (curves, straight, diagonal, U-turns)

  - **Tests:**
    Type: Manual visual observation tests
    - Map 8 U-turns: Bugs handle 180-degree turns without overshoot or drift
    - Map 9 straight lines: Perfect horizontal/vertical alignment (baseline)
    - Map 15 diagonals: Diagonal movement stays on diagonal path tiles
    - All maps: Smooth movement, no teleporting, bugs reach house correctly

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Watch bugs at critical points: U-turn corners (Map 8), straight segments (Map 9), diagonal segments (Map 15)
    - Note any visual anomalies specific to path geometry
    - Compare behavior across different map types to ensure consistency

  - **Security & Permissions:**
    N/A - Manual testing only

  - **Performance:**
    - All map types should perform equally well (no geometry-specific lag)
    - Diagonal movement should not be slower than orthogonal movement

  - **Commands:**
    ```bash
    # Game should already be running from previous items
    # Use in-game UI to switch between maps
    # If game needs restart:
    swift run
    # OR
    open BugDefense.app
    ```

  - **Risks & Mitigations:**
    - **Risk:** Different path geometries show different drift patterns
      **Mitigation:** Document specific issues per map type - this helps identify if the fix is geometry-dependent
    - **Risk:** Diagonal movement shows drift (different from orthogonal)
      **Mitigation:** Document diagonal-specific issues - TASK1 fix may need diagonal-specific adjustments


- [ ] **Item 4 — Regression Testing: Flying Bugs and Burrowing Bugs**
  - **What to do:**
    1. **Test flying bugs (mosquito, wasp):**
       - Identify waves that spawn mosquitos or wasps (check wave definitions or advance waves)
       - Observe flying bug behavior
       - **Verify:** Flying bugs still follow the road path correctly (they use the same road path system per GameScene.swift:494-500)
       - **Verify:** Flying bug movement is unchanged from pre-fix behavior
       - **Verify:** No visual anomalies introduced by TASK1 changes

    2. **Test burrowing bugs (if applicable):**
       - Identify waves that spawn burrowing bugs (check BugType definitions for canBurrow property)
       - Observe burrowing behavior
       - **Verify:** Burrowing bugs still burrow and surface correctly (burrow logic is in Bug.swift:258-270, should be untouched)
       - **Verify:** Underground/surface transitions work correctly
       - **Verify:** Movement respects burrowing mechanics

    3. **Document findings:** Record PASS/FAIL/N/A for flying and burrowing bugs in MANUAL_TEST_REPORT.md

  - **Context (read-only):**
    - `Sources/BugDefense/Bug.swift:258-270` — Burrowing behavior logic (should be untouched by TASK1)
    - `Sources/BugDefense/GameScene.swift:494-500` — All bugs (including flying) use road path
    - `Sources/BugDefense/Bug.swift:254-316` — Movement update (ensure TASK1 changes don't affect special bug types)
    - `.claudiomiro/AI_PROMPT.md` Section 4 — "No Regression: Flying bugs (mosquito, wasp) are unaffected. Burrowing bugs maintain their special mechanics."

  - **Touched (will modify/create):**
    - MODIFY: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md` — Add regression test results

  - **Interfaces / Contracts:**
    Regression contract: Special bug behaviors (flying, burrowing) must remain unchanged by TASK1 fix

  - **Tests:**
    Type: Manual regression testing
    - Flying bugs (mosquito, wasp): Follow path correctly, movement unchanged from baseline
    - Burrowing bugs: Burrow/surface transitions work, movement respects burrowing state
    - No new bugs introduced: Flying and burrowing bugs function as expected

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    - Watch for any new visual glitches or behavior changes in flying bugs
    - Check that burrowing state (underground vs surface) is visually clear
    - Console logs should not show errors related to special bug types

  - **Security & Permissions:**
    N/A - Manual testing only

  - **Performance:**
    - Flying and burrowing bugs should perform the same as before TASK1 fix
    - No performance regression for special bug types

  - **Commands:**
    ```bash
    # Game should already be running
    # Advance waves to find flying bugs (mosquito, wasp)
    # Check BugType definitions if unsure which waves spawn which bugs
    # If needed, restart game:
    swift run
    # OR
    open BugDefense.app
    ```

  - **Risks & Mitigations:**
    - **Risk:** TASK1 changes inadvertently affect flying bug movement
      **Mitigation:** Document specific issues - TASK1 fix should only affect ground bug movement calculation (Bug.swift:276-315), not flying bug logic
    - **Risk:** Burrowing bugs show movement anomalies
      **Mitigation:** Document issues - burrowing logic (lines 258-270) should be completely separate from movement calculation


- [ ] **Item 5 — Create Comprehensive Manual Test Report**
  - **What to do:**
    1. Compile all observations from Items 1-4 into a structured test report
    2. Use the template from PROMPT.md (lines 100-138) as a guide
    3. **Include in report:**
       - Test environment details (build status, platform, date)
       - Maps tested with PASS/FAIL status and notes
       - Bug speed testing results (slow, normal, fast)
       - Regression testing results (flying, burrowing)
       - Visual quality observations (smoothness, path adherence, corner handling)
       - Overall assessment: PASS or FAIL with justification
       - Detailed description of any issues found (map, bug type, location, specific behavior)
       - Screenshots or additional evidence (optional but helpful)
    4. **Overall assessment criteria:**
       - PASS if: Bugs stay on path at all times across all tested scenarios, smooth movement, no visual drift
       - FAIL if: Any visual drift off brown road tiles, bugs cut corners, jerky movement, waypoint skipping
    5. Save report to `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md`

  - **Context (read-only):**
    - `.claudiomiro/TASK3/PROMPT.md:100-138` — Test report template
    - `.claudiomiro/AI_PROMPT.md` Section 9 — Success definition: "bugs follow the brown dirt road tiles precisely, like a train on tracks"
    - `.claudiomiro/TASK3/TASK.md:123-136` — Acceptance criteria checklist

  - **Touched (will modify/create):**
    - CREATE/MODIFY: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md` — Final comprehensive report

  - **Interfaces / Contracts:**
    Report contract: Must provide clear PASS/FAIL assessment with sufficient detail to validate TASK1 fix

  - **Tests:**
    Type: Test report synthesis
    - All required sections included in report
    - Clear PASS/FAIL status for each tested scenario
    - Overall assessment is justified by observations
    - Any issues are described with specific details (reproducible)

  - **Migrations / Data:**
    N/A - Documentation only

  - **Observability:**
    - Report should serve as evidence of TASK1 fix validation
    - Document serves as traceability artifact for TASKΩ (final verification)

  - **Security & Permissions:**
    N/A - Documentation only

  - **Performance:**
    N/A - Documentation only

  - **Commands:**
    ```bash
    # Create/edit the report (use any text editor)
    # Recommended structure from PROMPT.md template:
    # 1. Test Environment
    # 2. Maps Tested (Map 1, 8, 9, 15 minimum)
    # 3. Bug Speed Testing
    # 4. Regression Testing
    # 5. Visual Quality Observations
    # 6. Overall Assessment
    # 7. Issues Found (if any)
    # 8. Screenshots/Evidence (optional)
    ```

  - **Risks & Mitigations:**
    - **Risk:** Report is incomplete or lacks critical details
      **Mitigation:** Use template from PROMPT.md, ensure all sections filled, cross-check against acceptance criteria
    - **Risk:** Overall assessment (PASS/FAIL) is ambiguous
      **Mitigation:** Be explicit - PASS means "bugs stay on path at all times", FAIL means "visual drift observed"

## Verification (global)
- [ ] Game builds and runs successfully (no compilation or runtime errors)
- [ ] Minimum 4 maps tested: Map 1 (Winding Road), Map 8 (U-Turns), Map 9 (Straight Shot), Map 15 (Diagonal)
- [ ] Bug speed variations tested: Slow (beetles or trapped), Normal (ants), Fast (spiders/wasps or high waves)
- [ ] Regression testing completed: Flying bugs (mosquito/wasp) and burrowing bugs (if applicable)
- [ ] Manual test report created with all required sections
- [ ] Overall PASS/FAIL assessment is clear and justified
- [ ] All acceptance criteria met (see below)
- [ ] No code changes made (observation task only - critical constraint)

## Acceptance Criteria
From TASK.md, all items must be satisfied:
- [ ] **Game builds and runs**: No compilation or runtime errors
- [ ] **Map 1 tested**: Winding path works with normal, slow, and fast bugs - verified visually
- [ ] **Map 8 tested**: U-turns handled correctly without drift - verified visually
- [ ] **Map 9 tested**: Straight paths work correctly (baseline) - verified visually
- [ ] **Map 15 tested**: Diagonal paths work correctly - verified visually
- [ ] **Slow bugs verified**: Beetles or slowed bugs stay on path at all speeds
- [ ] **Fast bugs verified**: High-speed bugs don't skip waypoints or drift off path
- [ ] **Visual quality**: Movement is smooth, no teleporting or jerkiness observed
- [ ] **No drift observed**: Bugs remain on brown road tiles at all times across all tested maps
- [ ] **Flying bugs unchanged**: Mosquitos/wasps still fly correctly (regression test PASS)
- [ ] **Burrowing unchanged**: Burrowing mechanics still work (if applicable, regression test PASS)
- [ ] **Test report created**: Document which scenarios were tested and results (MANUAL_TEST_REPORT.md exists and is complete)

## Impact Analysis
- **Directly impacted:**
  - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md` (created)
  - This task validates TASK1 implementation (Bug.swift:254-316 movement logic)

- **Indirectly impacted:**
  - TASKΩ (Final Verification) depends on this manual testing validation
  - TASK1 implementation may need revision if this testing reveals issues
  - Future gameplay quality depends on confirming the fix works visually

## Follow-ups
- If visual drift is observed during testing, document specific scenarios in MANUAL_TEST_REPORT.md and report findings (DO NOT attempt to fix code in this task)
- If bugs are found in flying or burrowing behavior, these are regression issues that should be escalated
- If game doesn't build or launch, this blocks testing and may require TASK1 review
