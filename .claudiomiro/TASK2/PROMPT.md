## PROMPT
Simplify the `recalculateBugPaths()` function in GameScene.swift to always use predefined road paths when recalculating bug paths during map transitions, removing the road-blocking conditional check that triggers A* pathfinding.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (tier progression with map changes every 10 waves), coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
- `Sources/BugDefense/GameScene.swift` lines 1062-1087 - The `recalculateBugPaths()` function

### Patterns to Follow
**Current pattern (to be simplified):**
```swift
private func recalculateBugPaths() {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    if isRoadPathBlocked(roadPath) {
        // A* fallback - REMOVE THIS
        for bug in activeBugs {
            let aStarPath = pathfindingGrid.findPath(...)
            bug.setPath(aStarPath)
        }
    } else {
        // Predefined road path - KEEP THIS AS ONLY BEHAVIOR
        for bug in activeBugs {
            bug.setPath(roadPath)
        }
    }
}
```

**Simplified pattern (target state):**
```swift
private func recalculateBugPaths() {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    for bug in activeBugs {
        bug.setPath(roadPath)
    }
}
```

### Integration Points
- Called during tier transitions when map changes (every 10 waves)
- Operates on activeBugs array (bugs currently alive on screen)
- Uses MapManager.shared.getCurrentRoadPath() to get new map's road
- Calls bug.setPath() for each bug to update their navigation

### Why This Change Is Safe
TASK0 prevents towers from being placed on roads, guaranteeing:
1. New map's road path is always clear (no towers blocking it)
2. A* recalculation fallback is unnecessary
3. All bugs can transition to new map's path smoothly

## EXTRA DOCUMENTATION

### When This Function Executes
- Tier transitions occur every 10 waves
- When map changes, all bugs on screen need path updates
- New map has different road geometry → bugs must recalculate routes
- Function iterates through activeBugs array and reassigns paths

### Function Purpose (Preserved)
Keep this function as a separate method even though it's now simpler:
- Semantic clarity: "recalculate paths during map change" is clear intent
- Single responsibility: separates spawn-time logic (TASK1) from transition logic
- Maintainability: future map transition logic stays isolated

### Expected Outcome
After this change:
- `recalculateBugPaths()` has linear logic (no conditionals)
- All bugs on screen receive new roadPath during map transitions
- No calls to `isRoadPathBlocked()` in this function
- No A* path calculation during recalculation

### Verification Steps
1. Build project: `swift build` (must succeed)
2. Verify no calls to `isRoadPathBlocked()` in `recalculateBugPaths()`
3. Verify all bugs receive roadPath from MapManager
4. Confirm function still serves map transition purpose

## LAYER
1

## PARALLELIZATION
Parallel with: [TASK1]

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push.
- Remove road-blocking conditional entirely (prefer removal over commenting)
- Keep the function as a separate method (don't inline into map transition code)
- Do NOT modify Bug.swift or bug.setPath() behavior
- Do NOT change activeBugs array management
- Do NOT add special handling for different bug types
- Build must succeed after changes: `swift build`
- This change applies to ALL 20 map types (generic solution)
- Function must still correctly handle map transitions (its primary purpose)
