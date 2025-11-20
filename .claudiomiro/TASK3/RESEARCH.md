# Research for TASK3: Manual Visual Testing Across Multiple Maps

## Context Reference
**For tech stack and conventions, see:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack: Swift 5.x + SpriteKit, 20x15 grid, 40pt tiles, map system, bug types, wave mechanics)
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/TASK.md` - Task-level context (manual testing requirements)
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/PROMPT.md` - Task-specific context (test report template, scenarios)

**This file contains ONLY new information discovered during research.**

---

## Task Understanding Summary
Build and run the game to visually verify that bugs follow the brown dirt road tiles precisely without drift, across representative maps with different path geometries and bug speeds. Reference TODO.md for full implementation checklist.

---

## Files Discovered to Read/Modify
**NEW discoveries (not in PROMPT.md):**
- `Sources/BugDefenseApp/App.swift:1-118` - App launcher with platform-specific code (macOS NSWindow, iOS SwiftUI)
- `BugDefense.app/Contents/MacOS/BugDefenseApp` - Pre-built executable (Mach-O 64-bit ARM64)
- `.build/arm64-apple-macosx/debug/BugDefenseApp` - Debug build executable
- `Package.swift:1-30` - Swift Package Manager configuration (confirms build setup)
- `Sources/BugDefense/WaveManager.swift:99-102` - Flying/burrowing bug spawn conditions discovered:
  - Mosquitos unlock at wave 10+ (10-25% spawn rate)
  - Wasps unlock at wave 15+ (5-25% spawn rate)
  - Burrowers unlock at wave 18+ (8-20% spawn rate)
- `Sources/BugDefense/Bug.swift:115-122` - `canBurrow` property (only .burrower returns true)

---

## Code Patterns Found
**NEW patterns discovered:**

### Console Logging Pattern - `Sources/BugDefense/GameScene.swift`
- **Lines 63, 66, 92, 313, 328, 395, 446, 496, 499, 503** - Emoji-prefixed print statements for debugging
- Pattern: `print("🎮 Context: \(data)")` for visual parsing of console output
- Relevant emojis: 🎮 (game), 🗺️ (map), 🌊 (wave), 📍 (position), 🛣️ (path), ✅ (success), 💥 (events)
- **Usage for testing**: Watch console during manual testing for:
  - `🛣️ Using predefined road path for [bugType] with [count] waypoints` - confirms path assignment
  - `✅ Bug spawned: [bugType] at position [gridPos]` - confirms spawn location
  - `💥 Bug reached house!` - confirms path completion

### App Launch Pattern - `Sources/BugDefenseApp/App.swift`
- **Lines 14-62 (macOS)**: NSApplication-based launcher
  - Creates 800x600 window with SKView
  - Shows FPS and node count for debugging (line 32-33)
  - Console prints: `🚀 App launching...`, `✅ Window created`, `🎮 Bug Defense is ready!`
- **Lines 80-116 (iOS)**: SwiftUI-based launcher with UIViewRepresentable
  - Uses UIScreen.main.bounds for sizing
  - Also shows FPS and node count (line 107-108)
- **Discovery**: Both platforms show FPS/node count by default - useful for performance observation

### TASK1 Movement Fix Pattern - `Sources/BugDefense/Bug.swift:292-300`
```swift
// 🐛 Use normalized vector movement for all directions
// This ensures bugs move in a straight line toward the target waypoint,
// keeping them precisely on the path regardless of segment orientation.
// The direction vector (dx, dy) is normalized by dividing by distance,
// then scaled by moveDistance to maintain consistent speed.
let normalizedDx = dx / distance
let normalizedDy = dy / distance
position.x += normalizedDx * moveDistance
position.y += normalizedDy * moveDistance
```
- **Key insight**: TASK1 replaced axis-locking heuristics with pure vector normalization
- **What changed**: Removed 23 lines of segment-type detection (old lines 292-314), replaced with 8 lines
- **Testing implication**: Manual testing validates this geometric approach works visually

---

## Integration & Impact Analysis

### Functions/Classes/Components Being Modified:
**NONE** - This task is observation only. No code changes allowed per PROMPT.md:172.

