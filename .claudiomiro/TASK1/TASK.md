@dependencies [TASK0]
# Task: Remove A* Pathfinding Fallback from Bug Spawning

## Summary
Simplify the `spawnBug()` function to always assign the predefined road path to bugs, removing the A* pathfinding fallback logic. Since TASK0 prevents towers from being placed on roads, bugs are guaranteed to have clear paths and no longer need dynamic pathfinding.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (bug spawning system, pathfinding grid), coding conventions, and related code patterns

**Task-Specific Context:**
This task simplifies bug path assignment during spawning by removing conditional logic that checks for road blocking.

**Files This Task Will Touch:**
- `Sources/BugDefense/GameScene.swift:510-544` - The `spawnBug(_ bug: Bug)` function
- Specifically lines 522-528 that contain the A* fallback code block

**Specific Patterns to Follow:**
Current implementation (GameScene.swift:510-544):
```swift
private func spawnBug(_ bug: Bug) {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    if isRoadPathBlocked(roadPath) {
        // A* fallback - REMOVE THIS ENTIRE BLOCK
    } else {
        // Use predefined path - KEEP THIS as only behavior
    }
    bug.setPath(path)
}
```

Simplified pattern:
```swift
private func spawnBug(_ bug: Bug) {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    // Always use predefined road path (no A* fallback needed)
    bug.setPath(roadPath)
    // Rest of spawning logic...
}
```

**Integration Points:**
- Works with MapManager.shared to get current map's road path
- Calls bug.setPath() to assign path (existing method, no changes)
- Affects all bug types: ground bugs (ant, beetle) and flying bugs (mosquito, wasp)
- No longer depends on `isRoadPathBlocked()` function

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK3, TASK4, TASKΩ]
Parallel with: [TASK2]

## Detailed Steps
1. Locate `spawnBug(_ bug: Bug)` function in GameScene.swift (lines 510-544)
2. Find the conditional block that checks `isRoadPathBlocked(roadPath)` (around lines 522-528)
3. Remove the entire `if isRoadPathBlocked(roadPath) { ... } else { ... }` structure
4. Replace with direct path assignment: `bug.setPath(roadPath)`
5. Ensure all bug types (ground and flying) follow this same logic
6. Build the project to verify no compilation errors: `swift build`

## Acceptance Criteria
- [ ] `spawnBug()` no longer calls `isRoadPathBlocked()`
- [ ] All bugs receive `roadPath` directly without conditional logic
- [ ] A* path assignment code block (lines 522-528 approximately) is removed or commented out
- [ ] Ground bugs (ant, beetle) spawn with road path
- [ ] Flying bugs (mosquito, wasp) spawn with road path (same as ground)
- [ ] Project builds successfully with no compilation errors
- [ ] No changes to bug.setPath() call or bug spawning orchestration

## Code Review Checklist
- [ ] Removed conditional A* logic entirely (no orphaned if/else blocks)
- [ ] All bug types use same path assignment (no special flying bug logic)
- [ ] No calls to isRoadPathBlocked() remain in this function
- [ ] Clean code with no commented-out blocks (or clearly marked if temporarily retained)
- [ ] Bug spawning flow otherwise unchanged (position, animations, etc.)
- [ ] Follows existing code style and patterns in GameScene.swift

## Reasoning Trace
**Why this depends on TASK0:**
Cannot safely remove A* fallback until towers cannot be placed on roads. If we removed this first, bugs could fail to reach the house when roads are blocked by existing towers.

**Why this is parallel with TASK2:**
Both tasks remove road-blocking-related logic but in different functions. They don't depend on each other's completion - only on TASK0's completion.

**Design Decision - Complete Removal vs. Commenting:**
Prefer complete removal of A* fallback code over commenting because:
1. User explicitly requested road-only movement (no fallback)
2. Dead code clutters codebase and creates confusion
3. Version control preserves history if needed
4. If temporary retention is needed for safety, use clear comment: `// REMOVED: A* fallback - roads cannot be blocked after TASK0`

**Flying Bug Behavior:**
User clarified flying bugs should follow roads (not take shortcuts). Current implementation already has this behavior - `canFly` property exists but is unused. This task confirms and preserves that behavior by treating all bugs identically.

**Alternative considered and rejected:**
Keeping A* as a fallback "just in case" would violate user's explicit requirement and maintain dead code that can never execute (since TASK0 prevents road blocking).
