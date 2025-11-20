@dependencies [TASK1, TASK2]
# Task: Clean Up Dead Road-Blocking Code

## Summary
Remove or deprecate the now-unused `isRoadPathBlocked()` function and verify that `findFlyingPath()` remains unused. Clean up any misleading comments about A* fallback behavior. This ensures the codebase reflects the new reality: roads cannot be blocked, so road-blocking detection is dead code.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture, coding conventions (code cleanup standards), and related code patterns

**Task-Specific Context:**
This task removes dead code that is no longer reachable after TASK1 and TASK2 eliminate all calls to road-blocking detection.

**Files This Task Will Touch:**
- `Sources/BugDefense/GameScene.swift:1049-1060` - The `isRoadPathBlocked()` function (to remove/deprecate)
- `Sources/BugDefense/PathfindingGrid.swift:85-122` - The `findFlyingPath()` function (verify unused)
- Any related comments about A* fallback behavior in GameScene.swift

**Specific Patterns to Follow:**
For unused function removal:
```swift
// Option A: Complete removal (preferred)
// Delete the entire function

// Option B: Deprecation with clear marker (if retention desired for reference)
// @available(*, deprecated, message: "Roads cannot be blocked - function no longer needed")
// private func isRoadPathBlocked(_ roadPath: [GridPosition]) -> Bool { ... }
```

For comment cleanup:
- Remove comments like "// Fallback to A* if road is blocked"
- Update comments to reflect new behavior: "// Bugs always follow predefined road paths"

**Integration Points:**
- After TASK1 and TASK2, no code calls `isRoadPathBlocked()`
- `findFlyingPath()` already unused (confirmed in AI_PROMPT.md line 71-72)
- Removal should not affect any active code paths

## Complexity
Low

## Dependencies
Depends on: [TASK1, TASK2]
Blocks: [TASK4, TASKΩ]
Parallel with: []

## Detailed Steps
1. Search for all references to `isRoadPathBlocked()` in GameScene.swift
2. Verify that TASK1 and TASK2 removed all calls (should be zero references except definition)
3. Choose removal strategy:
   - **Preferred:** Delete the function entirely (lines ~1049-1060)
   - **Alternative:** Add deprecation marker if function needs temporary retention
4. Search for misleading comments about "A* fallback" or "road blocking"
5. Update or remove comments to reflect new behavior
6. Verify `findFlyingPath()` in PathfindingGrid.swift remains unused (no new calls)
7. Build the project to verify no compilation errors: `swift build`

## Acceptance Criteria
- [ ] `isRoadPathBlocked()` function is removed or clearly deprecated
- [ ] No code in GameScene.swift references `isRoadPathBlocked()`
- [ ] Search codebase confirms zero calls to `isRoadPathBlocked()`
- [ ] Misleading comments about A* fallback are removed or updated
- [ ] `findFlyingPath()` in PathfindingGrid.swift remains unused (no changes needed there)
- [ ] Project builds successfully with no compilation errors
- [ ] No warnings about unused functions (if using Swift compiler warnings)

## Code Review Checklist
- [ ] All references to dead function verified removed
- [ ] Comments accurately reflect new road-only behavior
- [ ] No orphaned imports or dependencies on A* pathfinding for bugs
- [ ] Clean removal (no commented-out code blocks unless clearly justified)
- [ ] Build succeeds with no warnings about unused code
- [ ] Version control can restore function if needed (so removal is safe)

## Reasoning Trace
**Why this depends on TASK1 and TASK2:**
Cannot safely remove `isRoadPathBlocked()` until all its callers are eliminated. TASK1 removes the call in `spawnBug()`, and TASK2 removes the call in `recalculateBugPaths()`.

**Why this is not parallel:**
Must verify that TASK1 and TASK2 are complete before removing the function they used to call. Premature removal would break the build.

**Design Decision - Complete Removal vs. Deprecation:**

**Prefer complete removal because:**
1. Function has zero callers after TASK1/TASK2 (pure dead code)
2. User explicitly wants road-only behavior (no fallback)
3. Version control preserves history if function needed later
4. Dead code confuses future maintainers

**Use deprecation only if:**
1. Temporary safety during transition period desired
2. Function might be needed for debugging or rollback
3. Project policy requires deprecation before removal

**findFlyingPath() Status:**
According to AI_PROMPT.md line 71-72: "PathfindingGrid has unused findFlyingPath() function." This function is ALREADY unused and should REMAIN unused. User wants flying bugs on roads, not using special flying paths.

**Comment Cleanup Rationale:**
Misleading comments create technical debt and confusion. Comments referencing removed behavior should be updated to match reality or removed entirely.