### Manual Testing Integration Points:
1. **Build System** - `swift build` compiles to `.build/arm64-apple-macosx/debug/BugDefenseApp`
2. **Run Options Discovered**:
   - **Option A**: `swift run` (builds and runs from command line)
   - **Option B**: `open BugDefense.app` (uses pre-built app bundle if exists)
   - **Option C**: `open BugDefenseIOS.xcodeproj` (Xcode IDE for debugging)
   - **Option D**: Direct executable: `.build/arm64-apple-macosx/debug/BugDefenseApp`
3. **Console Output Integration** - Emoji-prefixed prints provide test observability
4. **Visual Integration** - FPS/node count overlay (enabled by default) helps detect performance issues

### Map Path Geometry Analysis (Integration Context):
- **Map 1 (Winding Road)**: 16 waypoints, orthogonal curves - `Sources/BugDefense/MapConfiguration.swift:118-137`
- **Map 8 (U-Turns)**: 32 waypoints, multiple 180° turns - lines 281-316
- **Map 15 (Diagonal)**: 9 waypoints, pure diagonal descent - lines 507-519
- **Key Discovery**: All paths already expanded to include intermediate tiles (via `expandPath()`, lines 71-103)
  - TASK1 fix leverages this by treating each waypoint as adjacent/diagonal tile
  - Testing confirms path expansion works correctly if bugs stay on tiles

### Wave/Bug Speed Integration:
- **Slow bugs**: Beetle base speed 30.0 pts/sec (`Sources/BugDefense/Bug.swift:31`)
- **Normal bugs**: Ant base speed 60.0 pts/sec (line 30)
- **Fast bugs**:
  - Spider base speed 100.0 pts/sec (line 32)
  - Wasp base speed 120.0 pts/sec (line 36)
- **Wave scaling**: Not explicitly found in research, but AI_PROMPT.md mentions wave scaling affects speed
- **Slow traps**: Can reduce speed further via `slowFactor` (Bug.swift:308-318)

### Flying/Burrowing Bug Regression Testing:
- **Flying bugs**: Mosquito (wave 10+), Wasp (wave 15+) - `Sources/BugDefense/WaveManager.swift:99-100`
  - Use same `update()` method as ground bugs (no special movement code path)
  - Regression test: Verify TASK1 changes don't break flying movement
- **Burrowing bugs**: Burrower (wave 18+) - line 102
  - Burrow logic: `Bug.swift:258-270` (TASK1 preserved this, no changes)
  - Regression test: Verify burrow/surface transitions still work

---

## Test Strategy Discovered

