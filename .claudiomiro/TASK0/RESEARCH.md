# Research for TASK0: Analyze Bug Movement System and Identify Root Cause

## Context Reference
**For tech stack and conventions, see:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (Swift/SpriteKit, grid system, conventions)
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/TASK.md` - Task-level context
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/PROMPT.md` - Task-specific context

**This file contains ONLY new information discovered during research.**

---

## Task Understanding Summary
Analyze the current bug movement implementation in `Bug.swift:254-316` to identify the exact root cause of path deviation and establish technical foundation for implementing the fix in TASK1.

---

## Files Discovered to Read/Modify

### Primary Analysis Target
- `Sources/BugDefense/Bug.swift:254-316` - `update(deltaTime:pathfindingGrid:)` method with flawed axis-locking heuristics
- `Sources/BugDefense/Bug.swift:133-134` - Private properties: `movementPath`, `pathIndex`
- `Sources/BugDefense/Bug.swift:240-251` - `setPath()` method that initializes bug at first waypoint

### Supporting Context Files
- `Sources/BugDefense/MapConfiguration.swift:71-103` - `expandPath()` method for path expansion
- `Sources/BugDefense/MapConfiguration.swift:118-133` - `map1Path` (Winding Road) - example with curves
- `Sources/BugDefense/MapConfiguration.swift:281-296` - `map8Path` (U-Turns) - example with sharp turns
- `Sources/BugDefense/MapConfiguration.swift:507-518` - `map15Path` (Diagonal) - example with diagonal segments
- `Sources/BugDefense/GameConfiguration.swift:67` - `tileSize = 40.0` constant
- `Sources/BugDefense/GameConfiguration.swift:177-182` - `GridPosition.toWorldPosition()` conversion formula
- `Sources/BugDefense/GameScene.swift:391` - Bug update call in main game loop
- `Sources/BugDefense/GameScene.swift:488-504` - `spawnBug()` method showing path assignment

---

## Code Patterns Found

### Pattern 1: Correct Vector-Based Movement (Hero.swift:110-127)
**EXCELLENT REFERENCE FOR THE FIX**

```swift
// Hero.swift:110-127 shows CORRECT movement approach
let dx = targetWorldPos.x - position.x
let dy = targetWorldPos.y - position.y
let distance = sqrt(dx * dx + dy * dy)

if distance < 5.0 {
    // Snap to target when close
    position = targetWorldPos
    currentGridPosition = target
    targetPosition = nil
} else {
    // Move toward target using ratio (equivalent to normalization)
    let moveDistance = moveSpeed * CGFloat(deltaTime)
    let ratio = min(1.0, moveDistance / distance)
    position.x += dx * ratio
    position.y += dy * ratio
}
```

**Why this is correct:**
- Uses `ratio = moveDistance / distance` which is equivalent to normalization
- The ratio approach: `position += delta * (moveDistance / distance)` is mathematically identical to `position += normalize(delta) * moveDistance`
- Always moves directly toward target regardless of direction
- No axis-locking, no segment-type detection
- Simple and geometrically correct

**Key Learning:** This is exactly the pattern Bug movement should follow!

### Pattern 2: Distance Calculation Pattern (Multiple Files)
Found consistent distance calculation pattern across codebase:
```swift
let dx = target.x - current.x
let dy = target.y - current.y
let distance = sqrt(dx * dx + dy * dy)
```

Used in:
- `Bug.swift:276-278` (current implementation)
- `Hero.swift:113`
- `DefenseStructure.swift:371-374`
- `GameScene.swift:714, 792` (using `sqrt(pow(...))` variant)
- `GameScene.swift:1707, 1729` (using `hypot()` function)

**Pattern variants:** Both `sqrt(dx*dx + dy*dy)` and `hypot(dx, dy)` are used in codebase. Both are correct.

### Pattern 3: Test Structure Pattern (BugDefenseTests.swift:1-100)
```swift
import XCTest
@testable import BugDefense

final class BugDefenseTests: XCTestCase {
    func testGridPositionConversion() {
        // Test implementation
        XCTAssertEqual(actual, expected)
    }

    @MainActor
    func testWithMainActor() {
        // Tests that require MainActor
    }
}
```

**Testing conventions discovered:**
- Test file location: `Tests/BugDefenseTests/`
- Test naming: `test{FeatureName}()`
- XCTest framework with `XCTAssertEqual`, `XCTAssertTrue`, etc.
- `@MainActor` annotation required for tests involving SpriteKit nodes
- Tests for grid position conversion exist (lines 6-15)

