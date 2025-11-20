@dependencies [TASK1]
# Task: Manual Visual Testing Across Multiple Maps

## Summary
Perform manual visual verification of bug movement across representative maps to ensure bugs stay on the brown dirt road tiles without visual drift. This complements unit tests by validating real gameplay scenarios and visual quality.

**Why this matters:** Unit tests verify the math, but only visual inspection can confirm the fix achieves the user's requirement: "bugs stay on the path at all times." This is the ultimate acceptance test that the visual drift issue is resolved.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift/SpriteKit), map system (20 maps with different path geometries), grid system (20x15 tiles), bug types (ant, beetle, spider, etc.), and wave mechanics

**Task-Specific Context:**
This task involves building and running the actual game to visually observe bug behavior.

### Files Involved (Read-Only)
- `Sources/BugDefense/MapConfiguration.swift` - Map definitions to understand different path types
- `Sources/BugDefense/GameScene.swift` - Game runtime and controls
- `Sources/BugDefense/Bug.swift` - The modified movement logic (from TASK1)

### Maps to Test
From AI_PROMPT.md Section 5.1:
**Priority maps** (representative sample):
1. **Map 1 (Winding Road):** Complex curves and turns - tests curve handling
2. **Map 8 (U-Turns):** Sharp direction changes - tests corner handling
3. **Map 9 (Straight Shot):** Simple horizontal/vertical - baseline test
4. **Map 15 (Diagonal):** Diagonal path segments - tests diagonal movement

**Additional maps** (if time permits):
- Map 3, Map 5, Map 12 - Various geometries for completeness

### Bug Types to Test
From AI_PROMPT.md Section 4 (Edge Cases):
- **Slow bug:** Beetle (naturally slow, tests minimum speed)
- **Fast bug:** Spider or Wasp (tests high speed with wave scaling)
- **Normal bug:** Ant (baseline test)

### Visual Verification Criteria
From AI_PROMPT.md Section 4:
- Bugs MUST remain visually on brown dirt road tiles
- No part of bug sprite should appear significantly off-path
- Movement should appear smooth, not jerky or teleporting

## Complexity
Low

## Dependencies
Depends on: [TASK1]
Blocks: [TASKΩ]
Parallel with: [TASK2]

## Detailed Steps

1. **Build the game**
   - Run `swift build` to compile with TASK1 changes
   - Verify build succeeds with no errors

2. **Launch the game**
   - Run the game executable (or use Xcode to run if needed)
   - Verify game starts successfully

3. **Test Map 1 (Winding Road) with normal bugs**
   - Select Map 1
   - Start wave 1 (normal speed ants)
   - **Observe:** Watch bugs closely as they move along the winding path
   - **Verify:** Bugs stay centered on brown road tiles throughout journey
   - **Verify:** No visual drift during curves or turns
   - **Verify:** Bugs reach the house successfully

4. **Test Map 1 with slow bugs**
   - Advance to a wave with beetles (slow bugs)
   - OR place slow traps to slow down bugs
   - **Observe:** Slow-moving bugs on the winding path
   - **Verify:** Even at slow speed, bugs stay on path tiles
   - **Verify:** No jittering or position correction artifacts

5. **Test Map 1 with fast bugs**
   - Advance to wave 10+ (wave scaling increases speed)
   - OR test with spiders/wasps (naturally fast)
   - **Observe:** Fast-moving bugs on the winding path
   - **Verify:** Bugs don't skip tiles or cut corners
   - **Verify:** Smooth movement even at high speed

6. **Test Map 8 (U-Turns) with normal bugs**
   - Select Map 8
   - Start waves and observe U-turn behavior
   - **Observe:** Bugs making sharp 180-degree turns
   - **Verify:** Bugs follow the path precisely through U-turns
   - **Verify:** No overshoot or drift at corners

7. **Test Map 9 (Straight Shot) baseline**
   - Select Map 9
   - Start waves
   - **Observe:** Simple straight-line movement
   - **Verify:** Bugs move in perfectly straight lines
   - **Verify:** Baseline confirmation that simple paths work

8. **Test Map 15 (Diagonal) for diagonal segments**
   - Select Map 15
   - Start waves
   - **Observe:** Bugs moving diagonally across the grid
   - **Verify:** Diagonal movement stays on diagonal path tiles
   - **Verify:** No drift to orthogonal directions