### Testing Framework
- **Framework**: XCTest (Swift's standard testing framework)
- **Test command**: `swift test` (from Package.swift configuration)
- **Config**: Implicit in Package.swift:26-28 (testTarget defined)

### Manual Testing Approach (Task-Specific)
- **No automated tests** - This task is visual verification only
- **Test execution**: Launch game, observe visually, document findings
- **Evidence collection**: Screenshots optional, written observations required

### Test Report Pattern (From PROMPT.md:100-138)
- Template structure:
  1. Test Environment (build status, platform, date)
  2. Maps Tested (with PASS/FAIL status)
  3. Bug Speed Testing (slow/normal/fast)
  4. Regression Testing (flying/burrowing)
  5. Visual Quality Observations
  6. Overall Assessment (PASS/FAIL)
  7. Issues Found (detailed descriptions)
  8. Screenshots/Evidence (optional)

### Success Criteria Pattern
- **PASS criteria**: "Bugs stay on path at all times" (AI_PROMPT.md:9)
  - Visual definition: Bug sprites remain on brown dirt road tiles
  - Movement quality: Smooth, continuous, no teleporting
  - Path adherence: No corner cutting, follows tiles sequentially
- **FAIL criteria**: Any visual drift observed off brown road tiles

---

## Risks & Challenges Identified

### Technical Risks

1. **Build Failure Risk**
   - **Description**: Game may not compile due to TASK1 changes or environment issues
   - **Likelihood**: Low (TASK1 marked "code review passed")
   - **Impact**: High (blocks all testing)
   - **Evidence**: `.claudiomiro/TASK1/CODE_REVIEW.md:44` confirms build succeeded
   - **Mitigation**: TASK1 already verified build success; if fails, report immediately
   - **Fallback**: Use pre-built `BugDefense.app` executable if fresh build fails

2. **App Launch Failure Risk**
   - **Description**: App may not launch on macOS (window issues, permissions, etc.)
   - **Likelihood**: Low (existing executable found)
   - **Impact**: High (blocks all testing)
   - **Evidence**: Pre-built `BugDefense.app/Contents/MacOS/BugDefenseApp` exists and is valid Mach-O binary
   - **Mitigation**: Try multiple launch methods (swift run, open app, direct executable)
   - **Fallback**: Use Xcode project if command-line launch fails

3. **Flying Bug Availability Risk**
   - **Description**: Flying bugs (mosquito, wasp) only spawn at wave 10+ and 15+
   - **Likelihood**: High (confirmed from WaveManager.swift:99-100)
   - **Impact**: Medium (delays regression testing)
   - **Evidence**: Mosquito spawn chance: 0% until wave 10, then 10-25%; Wasp: 0% until wave 15
   - **Mitigation**: Plan to advance waves or document N/A if time-constrained
   - **Fallback**: Note limitation in test report, focus on ground bug testing

4. **Burrowing Bug Availability Risk**
   - **Description**: Burrowing bugs only spawn at wave 18+
   - **Likelihood**: High (confirmed from WaveManager.swift:102)
   - **Impact**: Low (burrowing is secondary regression test)
   - **Evidence**: Burrower spawn chance: 0% until wave 18, then 8-20%
   - **Mitigation**: May need to advance many waves to observe burrowing behavior
   - **Fallback**: Document N/A if not encountered, reference TASK1 preservation of burrow code

5. **Visual Drift Detection Subjectivity**
   - **Description**: "Staying on path" is visual judgment, may be ambiguous for small drift
   - **Likelihood**: Medium (depends on sensitivity to visual error)
   - **Impact**: Medium (affects PASS/FAIL decision)
   - **Evidence**: AI_PROMPT.md:109 says "no part of bug sprite should appear significantly off-path"
   - **Mitigation**: Use strict interpretation: ANY visible drift = FAIL
   - **Fallback**: Document ambiguous cases with descriptions and suggest thresholds

### Complexity Assessment
- **Overall**: Low
- **Reasoning**:
  - No code changes required (observation only)
  - Build system already configured and tested
  - Pre-built executable available as backup
  - Test scope limited to 4 maps and 3 bug speeds
  - Success criteria clearly defined (visual path adherence)
- **Complex areas**: None - straightforward visual observation task

### Missing Information
- [ ] **Exact slow trap mechanics** for artificially slowing bugs
  - **Context**: TODO.md:99 mentions "place slow traps" to test slow bugs
  - **Impact**: May need to rely on naturally slow beetles instead
  - **Recommendation**: Test with beetles (naturally slow) if slow traps unclear

- [ ] **Wave speed scaling formula**
  - **Context**: AI_PROMPT.md mentions wave scaling affects speed, but formula not found
  - **Impact**: Cannot precisely predict fast bug speeds at high waves
  - **Recommendation**: Use wave 15+ and observe empirically; spider/wasp base speed already fast

---

## Execution Strategy Recommendation

**Based on research findings, execute in this order:**

### Step 1: Build Verification
- **Action**: Build the game with TASK1 changes
- **Command**: `swift build`
- **Expected output**: Clean build with no errors
- **Verification**: Check for `.build/arm64-apple-macosx/debug/BugDefenseApp` executable
- **Evidence**: TASK1 CODE_REVIEW.md:44 confirms previous build success
- **Fallback**: If build fails, try using existing `BugDefense.app` bundle
- **Time estimate**: 10-30 seconds

### Step 2: Launch and Initial Verification
- **Action**: Launch the game and verify basic functionality
- **Primary command**: `swift run` (builds if needed, then runs)
- **Alternative commands**:
  - `open BugDefense.app` (if app bundle exists)
  - `./.build/arm64-apple-macosx/debug/BugDefenseApp` (direct execution)
  - `open BugDefenseIOS.xcodeproj` (Xcode IDE debugging)
- **Observe console for**: `🚀 App launching...`, `✅ Window created`, `🎮 Bug Defense is ready!`
- **Visual checks**:
  - Window appears (800x600 on macOS)
  - FPS counter visible (top-left, should show ~60 FPS)
  - Node count visible (indicates scene loaded)
  - UI elements functional (map selection, wave start button)
- **Time estimate**: 5-10 seconds

### Step 3: Map 1 Testing (Winding Road) - All Bug Speeds
- **Action**: Test Map 1 with normal, slow, and fast bugs
- **Steps**:
  1. Select Map 1 from map selection UI
  2. Start wave 1 (spawns ants - normal speed)
  3. **Observe closely**: Watch bugs move through winding curves
  4. **Verify**: Bug sprites stay on brown road tiles at all times
  5. **Verify**: No cutting corners on curved sections
  6. **Verify**: Smooth continuous movement
  7. **Console check**: Look for `🛣️ Using predefined road path` and `✅ Bug spawned`
  8. For slow bugs: Wait for beetle wave OR advance to wave with beetles
  9. **Observe**: Even at slow speed (30 pts/sec), bugs stay on path
  10. For fast bugs: Advance to wave 10-15 OR wait for spider/wasp spawn
  11. **Observe**: Fast bugs (100-120 pts/sec) don't skip tiles or drift
- **Document**: Record PASS/FAIL for each speed variant in MANUAL_TEST_REPORT.md
- **Time estimate**: 5-10 minutes (depends on wave advancement)

### Step 4: Map 8, 9, 15 Testing (Path Geometry Variations)
- **Action**: Test U-turns, straight lines, and diagonal paths
- **Steps**:
  1. **Map 8 (U-Turns)**:
     - Select Map 8
     - Start waves, observe bugs making 180° turns
     - **Verify**: Bugs reach corner tile exactly before turning
     - **Verify**: No overshoot or drift during sharp turns
  2. **Map 9 (Straight Shot)**:
     - Select Map 9
     - Start waves, observe horizontal/vertical movement
     - **Verify**: Perfectly straight movement (baseline confirmation)
  3. **Map 15 (Diagonal)**:
     - Select Map 15
     - Start waves, observe diagonal movement
     - **Verify**: Bugs move through diagonal tiles sequentially
     - **Verify**: No drift toward orthogonal directions
- **Document**: Record observations for each map in MANUAL_TEST_REPORT.md
- **Time estimate**: 10-15 minutes (3-5 min per map)

### Step 5: Regression Testing (Flying and Burrowing Bugs)
- **Action**: Verify special bug types unaffected by TASK1 changes
- **Steps**:
  1. **Flying bugs (mosquito, wasp)**:
     - Advance to wave 10+ for mosquitos (10% spawn chance)
     - Advance to wave 15+ for wasps (5% spawn chance)
     - **Observe**: Flying bugs still follow path correctly
     - **Verify**: Movement unchanged from expected behavior
     - **Note**: May require multiple wave starts to encounter
  2. **Burrowing bugs**:
     - Advance to wave 18+ for burrowers (8% spawn chance)
     - **Observe**: Burrow/surface transitions work
     - **Verify**: Movement respects burrowing mechanics
     - **Fallback**: If wave 18 too time-consuming, document N/A and reference TASK1 preservation
- **Document**: PASS/FAIL/N/A for each special bug type in MANUAL_TEST_REPORT.md
- **Time estimate**: 10-20 minutes (may be lengthy to reach high waves)

### Step 6: Create Comprehensive Test Report
- **Action**: Compile all observations into structured report
- **Template**: Use PROMPT.md:100-138 template structure
- **File**: Create `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/MANUAL_TEST_REPORT.md`
- **Required sections**:
  1. Test Environment (build status, platform, date)
  2. Maps Tested (Map 1, 8, 9, 15 minimum with PASS/FAIL/notes)
  3. Bug Speed Testing (slow/normal/fast results)
  4. Regression Testing (flying/burrowing results or N/A)
  5. Visual Quality Observations (smoothness, path adherence, corner handling)
  6. Overall Assessment (PASS or FAIL with clear justification)
  7. Issues Found (if any, with map/bug/location/behavior details)
  8. Screenshots/Evidence (optional)
- **Overall Assessment Criteria**:
  - **PASS**: Bugs stay on path at all times across all tested scenarios
  - **FAIL**: Any visual drift off brown road tiles observed
- **Time estimate**: 10-15 minutes (documentation)

### Expected Total Time: 50-80 minutes

---

**Research completed:** 2025-11-20
**Total similar components found:** 0 (observation task, no new code)
**Total reusable components identified:** 5 (build system, app launcher, console logging, map paths, bug types)
**Estimated complexity:** Low (no code changes, straightforward visual verification)