---

## Integration & Impact Analysis

### Functions/Classes/Components Being Modified:

#### 1. `Bug.update(deltaTime:pathfindingGrid:)` in `Bug.swift:254-316`
- **Called by:** `GameScene.swift:391` in main game update loop
  ```swift
  for bug in bugs {
      bug.update(deltaTime: deltaTime, pathfindingGrid: pathfindingGrid)
  }
  ```
- **Call frequency:** Every frame for every active bug (high-frequency hot path)
- **Parameter contract:** `func update(deltaTime: TimeInterval, pathfindingGrid: PathfindingGrid)`
- **Impact:** Changes to movement logic will affect all ground bugs (ants, beetles, spiders, burrowers). Flying bugs (mosquito, wasp) use different pathfinding.
- **Breaking changes:** NO - Internal implementation change only. Same method signature, same properties accessed.

#### 2. Properties Involved:
- `position: CGPoint` - SpriteKit node position (world coordinates)
- `gridPosition: GridPosition` - Current grid tile position
- `movementPath: [GridPosition]` - Array of waypoints from `setPath()`
- `pathIndex: Int` - Index of current target waypoint in path
- `moveSpeed: CGFloat` - Base movement speed from bug type
- `slowFactor: CGFloat` - Slow multiplier from traps/cards

**All properties are internal to Bug class - no external dependencies on movement internals.**

### Path Assignment Flow:
1. `GameScene.spawnBug()` calls `MapManager.shared.getCurrentRoadPath()` (line 495)
2. Road path is already expanded with all intermediate tiles
3. `bug.setPath(roadPath)` is called (line 500)
4. `Bug.setPath()` initializes: `movementPath = path`, `pathIndex = 1`, positions bug at first waypoint (lines 240-250)
5. `Bug.update()` is called every frame to move bug through waypoints

**No changes needed to path assignment system - paths are correct.**

### Map Path Structure (Critical Discovery):
Examined three map types:
- **Map 1 (Winding Road):** Contains curves - horizontal segments followed by vertical segments
- **Map 8 (U-Turns):** Contains sharp reversals - excellent test case for drift
- **Map 15 (Diagonal):** Contains diagonal movement `(2,12)→(3,11)→(4,10)...` where both X and Y change each step

**Key Finding:** Map paths are ALREADY defined with every grid tile included. No gaps. The `expandPath()` method would add intermediate tiles if needed, but map definitions already provide dense waypoint arrays.

---

## Current Algorithm Deep Analysis

### Algorithm Flow (Bug.swift:254-316):

```
1. Guard: pathIndex < movementPath.count (line 255)
2. Handle burrowing (lines 257-270) - UNRELATED to movement issue
3. Get target waypoint: targetGridPos = movementPath[pathIndex] (line 272)
4. Convert to world coords: targetWorldPos = targetGridPos.toWorldPosition() (line 273)
5. Calculate deltas: dx, dy, distance (lines 276-278)
6. Check if reached waypoint: distance < 2 (line 280)
   - YES: Snap position, increment pathIndex (lines 282-284)
   - NO: Calculate movement (lines 289-314)
7. Movement calculation branches:
   a. Get previous grid position (line 293)
   b. Calculate grid deltas: deltaX = abs(targetX - prevX), deltaY = abs(targetY - prevY) (lines 294-295)
   c. Branch based on grid deltas:
      - BOTH non-zero (line 298): Diagonal branch - use normalization
      - deltaX > deltaY (line 304): Horizontal branch - lock Y axis
      - else (line 309): Vertical branch - lock X axis
```

### Root Cause Identified: Lines 292-314

**The Fundamental Flaw:**

The algorithm uses **grid coordinate deltas** between waypoints to infer segment type, then applies **world coordinate axis locks**. This creates a geometric mismatch.

**Example failure scenario:**

```
Bug position: (98, 120) world coords = (2.45, 3.0) grid coords
Target waypoint: GridPosition(3, 3) = (140, 140) world coords
Previous waypoint: GridPosition(2, 3)

Grid deltas: deltaX = |3-2| = 1, deltaY = |3-3| = 0
→ deltaX > deltaY → Horizontal branch selected (lines 304-308)

Horizontal branch executes:
  position.y = targetWorldPos.y = 140  // SNAP! Forces Y to 140

Problem: Bug was at Y=120, should move smoothly toward Y=140
Instead: Y instantly jumps to 140, creating visible "pop" or drift
```

