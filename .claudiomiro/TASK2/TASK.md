@dependencies [TASK0]
# Task: Simplify Bug Path Recalculation Logic

## Summary
Simplify the `recalculateBugPaths()` function to always use predefined road paths when recalculating bug paths, removing the road-blocking conditional check. This ensures consistency with spawn behavior (TASK1) and eliminates dynamic pathfinding during path recalculation events (like map transitions).

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (tier progression system with map changes every 10 waves), coding conventions, and related code patterns

**Task-Specific Context:**
This task simplifies the path recalculation logic used when maps change during tier transitions (every 10 waves).

**Files This Task Will Touch:**
- `Sources/BugDefense/GameScene.swift:1062-1087` - The `recalculateBugPaths()` function

**Specific Patterns to Follow:**
Current implementation (GameScene.swift:1062-1087):
```swift
private func recalculateBugPaths() {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    if isRoadPathBlocked(roadPath) {
        // A* fallback for each bug
    } else {
        // Use predefined road path for each bug
    }
}
```

Simplified pattern:
```swift
private func recalculateBugPaths() {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    // Always use predefined road path (no blocking check needed)
    for bug in activeBugs {
        bug.setPath(roadPath)
    }
}
```

**Integration Points:**
- Called during tier transitions when map changes (every 10 waves)
- Iterates through activeBugs array (bugs currently on screen)
- Works with MapManager.shared to get new map's road path
- Uses bug.setPath() to reassign paths

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK3, TASK4, TASKΩ]
Parallel with: [TASK1]

## Detailed Steps
1. Locate `recalculateBugPaths()` function in GameScene.swift (lines 1062-1087)
2. Find the conditional block that checks `isRoadPathBlocked(roadPath)`
3. Remove the `if isRoadPathBlocked(roadPath) { ... } else { ... }` structure
4. Replace with direct path assignment loop:
   ```swift
   let roadPath = MapManager.shared.getCurrentRoadPath()
   for bug in activeBugs {
       bug.setPath(roadPath)
   }
   ```
5. Ensure function still serves its purpose during map transitions
6. Build the project to verify no compilation errors: `swift build`

## Acceptance Criteria
- [ ] `recalculateBugPaths()` no longer checks `isRoadPathBlocked()`
- [ ] All bugs in activeBugs array receive `roadPath` directly
- [ ] Conditional A* logic removed from this function
- [ ] Function still correctly handles map transitions (tier progression)
- [ ] Path recalculation works for all bugs on screen simultaneously
- [ ] Project builds successfully with no compilation errors

## Code Review Checklist
- [ ] Removed conditional road-blocking check entirely
- [ ] Loop through activeBugs array correctly (existing pattern preserved)
- [ ] No calls to isRoadPathBlocked() remain in this function
- [ ] Clean code with no commented-out blocks
- [ ] Function name still accurately describes behavior (recalculates paths → yes)
- [ ] Follows existing code style and patterns

## Reasoning Trace
**Why this depends on TASK0:**
Same rationale as TASK1 - cannot safely remove road-blocking logic until roads are physically unblockable.

**Why this is parallel with TASK1:**
These functions serve different purposes but perform similar simplifications:
- TASK1: Simplifies path assignment during initial bug spawning
- TASK2: Simplifies path assignment during map transitions

They modify different functions and don't depend on each other.

**When is this function called?**
According to AI_PROMPT.md section 5, this function is "still needed when map changes during tier transitions." Maps change every 10 waves, and all bugs on screen need their paths updated to the new map's road.

**Design Decision - Function Preservation:**
Keep `recalculateBugPaths()` function even though it's now simpler because:
1. Semantic clarity: name describes the "what" and "when" (map change event)
2. Single responsibility: separates spawn-time path assignment from recalculation
3. Future-proofing: if map transitions need special handling, logic is isolated

**Alternative considered and rejected:**
Could inline this into map transition code, but keeping it as a named function preserves code organization and readability.
