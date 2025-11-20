@dependencies []
# Task: Add Road Path Validation to Tower Placement

## Summary
Modify the `canPlaceStructure()` function in GameScene.swift to prevent tower placement on road tiles. This is the foundational change that enables road-only bug movement by making roads physically impassable for towers. All bugs will then be guaranteed to have unblocked road paths to follow.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (20x15 grid system, MapManager pattern), coding conventions (console logging with ❌/✅ patterns), and related code patterns

**Task-Specific Context:**
This task modifies the tower placement validation logic - the gatekeeper that determines where players can build.

**Files This Task Will Touch:**
- `Sources/BugDefense/GameScene.swift:866-896` - The `canPlaceStructure()` function

**Specific Patterns to Follow:**
- Use road path access pattern from GameScene.swift: `MapManager.shared.getCurrentRoadPath()`
- Follow existing validation check pattern (lines 875-878 for house check):
  ```swift
  if position == MapManager.shared.getCurrentHousePosition() {
      print("❌ Cannot place on house: \(position)")
      return false
  }
  ```
- Follow array contains pattern: `MapManager.shared.getCurrentRoadPath().contains(position)`
- Console logging: Use "❌" for failures, match existing verbosity

**Integration Points:**
- This check integrates with existing validation chain (bounds → house → structures → road)
- Works with MapManager.shared to get current map's road path
- Feeds into visual placement preview system (red preview on hover)

## Complexity
Low

## Dependencies
Depends on: []
Blocks: [TASK1, TASK2, TASK3]
Parallel with: []

## Detailed Steps
1. Locate `canPlaceStructure(at position: GridPosition) -> Bool` in GameScene.swift (lines 866-896)
2. After existing validation checks (bounds, house, existing structures), add road path check:
   ```swift
   // Check if position is on road path
   let roadPath = MapManager.shared.getCurrentRoadPath()
   if roadPath.contains(position) {
       print("❌ Cannot place on road: \(position)")
       return false
   }
   ```
3. Ensure this check happens AFTER bounds/house/structure checks (maintain validation order)
4. Build the project to verify no compilation errors: `swift build`

## Acceptance Criteria
- [ ] `canPlaceStructure()` returns false when position is in current map's road path
- [ ] Console prints "❌ Cannot place on road: \(position)" when placement attempted on road
- [ ] Check is positioned correctly in validation chain: bounds → house → existing structures → road path
- [ ] Project builds successfully with no compilation errors
- [ ] Existing validation checks (bounds, house, structures) remain unchanged

## Code Review Checklist
- [ ] Clear variable naming (use `roadPath` to match existing patterns)
- [ ] Console logging matches existing patterns (❌ prefix)
- [ ] Uses MapManager.shared.getCurrentRoadPath() (follows existing pattern)
- [ ] No hardcoded map-specific logic (works for all 20 maps)
- [ ] Validation order is logical and efficient
- [ ] No impact on existing checks (house, bounds, structures)

## Reasoning Trace
**Why this is Layer 0:**
This is the foundational change that makes all other tasks possible. Once towers cannot be placed on roads, bugs are guaranteed to have clear paths, enabling removal of A* fallback logic.

**Design Decision - Validation Order:**
Place road check AFTER bounds/house/structures because:
1. Bounds check is fastest (simple coordinate comparison)
2. House check is single-point comparison (fast)
3. Structure check iterates existing structures (small array)
4. Road check iterates road path (10-50 waypoints) - most expensive

This ordering optimizes for early rejection of invalid placements.

**Why contains() is acceptable:**
Road paths have ~10-50 waypoints (expanded). O(n) linear search is acceptable given:
- Called only during mouse movement (not every frame)
- Array is small (< 100 elements)
- No performance issues reported in existing similar checks

**Alternative considered and rejected:**
Converting roadPath to Set for O(1) lookup would require caching or repeated conversions. Current approach is simpler and sufficient for this use case.