**Why axis-locking fails:**
1. Grid deltas tell us the waypoint direction (horizontal/vertical/diagonal)
2. But bug's CURRENT position might not be aligned with that axis yet
3. Locking an axis assumes bug is already on that axis - this assumption is false when:
   - Bug is between waypoints due to deltaTime overshooting
   - Bug has accumulated slight position errors
   - Bug is rounding a corner and hasn't aligned yet

**The diagonal branch (lines 298-303) is correct** - it uses normalization:
```swift
let normalizedDx = dx / distance
let normalizedDy = dy / distance
position.x += normalizedDx * moveDistance
position.y += normalizedDy * moveDistance
```
This works because it moves toward target without axis assumptions.

**But diagonal detection is wrong:** It only triggers when BOTH grid deltas are non-zero. This misses cases where:
- Bug is between waypoints (grid positions are same)
- Bug needs to correct position errors
- Bug is in transition between segment types

---

## Path System Verification

### expandPath() Analysis (MapConfiguration.swift:71-103):

```swift
private static func expandPath(_ waypoints: [GridPosition]) -> [GridPosition] {
    guard waypoints.count >= 2 else { return waypoints }
    var expandedPath: [GridPosition] = [waypoints[0]]

    for i in 1..<waypoints.count {
        let start = waypoints[i - 1]
        let end = waypoints[i]
        let dx = end.x - start.x
        let dy = end.y - start.y
        let steps = max(abs(dx), abs(dy))  // Correctly handles orthogonal and diagonal

        if steps == 0 { continue }

        for step in 1...steps {
            let x = start.x + (dx * step) / steps  // Linear interpolation
            let y = start.y + (dy * step) / steps
            let position = GridPosition(x: x, y: y)
            if position != expandedPath.last {
                expandedPath.append(position)
            }
        }
    }
    return expandedPath
}
```

**Verification Result: PATH SYSTEM IS CORRECT**

- Uses `max(abs(dx), abs(dy))` to calculate steps - handles both orthogonal and diagonal segments correctly
- Linear interpolation fills in ALL intermediate tiles
- No gaps possible in expanded path
- Duplicate prevention ensures clean path array

**Tested with map examples:**
- Map 1: Already dense waypoints, expandPath() would be mostly pass-through
- Map 8: U-turns work correctly, expansion not needed (already dense)
- Map 15: Diagonal path `(2,12)→(3,11)→(4,10)` already has every tile

**Conclusion:** The movement drift is NOT caused by path definition. Paths are geometrically correct and complete.

---

## Risks & Challenges Identified

### Technical Risks

1. **Normalization Division by Zero**
   - **Context:** When normalizing direction vector, dividing by distance could cause issues if distance ≈ 0
   - **Current mitigation:** Line 280 checks `if distance < 2` and snaps position instead of calculating movement
   - **Risk level:** LOW - Already handled correctly in existing code
   - **Note:** Keep this distance check in the fix

2. **Performance of sqrt() Calculation**
   - **Context:** `sqrt(dx*dx + dy*dy)` is called every frame for every bug
   - **Assessment:** Already present in current code (line 278), so fix won't add overhead
   - **Risk level:** LOW - Same computational complexity O(1)
   - **Note:** Could use `hypot(dx, dy)` as seen elsewhere in codebase, but current approach is fine

3. **Diagonal Segments on Map 15**
   - **Context:** Diagonal path requires both X and Y to change simultaneously
   - **Assessment:** Current diagonal branch (lines 298-303) already handles this correctly with normalization
   - **Risk level:** LOW - Proposed fix uses same normalization approach for ALL segments
   - **Mitigation:** Test specifically on Map 15 (Diagonal) during TASK1

4. **High-Speed Bugs Overshooting Waypoints**
   - **Context:** Wasps have speed=120, wave scaling could make them very fast
   - **Assessment:** Distance check (line 280) prevents overshooting by snapping when close
   - **Risk level:** LOW - Threshold of `distance < 2` is small enough to prevent visual issues
   - **Note:** May want to verify threshold is appropriate for highest speeds

### Complexity Assessment
- **Overall complexity:** LOW
- **Reasoning:**
  - Problem is localized to lines 292-314 of single method
  - Solution is simpler than current code (remove branching logic)
  - No changes to path system, properties, or integration points
  - Direct reference pattern exists in Hero.swift

### Missing Information
None - all necessary information for analysis has been found:
- ✅ Current algorithm understood
- ✅ Root cause identified (axis-locking based on grid deltas)
- ✅ Reference implementation found (Hero.swift)
- ✅ Path system verified as correct
- ✅ Integration points mapped
- ✅ Test patterns discovered

