@dependencies [TASK0]
# Task: Implement Vector-Based Movement Fix in Bug.swift

## Summary
Rewrite the bug movement calculation in `Bug.swift:276-315` to use proper vector-based movement that keeps bugs strictly on the path. Replace the current axis-locking heuristics with normalized direction vectors that ensure bugs move directly toward each waypoint without drift.

**Why this matters:** This is the core fix that addresses the root cause identified in TASK0. Proper vector math ensures bugs follow the straight line from their current position to the target waypoint, which keeps them on the path tiles at all times.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift/SpriteKit), architecture patterns, grid system (20x15 tiles, 40pt size), coordinate conversion, performance requirements, and coding conventions (emoji prefixes, camelCase, etc.)

**Task-Specific Context:**
This task modifies the movement calculation logic in one method only.

### Files This Task Will Modify
- `Sources/BugDefense/Bug.swift` (lines 276-315) - Replace the movement calculation section
  - **Keep unchanged:** Lines 254-275 (burrowing behavior, path setup, distance calculation)
  - **Modify:** Lines 276-315 (movement calculation and waypoint advancement)
  - **Keep unchanged:** Lines 316+ (rest of the update method)

### Pattern to Follow
From AI_PROMPT.md Section 5 (Implementation Guidance):
**Recommended Approach:**
1. Move directly toward the target waypoint's exact world position
2. Use proper vector normalization to maintain speed while moving toward target
3. Lock position exactly to the waypoint's world position when close enough
4. Only then advance to the next waypoint

### Integration Points
- Called from: `GameScene.update(_:)` every frame for each bug
- Affects: `Bug.position` (SpriteKit world coords) and `Bug.gridPosition` (grid coords)
- Must preserve: `moveSpeed`, `slowFactor`, wave scaling, burrowing behavior

### Key Constraints
- **Performance critical:** This runs every frame for every active bug
- **Use basic vector math only:** No complex algorithms or allocations
- **Preserve existing behavior:** Flying bugs, burrowing bugs, slow factors must work unchanged
- **No API changes:** Keep the same method signature and parameters

## Complexity
Medium

## Dependencies
Depends on: [TASK0]
Blocks: [TASK2, TASK3, TASKΩ]
Parallel with: []

## Detailed Steps

1. **Review TASK0 analysis findings**
   - Read the root cause analysis from TASK0
   - Understand the geometric flaw in the current approach
   - Confirm the recommended vector-based solution

2. **Locate the movement calculation section**
   - Open `Sources/BugDefense/Bug.swift`
   - Identify lines 276-315 (the section to replace)
   - Understand what needs to be preserved vs. replaced

3. **Implement the new movement algorithm**
   Replace lines 276-315 with vector-based movement:

   ```swift
   // Calculate direction vector from current position to target waypoint
   let direction = CGPoint(
       x: targetWorldPos.x - position.x,
       y: targetWorldPos.y - position.y
   )

   // Calculate distance to target
   let distance = sqrt(direction.x * direction.x + direction.y * direction.y)

   // If very close to waypoint, snap to exact position
   if distance < 2.0 {
       position = targetWorldPos
       gridPosition = movementPath[pathIndex]
       pathIndex += 1
   } else {
       // Normalize direction and apply speed
       let normalizedDirection = CGPoint(
           x: direction.x / distance,
           y: direction.y / distance
       )

       let moveDistance = moveSpeed * slowFactor * CGFloat(deltaTime)

       // Move along the normalized direction
       position.x += normalizedDirection.x * moveDistance
       position.y += normalizedDirection.y * moveDistance
   }
   ```

4. **Preserve critical existing logic**
   - Keep the burrowing behavior section (lines 258-270) exactly as-is
   - Keep the path completion check (when pathIndex reaches end)
   - Keep the health bar update and other properties

5. **Update gridPosition correctly**
   - Ensure `gridPosition` updates when waypoint is reached
   - Verify it reflects the current path position

6. **Add clarifying comments**
   - Use emoji prefix (🐛) consistent with codebase conventions
   - Explain why vector normalization prevents drift
   - Document the snap threshold (2.0 points)

7. **Test the changes build**
   - Run `swift build` to ensure no syntax errors
   - Fix any compilation issues

## Acceptance Criteria
- [ ] **Code compiles successfully**: No build errors after changes
- [ ] **Movement uses vector normalization**: Direction is normalized before applying speed
- [ ] **Position snaps exactly at waypoints**: When distance < 2.0, position = targetWorldPos exactly
- [ ] **Speed calculation preserved**: Uses `moveSpeed * slowFactor * CGFloat(deltaTime)`
- [ ] **GridPosition updates correctly**: Set to current waypoint when waypoint reached
- [ ] **PathIndex increments properly**: Only increments after position snap, not before
- [ ] **Burrowing behavior unchanged**: Lines 258-270 remain exactly as they were
- [ ] **No segment-type heuristics**: Removed the `deltaX > deltaY` logic completely
- [ ] **Simple and efficient**: No complex calculations, no allocations in hot path
- [ ] **Comments added**: Clarifying comments explain the vector-based approach
- [ ] **Follows Swift conventions**: camelCase naming, proper spacing, emoji prefixes

## Code Review Checklist
- [ ] **No dead code**: Removed old axis-locking logic completely, no commented-out code
- [ ] **Clear variable names**: `direction`, `distance`, `normalizedDirection`, `moveDistance` are descriptive
- [ ] **Geometric correctness**: Vector normalization math is correct (divide by magnitude)
- [ ] **Edge case handling**: Distance check prevents division by zero when very close to waypoint
- [ ] **Consistent with codebase**: Follows existing patterns in Bug.swift (property updates, coordinate handling)
- [ ] **No performance regressions**: Only basic math operations (sqrt, division, multiplication)
- [ ] **Preserve existing contracts**: Method signature unchanged, all properties still updated correctly
- [ ] **Error handling**: Distance check ensures we never normalize a zero-length vector

## Reasoning Trace

**Why vector normalization?**
- A normalized direction vector has length 1.0
- Multiplying by speed gives exact control over distance traveled
- This ensures bugs move AT the target, not past it or falling short
- Moving along the straight line to the target keeps the bug on the path tiles

**Why snap at distance < 2.0?**
- Prevents oscillation around the waypoint
- 2.0 points is small enough to be visually unnoticeable (tile size is 40 points)
- Ensures exact arrival at waypoint center before advancing to next

**Why remove axis-locking?**
- The current heuristic (`deltaX > deltaY`) is arbitrary and doesn't reflect the actual path geometry
- Since paths are already expanded to every tile, we don't need to infer segment direction
- Direct vector movement is simpler, more correct, and easier to understand

**Performance considerations:**
- One sqrt() call per bug per frame is acceptable (standard game math)
- No allocations (reusing existing CGPoint properties)
- No loops or complex algorithms
- This is standard vector math used in all game engines

**Alternative approaches considered:**
- Tile-by-tile snapping: Would work but creates jerky movement
- Bezier curves: Overkill for straight tile-to-tile movement
- State machine for segment types: More complex than needed, prone to same heuristic errors

**Trade-offs:**
- **Chosen:** Vector normalization - Simple, geometrically correct, smooth movement
- **Not chosen:** Axis-locking heuristics - Simpler code but fundamentally flawed for curved paths
