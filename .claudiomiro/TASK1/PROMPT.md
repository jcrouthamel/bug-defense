## PROMPT
Remove the A* pathfinding fallback logic from the `spawnBug()` function in GameScene.swift and simplify it to always assign the predefined road path to all bugs, since roads can no longer be blocked by towers (guaranteed by TASK0).

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (bug spawning system, 20 map types, MapManager pattern), coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
- `Sources/BugDefense/GameScene.swift` lines 510-544 - The `spawnBug(_ bug: Bug)` function
- Specifically removing/simplifying lines 522-528 (A* fallback conditional block)

### Patterns to Follow
**Current pattern (to be simplified):**
```swift
private func spawnBug(_ bug: Bug) {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    if isRoadPathBlocked(roadPath) {
        // A* pathfinding fallback - REMOVE THIS
        let aStarPath = pathfindingGrid.findPath(...)
        bug.setPath(aStarPath)
    } else {
        // Predefined road path - KEEP THIS AS ONLY BEHAVIOR
        bug.setPath(roadPath)
    }
}
```

**Simplified pattern (target state):**
```swift
private func spawnBug(_ bug: Bug) {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    bug.setPath(roadPath)
    // Rest of spawning logic unchanged...
}
```

### Integration Points
- Road path obtained via MapManager.shared.getCurrentRoadPath()
- Path assigned via existing bug.setPath(roadPath) method
- Spawning position, animations, and other orchestration unchanged
- Applies to ALL bug types: ground (ant, beetle) and flying (mosquito, wasp)

### Why This Change Is Safe
TASK0 prevents towers from being placed on roads, guaranteeing that:
1. Road paths are always clear (no blocking possible)
2. A* pathfinding fallback is never needed
3. Bugs can always reach the house via predefined road path

## EXTRA DOCUMENTATION

### Bug Types Affected
All bug types should follow road paths after this change:
- **Ground bugs:** ant, beetle (already follow roads)
- **Flying bugs:** mosquito, wasp (user explicitly wants them on roads too)

Reference: Bug.swift:106-113 defines canFly property, but it's currently unused. Keep it unused - all bugs use road paths.

### Code Block to Remove
The conditional block around lines 522-528 that checks `isRoadPathBlocked(roadPath)` and contains A* fallback logic.

### Expected Outcome
After this change:
- `spawnBug()` has simpler, linear logic (no conditionals for path choice)
- All bugs spawn with roadPath assigned
- No calls to `isRoadPathBlocked()` in this function
- No A* path calculation during spawning

### Verification Steps
1. Build project: `swift build` (must succeed)
2. Verify no calls to `isRoadPathBlocked()` in `spawnBug()`
3. Verify all bugs use `roadPath` from MapManager
4. Confirm flying bug logic unchanged (no special behavior added)

## LAYER
1

## PARALLELIZATION
Parallel with: [TASK2]

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push.
- Remove A* fallback code entirely (prefer removal over commenting unless needed for safety)
- If commenting out code temporarily, use: `// REMOVED: A* fallback - roads cannot be blocked`
- Do NOT modify Bug.swift movement logic (movement code is correct)
- Do NOT add special flying bug path logic (user wants flying bugs on roads)
- Do NOT modify bug.setPath() method signature or behavior
- Do NOT change spawning position, animations, or other orchestration
- Build must succeed after changes: `swift build`
- This change applies to ALL 20 map types (generic solution)