---

## Execution Strategy Recommendation

**Based on research findings, TASK1 should execute in this order:**

### Step 1: Deep Analysis Documentation
- **Action:** Create `.claudiomiro/TASK0/ANALYSIS.md` with comprehensive root cause analysis
- **Include:**
  - Current algorithm flow with line references
  - Root cause explanation with geometric reasoning
  - Failure mode examples (curved paths, fast bugs, diagonal segments)
  - Comparison: current vs. proposed approach
  - Reference to Hero.swift:110-127 as correct pattern
- **No code changes:** Analysis only

### Step 2: Verify Analysis Completeness
- **Check:** All acceptance criteria from TODO.md are addressed
- **Verify:**
  - Root cause clearly documented with line numbers
  - Geometric explanation includes mathematical reasoning
  - Path system verified (MapConfiguration.swift:71-103 correct)
  - Solution approach recommended (vector-based movement)
  - Test scenarios identified for TASK1

### Recommended Fix Approach for TASK1:

**Replace lines 292-314 with simple vector-based movement:**

```swift
// Calculate direction and move toward target
let moveDistance = moveSpeed * slowFactor * CGFloat(deltaTime)

// Always move directly toward target using normalized direction
// (Following pattern from Hero.swift:110-127)
let ratio = min(1.0, moveDistance / distance)
position.x += dx * ratio
position.y += dy * ratio

// Note: gridPosition will be updated when waypoint is reached (line 283)
```

**Rationale:**
1. Eliminates all segment-type detection logic (lines 292-296)
2. Removes flawed axis-locking branches (lines 304-314)
3. Uses same normalization approach for ALL movement
4. Follows proven pattern from Hero.swift
5. Simpler code = fewer bugs
6. Geometrically correct for any path shape

**What to preserve:**
- Lines 255-270: Guard and burrowing logic (unrelated to drift issue)
- Lines 272-278: Target waypoint and distance calculation (correct)
- Lines 280-285: Waypoint snap logic (correct, prevents division by zero)
- No changes to other methods or files

---

## Test Strategy for TASK1

### Testing Framework
- **Framework:** XCTest
- **Test command:** `swift test` or `xcodebuild test`
- **Test location:** `Tests/BugDefenseTests/`
- **Pattern:** See `BugDefenseTests.swift:1-100` for examples

### Recommended Test Cases for TASK1:

1. **Straight Horizontal Path**
   - Create bug with path: `[(1,5), (2,5), (3,5), (4,5), (5,5)]`
   - Update multiple times with fixed deltaTime
   - Assert: `position.y` remains constant (within small tolerance)
   - Assert: Bug reaches each waypoint exactly

2. **Straight Vertical Path**
   - Create bug with path: `[(5,1), (5,2), (5,3), (5,4), (5,5)]`
   - Update multiple times
   - Assert: `position.x` remains constant
   - Assert: Bug reaches each waypoint exactly

3. **L-Shaped Curved Path**
   - Path: `[(1,3), (2,3), (3,3), (3,4), (3,5)]`
   - Critical test: Watch behavior at corner waypoint (3,3)
   - Assert: No sudden position jumps
   - Assert: Path follows expected route without cutting corner

4. **Diagonal Path (Map 15 style)**
   - Path: `[(2,12), (3,11), (4,10), (5,9)]`
   - Assert: Bug moves in straight line through diagonal tiles
   - Assert: Reaches each waypoint without drift

5. **Fast Bug Test**
   - Use spider (speed=100) or wasp (speed=120)
   - Multiple updates with larger deltaTime
   - Assert: Doesn't skip waypoints
   - Assert: Snap logic works correctly

6. **Slow Bug Test**
   - Use beetle (speed=30) with slowFactor=0.1
   - Very slow movement
   - Assert: Smooth movement, no jitter
   - Assert: Still progresses correctly

### Manual Testing for TASK1:
- Run game and observe bugs on Map 1 (Winding Road)
- Run game on Map 8 (U-Turns) - critical for corner testing
- Run game on Map 15 (Diagonal) - verify diagonal movement
- Watch for visual drift off brown road tiles
- Test with different wave numbers (speed scaling)

---

**Research completed:** 2025-11-20
**Files analyzed:** 15 source files + 3 map paths
**Similar patterns found:** 1 (Hero.swift movement - exact reference for fix)
**Reusable components identified:** 0 (no utilities needed, inline calculation is appropriate)
**Estimated complexity for TASK1:** LOW (localized fix, clear solution, reference pattern exists)
