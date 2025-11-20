@dependencies []
# Task: Analyze Current Bug Movement System and Identify Root Cause

## Summary
Perform deep analysis of the current bug movement implementation in `Bug.swift` to identify the exact root cause of path deviation. This task establishes the technical foundation and understanding needed for implementing the fix.

**Why this matters:** The implementation fix (TASK1) must be based on precise understanding of why bugs drift off the path. Without proper root cause analysis, the fix might address symptoms rather than the underlying issue.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift/SpriteKit), architecture patterns, grid system details, coordinate conversion, and coding conventions

**Task-Specific Context:**
This task focuses exclusively on analysis - no code changes will be made.

### Files This Task Will Analyze
- `Sources/BugDefense/Bug.swift` (lines 254-316) - Current `update(deltaTime:pathfindingGrid:)` method
- `Sources/BugDefense/MapConfiguration.swift` (lines 71-103) - Path expansion logic
- `Sources/BugDefense/GameConfiguration.swift` - Grid-to-world coordinate conversion
- `Sources/BugDefense/GameScene.swift` (lines 488-504, 1009-1018) - Bug spawning and path assignment

### Specific Focus Areas
- **Line 292-315 in Bug.swift:** Movement calculation with axis-locking heuristics
- **Line 298-303 in Bug.swift:** Diagonal movement logic that allows free movement in both axes
- **Lines 304-314 in Bug.swift:** Horizontal/vertical locking using `deltaX > deltaY` heuristic

### Analysis Objectives
1. Understand the intended movement logic vs actual behavior
2. Identify where position drift occurs geometrically
3. Determine why axis-locking fails on curves and diagonals
4. Verify that paths are correctly expanded to include all intermediate tiles
5. Document the precise failure modes

## Complexity
Low

## Dependencies
Depends on: []
Blocks: [TASK1]
Parallel with: []

## Detailed Steps

1. **Read and understand the movement implementation**
   - Read `Bug.swift:254-316` completely
   - Map out the current algorithm flow
   - Identify all variables involved in movement calculation

2. **Analyze the axis-locking heuristics**
   - Examine lines 292-315 that determine segment type (horizontal/vertical/diagonal)
   - Understand the `deltaX > deltaY` comparison logic
   - Identify scenarios where this heuristic fails

3. **Trace a specific movement scenario**
   - Choose a curved path segment (e.g., moving from (1,3) → (2,3) → (2,4))
   - Manually calculate what the current algorithm would do
   - Identify where drift would occur

4. **Verify path expansion correctness**
   - Read `MapConfiguration.swift:71-103`
   - Confirm that `expandPath()` includes all intermediate tiles
   - Verify no gaps exist in the path array

5. **Review coordinate conversion**
   - Read the grid-to-world conversion in `GameConfiguration.swift`
   - Verify the conversion formula: `position * tileSize + tileSize/2`
   - Ensure this is used consistently

6. **Document root cause findings**
   - Write precise explanation of why drift occurs
   - Identify the geometric flaw in the current approach
   - Propose the mathematical correction needed (for TASK1 to implement)

## Acceptance Criteria
- [ ] **Root Cause Documented**: Clear explanation of why bugs drift off the path with specific line references
- [ ] **Failure Modes Identified**: List all scenarios where the current logic fails (straight paths, curves, diagonals)
- [ ] **Path System Verified**: Confirmed that path expansion works correctly and paths include all intermediate tiles
- [ ] **Geometric Analysis Complete**: Mathematical explanation of the position drift issue
- [ ] **Solution Direction Established**: High-level recommendation for the fix approach (vector-based vs. other)
- [ ] **No Code Changes**: This task is analysis only - no modifications to source files

## Code Review Checklist
N/A - This is an analysis task with no code changes.

## Reasoning Trace

**Why separate analysis from implementation?**
- Ensures the fix is based on deep understanding, not trial-and-error
- Allows validation of assumptions before making changes
- Provides clear documentation of the problem for future reference
- Creates a checkpoint for review before proceeding to implementation

**Key Questions to Answer:**
1. Is the problem in the movement calculation itself, or in how waypoints are defined?
   - Expected answer: Movement calculation (paths are already correct)
2. Does the axis-locking heuristic work for straight paths?
   - Need to verify with specific examples
3. Why does diagonal movement allow drift?
   - Lines 298-303 move freely in both axes without constraint
4. What's the correct geometric approach?
   - Direct vector from current position to target waypoint world position
   - Normalize and scale by speed * deltaTime

**Analysis Output Format:**
Create a summary document (can be in CONTEXT.md for this task) that includes:
- Current algorithm pseudocode
- Failure scenario diagrams (text-based)
- Root cause statement
- Recommended fix approach with mathematical justification
