## PROMPT
Analyze the current bug movement system in `Bug.swift` to identify the root cause of path deviation and establish the technical foundation for implementing a fix.

**Your objective:** Understand WHY bugs drift off the predefined road path, not just THAT they do. Provide precise, technical analysis with line-number references and geometric reasoning.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x/SpriteKit), architecture (Entity-Component pattern), grid system (20x15 tiles, 40pt tile size), coordinate conversion formulas, and coding conventions

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Analyze
- `Sources/BugDefense/Bug.swift` (lines 254-316) - Current `update(deltaTime:pathfindingGrid:)` method containing movement logic
- `Sources/BugDefense/MapConfiguration.swift` (lines 71-103) - `expandPath()` method that expands sparse waypoints to include all intermediate tiles
- `Sources/BugDefense/GameConfiguration.swift` - Grid-to-world coordinate conversion (tileSize = 40.0)
- `Sources/BugDefense/GameScene.swift` (lines 488-504, 1009-1018) - Bug spawning and path assignment

### Known Problem Areas
From AI_PROMPT.md section 3:
- **Lines 292-315 in Bug.swift:** Movement calculation attempts axis-locking but uses imprecise heuristics
- **Lines 298-303 in Bug.swift:** Diagonal movement allows free movement in both axes (causes drift)
- **Lines 304-314 in Bug.swift:** Horizontal/vertical locking uses `deltaX > deltaY` heuristic which doesn't guarantee on-path movement

### What Success Looks Like
A clear, technical document that:
1. Explains the current algorithm with pseudocode
2. Shows exactly where and why drift occurs (with specific line numbers)
3. Provides geometric/mathematical explanation of the failure
4. Verifies that path expansion is working correctly
5. Recommends the specific fix approach (e.g., "Use normalized direction vector from current position to target waypoint")

### Analysis Framework
Follow this structure:
1. **Current Algorithm Analysis**
   - Read Bug.swift:254-316 completely
   - Document the algorithm flow step-by-step
   - Identify all position update calculations

2. **Root Cause Identification**
   - Trace through a curved path example (e.g., (1,3) → (2,3) → (2,4))
   - Calculate what the current code would do at each step
   - Identify where drift occurs geometrically

3. **Heuristic Failure Analysis**
   - Examine the `deltaX > deltaY` logic (lines 304-314)
   - Show scenarios where this produces off-path movement
   - Explain why this approach is fundamentally flawed

4. **Path System Verification**
   - Read MapConfiguration.swift:71-103
   - Confirm paths are expanded correctly
   - Verify no issues in the path definition system

5. **Solution Direction**
   - Based on the root cause, recommend the fix approach
   - Provide mathematical justification (e.g., vector normalization)
   - Ensure the solution is simple and computationally efficient

## EXTRA DOCUMENTATION

**Grid Coordinate System:**
- Origin (0,0) is bottom-left
- (19,14) is top-right
- Grid size: 20x15 tiles

**World Coordinate Conversion:**
```swift
func toWorldPosition() -> CGPoint {
    let tileSize = GameConfiguration.tileSize // 40.0
    return CGPoint(
        x: CGFloat(x) * tileSize + tileSize / 2,
        y: CGFloat(y) * tileSize + tileSize / 2
    )
}
```

**Path Expansion Example:**
Sparse path: `[(1,3), (4,3), (4,7)]`
Expands to: `[(1,3), (2,3), (3,3), (4,3), (4,4), (4,5), (4,6), (4,7)]`

This means bugs should move tile-by-tile, not in large jumps.

## LAYER
0 (Foundation - Analysis)

## PARALLELIZATION
Parallel with: []
This task must complete before TASK1 can begin.

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push
- **This is analysis only** - make NO changes to source files
- Read files using the Read tool - do NOT modify anything
- Focus on understanding, not fixing
- Document findings clearly for the implementation task (TASK1)
- Use precise line number references when identifying issues
- Provide geometric/mathematical reasoning, not just descriptions
- **NO CODE CHANGES** - if you find yourself wanting to fix something, STOP and document it instead
