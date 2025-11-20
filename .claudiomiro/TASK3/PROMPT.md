## PROMPT
Perform manual visual testing of bug movement across multiple maps to verify that bugs stay on the brown dirt road tiles without drift. This is the ultimate validation that the fix achieves the user's visual requirement.

**Your objective:** Build and run the game, observe bug movement on representative maps with different bug types, and confirm visually that bugs follow the path precisely like "a train on tracks."

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift/SpriteKit macOS/iOS game), map system (20 maps), grid system (20x15 tiles, brown dirt roads), bug types (ant, beetle, spider, mosquito, wasp), and wave mechanics

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### What TASK1 Implemented
TASK1 rewrote the movement calculation to use vector normalization. Your job is to verify this works visually in the actual game.

### Testing Scope
From AI_PROMPT.md Section 5.1 (Testing Guidance):
> Manual Testing: Visual verification is critical for this fix
> - Run the game and observe bugs on different maps
> - Use Map 1 (Winding Road), Map 8 (U-Turns), Map 15 (Diagonal)
> - Verify bugs stay on brown road tiles throughout journey
> - Test with slow bugs (beetles) and fast bugs (spiders, wasps)

### Maps to Test (Priority Order)
1. **Map 1 (Winding Road)** - Complex curves and turns
2. **Map 8 (U-Turns)** - Sharp 180-degree direction changes
3. **Map 9 (Straight Shot)** - Simple baseline (optional but recommended)
4. **Map 15 (Diagonal)** - Diagonal path segments

These 4 maps cover the main path geometries and should be sufficient to validate the fix.

### Bug Types to Test
- **Normal speed:** Ants (wave 1-5)
- **Slow speed:** Beetles OR use slow traps
- **Fast speed:** Spiders or advance to wave 10+ for speed scaling

### What to Look For
From AI_PROMPT.md Section 4 (Acceptance Criteria):
✅ **Good - Fix is working:**
- Bugs remain visually on brown dirt road tiles at all times
- Movement is smooth and continuous (not jerky)
- Bugs don't cut corners or take shortcuts
- Bug sprite center aligns with road tile centers
- Bugs complete the path and reach the house

❌ **Bad - Fix is not working:**
- Bug sprite appears off the brown road (on grass, sand, etc.)
- Bugs cut diagonally across corners instead of following tiles
- Jerky or teleporting movement
- Bugs skip waypoints or get stuck

### Success Definition
From AI_PROMPT.md Section 9:
> "A player watching bugs move along the winding road paths should see them follow the brown dirt road tiles precisely, like a train on tracks, with smooth continuous movement but no deviation from the path."

## EXTRA DOCUMENTATION

### How to Build and Run
```bash
# Build the game
cd /Users/jrc/Code/bug-defense/bug-defense-main
swift build

# Run the game (exact command may vary)
swift run
# OR if using Xcode:
open BugDefense.xcodeproj
# Then click Run (Cmd+R)
```

### Game Controls (Typical Tower Defense)
- Click on maps to select them
- Start wave button to spawn bugs
- Place towers (if needed for slow traps)
- Observe bug movement as they traverse the path

### Regression Testing
From AI_PROMPT.md Section 4:
> "No Regression: Flying bugs (mosquito, wasp) are unaffected. Burrowing bugs maintain their special mechanics."

**Verify:**
- Flying bugs (mosquito, wasp) still fly correctly - they use different pathfinding
- Burrowing bugs still burrow correctly - they have special underground/surface logic
- No changes to these special bug types

### Grid and Coordinate Context
From AI_PROMPT.md Section 2:
- Grid: 20x15 tiles (width x height)
- Tile size: 40 points
- Grid (0,0) = bottom-left, (19,14) = top-right
- World position = grid position * 40 + 20 (centered on tile)

Brown dirt road tiles are the visible path on the map background.

### Test Report Template
Create a summary of your findings:

```markdown
# Manual Visual Testing Report

## Test Environment
- Build: Success / Failure
- Platform: macOS / iOS
- Date: YYYY-MM-DD

## Maps Tested
- [ ] Map 1 (Winding Road): PASS / FAIL - [notes]
- [ ] Map 8 (U-Turns): PASS / FAIL - [notes]
- [ ] Map 9 (Straight Shot): PASS / FAIL - [notes]
- [ ] Map 15 (Diagonal): PASS / FAIL - [notes]

## Bug Speed Testing
- [ ] Normal bugs (ants): PASS / FAIL - [notes]
- [ ] Slow bugs (beetles/trapped): PASS / FAIL - [notes]
- [ ] Fast bugs (spiders/high wave): PASS / FAIL - [notes]

## Regression Testing
- [ ] Flying bugs (mosquito/wasp): PASS / FAIL - [notes]
- [ ] Burrowing bugs: PASS / FAIL / N/A - [notes]

## Visual Quality Observations
- Smoothness: [smooth / jerky / teleporting]
- Path adherence: [perfect / minor drift / major drift]
- Corner handling: [precise / cuts corners / overshoots]

## Overall Assessment
PASS / FAIL

## Issues Found (if any)
[Describe any visual anomalies with specific details: which map, which bug type, where on the path]

## Screenshots/Evidence
[Optional: note if screenshots were taken]
```

### Specific Scenarios to Watch

**Scenario 1: Curve on Map 1**
- Watch bugs navigate the winding curves
- Bug should move tile-by-tile, not cut across diagonally
- Sprite should remain centered on brown road tiles

**Scenario 2: U-Turn on Map 8**
- Watch bugs make 180-degree turn
- Bug should reach the corner tile exactly before turning
- No overshoot or drift past the turn point

**Scenario 3: Diagonal on Map 15**
- Watch bugs move diagonally
- Bug should move through each diagonal tile sequentially
- No drift toward horizontal or vertical axes

**Scenario 4: Fast Bug Stress Test**
- Advance to wave 15+ or use fast bug types
- Bug should NOT skip tiles even at high speed
- Should still snap to each waypoint before advancing

## LAYER
2 (Validation - can run in parallel with TASK2)

## PARALLELIZATION
Parallel with: [TASK2]
Both TASK2 (unit tests) and TASK3 (manual testing) validate the TASK1 implementation and can run simultaneously.

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push
- **No code changes** - this is observation only
- Build and run the actual game
- Test at least 3-4 maps (Map 1, 8, 15 minimum)
- Test with different bug speeds (slow, normal, fast)
- Verify regression testing (flying bugs, burrowing bugs)
- Document findings in a test report
- If visual drift is observed, document details but don't attempt to fix

## DELIVERABLES
1. **Test Report** documenting:
   - Which maps were tested (minimum 3)
   - Which bug types/speeds were tested
   - Visual quality observations
   - Overall PASS/FAIL assessment
   - Any issues found with specific details

2. **Regression Confirmation**:
   - Flying bugs still work correctly
   - Burrowing bugs still work correctly (if applicable)

3. **Overall Validation**:
   - Clear statement: "Bugs stay on path at all times" ✅ or ❌