9. **Test regression: Flying bugs**
   - Find a wave with mosquitos or wasps (flying bugs)
   - **Verify:** Flying bugs still function correctly (use their own pathfinding)
   - **Verify:** No changes to flying bug behavior

10. **Test regression: Burrowing bugs**
    - Find a wave with burrowing bugs (if applicable)
    - **Verify:** Burrowing behavior still works (underground/surface transitions)
    - **Verify:** Movement respects burrowing mechanics

11. **Document findings**
    - Create a test report documenting:
      - Which maps were tested
      - Which bug types were tested
      - Any visual anomalies observed (if any)
      - Overall pass/fail assessment
    - Take screenshots or notes if issues found

## Acceptance Criteria
- [ ] **Game builds and runs**: No compilation or runtime errors
- [ ] **Map 1 tested**: Winding path works with normal, slow, and fast bugs
- [ ] **Map 8 tested**: U-turns handled correctly without drift
- [ ] **Map 9 tested**: Straight paths work correctly (baseline)
- [ ] **Map 15 tested**: Diagonal paths work correctly
- [ ] **Slow bugs verified**: Beetles or slowed bugs stay on path
- [ ] **Fast bugs verified**: High-speed bugs don't skip waypoints or drift
- [ ] **Visual quality**: Movement is smooth, no teleporting or jerkiness
- [ ] **No drift observed**: Bugs remain on brown road tiles at all times across all tested maps
- [ ] **Flying bugs unchanged**: Mosquitos/wasps still fly correctly (regression test)
- [ ] **Burrowing unchanged**: Burrowing mechanics still work (if applicable)
- [ ] **Test report created**: Document which scenarios were tested and results

## Code Review Checklist
N/A - This is a manual testing task with no code changes.

## Reasoning Trace

**Why manual testing is necessary:**
- Unit tests verify math, but can't verify visual appearance
- The user's requirement is "bugs stay on the path **at all times**" - this is inherently visual
- Real gameplay reveals edge cases that synthetic tests might miss
- Different maps stress different path geometries (curves, diagonals, U-turns)

**Why test multiple maps:**
From AI_PROMPT.md Section 4: "The fix must work correctly across all 20 map layouts without special-casing."
- Testing 4 representative maps (winding, U-turn, straight, diagonal) covers the major path geometries
- If these work, the fix is geometry-agnostic and should work on all maps

**Why test different bug speeds:**
From AI_PROMPT.md Section 4 (Edge Cases):
- Very slow bugs test minimum movement calculations (potential jitter)
- Very fast bugs test waypoint skipping edge cases
- Normal bugs test typical gameplay

**Why test flying/burrowing bugs:**
From AI_PROMPT.md Section 4: "No Regression: Flying bugs (mosquito, wasp) are unaffected. Burrowing bugs maintain their special mechanics."
- These bugs have special movement code that shouldn't be touched
- Regression testing ensures TASK1 changes didn't break them

**What "staying on path" means visually:**
- Bug sprite center should align with road tile center
- During movement between tiles, bug should move in straight line (not arc or drift)
- On curved paths, bug should follow the tiles sequentially (not cut corners)

**Success criteria for visual testing:**
From AI_PROMPT.md Section 9: "A player watching bugs move along the winding road paths should see them follow the brown dirt road tiles precisely, like a train on tracks, with smooth continuous movement but no deviation from the path."

**Test report format:**
```
# Manual Testing Report

## Maps Tested
- Map 1 (Winding Road): ✅ PASS
- Map 8 (U-Turns): ✅ PASS
- Map 9 (Straight Shot): ✅ PASS
- Map 15 (Diagonal): ✅ PASS

## Bug Types Tested
- Normal speed (ants): ✅ PASS
- Slow bugs (beetles): ✅ PASS
- Fast bugs (spiders, wave 15+): ✅ PASS

## Regression Testing
- Flying bugs (mosquitos/wasps): ✅ PASS
- Burrowing bugs: ✅ PASS (if applicable)

## Visual Quality
- Smooth movement: ✅
- No teleporting: ✅
- No drift off path: ✅
- No jittering: ✅

## Overall Assessment
✅ PASS - Bugs stay on path at all times across all tested scenarios
```

**Alternative: If issues found:**
If any visual drift or anomalies are observed:
1. Document the exact scenario (map, bug type, location)
2. Note the specific behavior (e.g., "bug drifts 5 points left at corner")
3. Do NOT attempt to fix (that's outside this task scope)
4. Report findings to trigger TASK1 review
