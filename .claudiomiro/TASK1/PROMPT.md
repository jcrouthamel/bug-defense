## PROMPT
Implement the vector-based movement fix in `Bug.swift` to eliminate path drift by replacing the axis-locking heuristics with proper normalized direction vector calculations.

**Your objective:** Modify the movement calculation in `Bug.update(deltaTime:pathfindingGrid:)` (lines 276-315) to use geometric vector math that guarantees bugs stay on the path tiles.

## COMPLEXITY
Medium

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x/SpriteKit), architecture (Entity-Component pattern), grid system (20x15 tiles, 40pt tile size), coordinate conversion, performance requirements, and coding conventions (emoji prefixes 🐛, camelCase, async/await)

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### What TASK0 Established
TASK0 identified that the root cause of path drift is the axis-locking heuristics in lines 292-315 of Bug.swift. The `deltaX > deltaY` comparison doesn't guarantee on-path movement and allows diagonal drift.

### File to Modify
**`Sources/BugDefense/Bug.swift`**
- **Lines 254-275:** KEEP - Burrowing behavior, path validation, target waypoint setup
- **Lines 276-315:** REPLACE - This is the movement calculation section with the flawed heuristics
- **Lines 316+:** KEEP - Rest of update method unchanged

### The Fix: Vector-Based Movement
Replace the current axis-locking logic with:

1. **Calculate direction vector:** `direction = targetWorldPos - currentPosition`
2. **Calculate distance:** `distance = sqrt(direction.x² + direction.y²)`
3. **Check if at waypoint:** If `distance < 2.0`, snap to exact position and advance pathIndex
4. **Otherwise, normalize and move:**
   - `normalizedDirection = direction / distance`
   - `moveDistance = moveSpeed * slowFactor * deltaTime`
   - `position += normalizedDirection * moveDistance`

### Why This Works
- **Straight line movement:** Bug always moves directly toward target waypoint
- **Speed control:** Normalization ensures consistent speed regardless of direction
- **No drift:** Can't drift off path when moving in a straight line to the next tile
- **Simple math:** Standard vector operations (normalize, scale, add)

### Existing Code to Preserve
From AI_PROMPT.md Section 5 (Constraints):
- **DO NOT** change path definition system in MapConfiguration.swift
- **DO NOT** modify grid-to-world coordinate conversion
- **DO NOT** change bug speed calculations or wave scaling
- **DO NOT** alter burrowing behavior (lines 258-270)
- **DO NOT** affect flying bugs (they use different pathfinding)

### Performance Requirements
From AI_PROMPT.md Section 5:
- Movement calculation called every frame for every active bug
- Must be computationally simple (basic vector math only)
- Avoid allocations in hot path (use existing properties)

## EXTRA DOCUMENTATION

### Vector Normalization Refresher
A normalized vector has length 1.0:
```swift
length = sqrt(x² + y²)
normalized = (x/length, y/length)
```

When you multiply a normalized vector by a scalar (speed), you get a vector pointing in the same direction with magnitude = scalar.

### Snap Threshold Reasoning
Using `distance < 2.0` as the snap threshold:
- Tile size is 40 points
- 2 points = 5% of tile size = visually imperceptible
- Prevents floating-point oscillation around target
- Ensures exact arrival before advancing to next waypoint

### Code Pattern Example
```swift
// ✅ Good - This is the pattern to implement
let direction = CGPoint(x: target.x - current.x, y: target.y - current.y)
let distance = sqrt(direction.x * direction.x + direction.y * direction.y)

if distance < 2.0 {
    position = targetWorldPos
    gridPosition = movementPath[pathIndex]
    pathIndex += 1
} else {
    let normalized = CGPoint(x: direction.x / distance, y: direction.y / distance)
    let moveDistance = moveSpeed * slowFactor * CGFloat(deltaTime)
    position.x += normalized.x * moveDistance
    position.y += normalized.y * moveDistance
}
```

```swift
// ❌ Bad - Don't use axis-locking heuristics
if abs(deltaX) > abs(deltaY) {
    // Move horizontally
    position.x += ... // This allows drift!
} else {
    // Move vertically
    position.y += ... // This allows drift!
}
```

### Integration Context
From AI_PROMPT.md Section 3:
- `GameScene.update(_:)` calls `Bug.update(deltaTime:pathfindingGrid:)` every frame
- `Bug.setPath(_:)` is called when spawning (GameScene.swift:500)
- Movement affects both `Bug.position` (world) and `Bug.gridPosition` (grid)
- Visual rendering automatically follows `position` property

## LAYER
1 (Core Implementation)

## PARALLELIZATION
Parallel with: []
This task blocks TASK2 and TASK3 (testing tasks that depend on the fix being implemented)

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push
- **Modify Bug.swift ONLY** - specifically lines 276-315
- **Preserve all other code** - burrowing, flying bugs, properties, health bar
- Use the Read tool to read Bug.swift before editing
- Use the Edit tool to make precise changes (do NOT rewrite the entire file)
- Verify compilation with `swift build` after changes
- Add clarifying comments with 🐛 emoji prefix (consistent with codebase)
- Follow Swift naming conventions (camelCase, descriptive names)
- **No pathfinding changes** - ground bugs use predefined paths only
- **No coordinate system changes** - keep grid ↔ world conversion as-is
- **No performance regressions** - use simple vector math only

## DELIVERABLES
1. Modified `Bug.swift` with vector-based movement calculation
2. Successful build (`swift build` completes without errors)
3. Clear comments explaining the vector normalization approach
4. All existing functionality preserved (burrowing, slow factors, etc.)
