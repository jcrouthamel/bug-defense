## PROMPT
Remove or deprecate the now-unused `isRoadPathBlocked()` function in GameScene.swift, verify that `findFlyingPath()` remains unused, and clean up any misleading comments about A* fallback behavior. This removes dead code after TASK1 and TASK2 eliminated all callers of road-blocking detection.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture, coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
- `Sources/BugDefense/GameScene.swift` lines ~1049-1060 - The `isRoadPathBlocked()` function (remove/deprecate)
- `Sources/BugDefense/GameScene.swift` - Any comments referencing A* fallback behavior (update/remove)
- `Sources/BugDefense/PathfindingGrid.swift` lines 85-122 - The `findFlyingPath()` function (verify still unused, no changes)

### Patterns to Follow
**Removal pattern (preferred):**
```swift
// Simply delete the entire isRoadPathBlocked() function
// Version control preserves history if needed
```

**Deprecation pattern (alternative if retention desired):**
```swift
@available(*, deprecated, message: "Roads cannot be blocked - function no longer needed after TASK0")
private func isRoadPathBlocked(_ roadPath: [GridPosition]) -> Bool {
    // Function body...
}
```

**Comment cleanup examples:**
```swift
// BEFORE (misleading):
// If road is blocked, bugs use A* pathfinding

// AFTER (accurate):
// Bugs always follow predefined road paths

// OR simply remove if comment is now redundant
```

### Integration Points
- After TASK1 removes `isRoadPathBlocked()` call in `spawnBug()`
- After TASK2 removes `isRoadPathBlocked()` call in `recalculateBugPaths()`
- Function should have zero callers (verify with search)

### Verification Strategy
1. Search entire codebase for `isRoadPathBlocked` - should find only definition
2. Search for comments containing "A*", "blocked", "fallback" - update or remove misleading ones
3. Verify `findFlyingPath` still unused (already confirmed unused in AI_PROMPT.md)

## EXTRA DOCUMENTATION

### Why This Function Is Now Dead Code
**Before TASK0:** Roads could be blocked by towers → function checked if structures blocked road tiles → bugs used A* fallback

**After TASK0:** Roads cannot be blocked → function always returns false (or never called) → pure dead code

### findFlyingPath() Status
According to AI_PROMPT.md:
- "PathfindingGrid has unused findFlyingPath() function (PathfindingGrid.swift:85-122)"
- User wants flying bugs to follow roads (not use special paths)
- This function ALREADY unused and should REMAIN unused
- No changes needed to PathfindingGrid.swift - just verify no new calls introduced

### Removal Safety
Safe to remove `isRoadPathBlocked()` because:
1. TASK1 and TASK2 eliminated all callers
2. Function purpose (detect road blocking) is obsolete after TASK0
3. Version control preserves history for reference
4. Dead code creates confusion and maintenance burden

### Expected Outcome
After this task:
- Codebase has no road-blocking detection logic
- Comments accurately reflect road-only bug behavior
- No unused functions generating compiler warnings
- Code is cleaner and easier to understand

## LAYER
2

## PARALLELIZATION
Parallel with: []

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push.
- Prefer complete removal over deprecation (unless project policy requires deprecation first)
- Do NOT modify PathfindingGrid.swift (findFlyingPath stays unused but intact)
- Do NOT remove A* pathfinding infrastructure (might be used elsewhere or future)
- Do NOT modify Bug.swift or movement logic
- Only remove code confirmed unused by TASK1 and TASK2 completion
- Build must succeed after changes: `swift build`
- Use grep/search to verify zero references before removal
