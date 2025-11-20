## PROMPT
Perform comprehensive manual testing of the road enforcement system to validate that tower placement is correctly blocked on roads and that all bugs follow predefined road paths across multiple map types, edge cases, and game scenarios.

## COMPLEXITY
Medium

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (20 map types, tier progression system), testing philosophy (manual gameplay testing), and complete acceptance criteria

**You MUST read AI_PROMPT.md before executing this task to understand the environment and acceptance criteria.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
- No code files - this is a validation-only task
- Interacts with running game application

### Testing Approach
Manual gameplay testing following AI_PROMPT.md section 5.1:
1. Build and run game: `swift build && open BugDefense.app`
2. Validate happy path scenarios (existing behavior preserved)
3. Validate core changes (road blocking, path enforcement)
4. Validate edge cases (map transitions, flying bugs, etc.)

### Integration Points
This task validates the complete feature integration:
- TASK0: Tower placement validation on roads
- TASK1: Bug spawn path assignment (no A* fallback)
- TASK2: Path recalculation during map transitions
- TASK3: Dead code cleanup (no functional impact but cleaner codebase)

### Test Scenarios (From AI_PROMPT.md Section 5.1)

**1. Happy Path:**
- Place tower off-road → success (existing behavior)
- Bug spawns → follows road → reaches house (core behavior)

**2. Core Change:**
- Tower placement on road → rejected with red preview and console message
- Bug spawns → uses predefined path (not A*)

**3. Edge Cases:**
- Map changes at wave 10 → new road protected
- Flying bug spawns → follows road (not direct line)
- House position → still protected

## EXTRA DOCUMENTATION

### Build and Run Commands
```bash
# Build the project
swift build

# Launch the game
open BugDefense.app

# Or run from Xcode if app bundle not found
# Xcode → Run (Cmd+R)
```

### Test Maps to Focus On
From AI_PROMPT.md sections 4 and 5:
- **Map 1 (Winding Road):** Complex path with many turns
- **Map 9 (Straight Shot):** Simple linear path
- **Map 11 (Box Spiral):** Geometric complexity
- **Spot-check:** Maps 5, 10, 15, 20 for diversity

### Expected Console Output
When attempting tower placement on road:
```
❌ Cannot place on road: GridPosition(x: 5, y: 7)
```

When placement succeeds off-road:
```
✅ Can place at: GridPosition(x: 6, y: 8)
```

### Bug Types to Test
**Ground bugs:** ant, beetle (standard road-following)
**Flying bugs:** mosquito, wasp (should follow roads, not fly direct)

### Map Transition Testing
Maps change every 10 waves (tier progression):
- Complete waves 1-9 on first map
- Wave 10 triggers map change
- Verify new map's road is protected
- Verify bugs recalculate paths if alive during transition

### Validation Checklist (From AI_PROMPT.md Section 4)
Reference the complete acceptance criteria in AI_PROMPT.md section 4:
- AC1-AC5: Primary requirements
- EC1-EC4: Edge cases
- CQ1-CQ3: Code quality (partially validated here)

### Success Definition
Testing passes if:
1. All AC1-AC5 criteria validated successfully
2. All EC1-EC4 edge cases handled correctly
3. No unexpected errors or crashes during testing
4. Console logs match expected patterns
5. Gameplay feels predictable and strategic (bugs always on roads)

Testing fails if:
1. Any acceptance criteria not met
2. Bugs observed leaving road paths
3. Towers can be placed on roads
4. Console errors or crashes occur
5. Flying bugs take direct routes instead of following roads

## LAYER
3

## PARALLELIZATION
Parallel with: []

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push.
- This is a validation-only task (no code changes)
- Must test across multiple map types (minimum 5 maps: 1, 5, 10, 15, 20)
- Must test both ground and flying bug types
- Must test map transition scenario (progress to wave 10+)
- Must verify console logging matches expected patterns
- Document any failures or unexpected behavior clearly
- All acceptance criteria from AI_PROMPT.md section 4 must be validated
- If any criteria fails, document exactly what failed and how
