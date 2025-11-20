# Bug Movement Path Deviation - Root Cause Analysis

## Executive Summary

Bugs visibly drift off the brown road tiles in Bug Defense due to a flawed axis-locking heuristic in `Bug.swift:292-314`. The current algorithm infers segment direction from grid coordinate deltas and then locks axes in world coordinates, causing visible position snaps when bugs are slightly off-path or rounding corners. The fix requires replacing the segment-type detection with simple vector-based movement that always moves directly toward the target waypoint, following the proven pattern from `Hero.swift:110-127`.

## Current Algorithm Analysis

### Algorithm Flow (`Bug.swift:254-316`)

The bug movement system follows this sequence every frame:

```
1. Guard check: pathIndex < movementPath.count (line 255)
   └─ Exit early if path is complete

2. Handle burrowing behavior (lines 257-270)
   └─ Independent feature, not related to movement drift

3. Get target waypoint and convert to world coordinates (lines 272-273)
   targetGridPos = movementPath[pathIndex]
   targetWorldPos = targetGridPos.toWorldPosition()

4. Calculate distance to target (lines 276-278)
   dx = targetWorldPos.x - position.x
   dy = targetWorldPos.y - position.y
   distance = sqrt(dx * dx + dy * dy)

5. Check if waypoint reached: distance < 2 (line 280)
   YES → Snap to exact position and increment pathIndex (lines 282-284)
   NO → Calculate movement (lines 289-314)

6. Movement calculation (THE PROBLEM AREA):
   a. Calculate previous grid position (line 293)
      prevGridPos = pathIndex > 1 ? movementPath[pathIndex - 1] : gridPosition

   b. Calculate grid deltas (lines 294-295)
      deltaX = abs(targetGridPos.x - prevGridPos.x)
      deltaY = abs(targetGridPos.y - prevGridPos.y)

   c. Branch based on grid deltas:

      IF deltaX > 0 AND deltaY > 0 (line 298):
         → DIAGONAL branch
         normalizedDx = dx / distance
         normalizedDy = dy / distance
         position.x += normalizedDx * moveDistance
         position.y += normalizedDy * moveDistance

      ELSE IF deltaX > deltaY (line 304):
         → HORIZONTAL branch
         moveX = min(abs(dx), moveDistance) * (dx > 0 ? 1 : -1)
         position.x += moveX
         position.y = targetWorldPos.y  // ⚠️ AXIS LOCK - SNAP Y COORDINATE

      ELSE (line 309):
         → VERTICAL branch
         moveY = min(abs(dy), moveDistance) * (dy > 0 ? 1 : -1)
         position.y += moveY
         position.x = targetWorldPos.x  // ⚠️ AXIS LOCK - SNAP X COORDINATE
```

### Key Variables Involved

From `Bug.swift:127-135`:
- `position: CGPoint` - World coordinates of bug sprite (e.g., x: 120.0, y: 180.0)
- `gridPosition: GridPosition` - Current grid tile (e.g., GridPosition(3, 4))
- `movementPath: [GridPosition]` - Array of waypoints from spawn to house
- `pathIndex: Int` - Index of current target waypoint in movementPath
- `moveSpeed: CGFloat` - Base speed from bug type (e.g., ant=60, wasp=120)
- `slowFactor: CGFloat` - Multiplier from traps/cards (default 1.0, can be <1.0 for slowed bugs)

### Movement Branches Detailed

#### Diagonal Branch (Lines 298-303) - CORRECT
```swift
if deltaX > 0 && deltaY > 0 {
    let normalizedDx = dx / distance
    let normalizedDy = dy / distance
    position.x += normalizedDx * moveDistance
    position.y += normalizedDy * moveDistance
}
```
**What it does:** Uses normalized direction vector to move proportionally in both X and Y.
**Why it's correct:** Always moves directly toward target, no axis assumptions.
**Problem:** Only triggers when BOTH grid deltas are non-zero. Misses cases where bug needs to correct position errors or is between waypoints.

#### Horizontal Branch (Lines 304-308) - FLAWED
```swift
else if deltaX > deltaY {
    let moveX = min(abs(dx), moveDistance) * (dx > 0 ? 1 : -1)
    position.x += moveX
    position.y = targetWorldPos.y  // ⚠️ SNAP!
}
```
**What it does:** Assumes segment is horizontal, locks Y axis to target, moves only in X.
**Why it's flawed:** Snaps Y coordinate immediately, assuming bug is already aligned horizontally.
**When it breaks:** When bug's current position has Y ≠ targetWorldPos.y (common during corner turns).

#### Vertical Branch (Lines 309-314) - FLAWED
```swift
else {
    let moveY = min(abs(dy), moveDistance) * (dy > 0 ? 1 : -1)
    position.y += moveY
    position.x = targetWorldPos.x  // ⚠️ SNAP!
}
```
**What it does:** Assumes segment is vertical, locks X axis to target, moves only in Y.
**Why it's flawed:** Snaps X coordinate immediately, assuming bug is already aligned vertically.
**When it breaks:** When bug's current position has X ≠ targetWorldPos.x (common during corner turns).

## Root Cause: Axis-Locking Heuristic Flaw

### The Fundamental Problem

The algorithm uses **grid coordinate deltas** between waypoints to infer segment type (horizontal/vertical/diagonal), then applies **world coordinate axis locks** based on that inference. This creates a **geometric mismatch** between the decision criteria and the action taken.

**The Core Issue:**
- **Decision:** Based on `abs(targetGridPos.x - prevGridPos.x)` vs `abs(targetGridPos.y - prevGridPos.y)` (GRID SPACE)
- **Action:** Locks `position.x` or `position.y` (WORLD SPACE)
- **Assumption:** Bug is already aligned with the inferred axis
- **Reality:** Bug position might not be aligned due to overshooting, position errors, or corner transitions

### Concrete Failure Example

**Scenario: Bug rounding a corner from horizontal to vertical segment**

```
Path waypoints: [(1,3), (2,3), (3,3), (3,4), (3,5)]
                 start   →→→→→   corner  ↑↑↑   end

Current state:
  Bug world position: (118.0, 140.0)  // Slightly off due to previous frame
  Bug grid position: (2, 3)
  pathIndex: 3  // Targeting waypoint (3,4)

Target waypoint: GridPosition(3, 4)
Target world position: (140.0, 180.0)

Previous waypoint: movementPath[2] = GridPosition(3, 3)

Grid deltas:
  deltaX = abs(3 - 3) = 0
  deltaY = abs(4 - 3) = 1

Branch selected: deltaX < deltaY → VERTICAL branch (lines 309-314)

Vertical branch executes:
  position.x = targetWorldPos.x = 140.0  // ⚠️ INSTANT SNAP from 118.0 → 140.0!
  position.y += moveY  // Normal movement

Visual result: Bug "pops" 22 pixels to the right instantly, then moves up.
              This is visible as drifting off the path or cutting corners.
```

### Why This Approach Fails Geometrically

**Grid deltas tell us:** The direction from the previous waypoint to the target waypoint.

**Grid deltas DO NOT tell us:** The direction from the bug's CURRENT position to the target waypoint.

**The axis lock assumes:** Bug is already on the segment's primary axis (e.g., Y aligned for horizontal movement).

**This assumption breaks when:**
1. Bug overshoots a waypoint slightly (deltaTime * high speed > remaining distance)
2. Bug has accumulated tiny position errors from floating-point arithmetic
3. Bug is transitioning from one segment type to another (corners)
4. Bug was slowed/sped during previous frame, affecting position

**Mathematical explanation:**

Current approach:
```
if (gridDelta_x > gridDelta_y):
    lock position.y = target.y  // Assumes bug.y already equals target.y
    move position.x toward target.x
```

This is geometrically incorrect when `bug.position.y ≠ target.y`, which is common.

Correct approach:
```
direction = normalize(target - bug.position)  // Direction from CURRENT position
bug.position += direction * speed * dt        // Move toward target
```

This always moves directly toward the target, regardless of segment orientation.

## Failure Modes

### 1. Curved Paths (Horizontal → Vertical Turns)

**When:** Bug approaches a corner waypoint (e.g., Map 1 "Winding Road", Map 8 "U-Turns")

**What happens:**
- Bug moves horizontally with Y-axis locked
- Reaches corner waypoint, pathIndex increments
- Next segment is vertical, X-axis gets locked
- **SNAP:** X position instantly jumps to target X coordinate
- Bug appears to "cut the corner" or drift off the brown road tiles

**Severity:** HIGH - Most visible on maps with many turns (Map 1, Map 8)

**Example trace:**
```
Frame N:   position=(118, 120), target=(140, 120) [horizontal segment]
           → Y locked to 120, move X toward 140
Frame N+1: position=(138, 120), target=(140, 120)
           → Distance < 2, snap to (140, 120), pathIndex++
Frame N+2: position=(140, 120), target=(140, 160) [vertical segment]
           → X locked to 140 ✓ (already aligned, no snap)

BUT if bug was slightly off:
Frame N+1: position=(141, 119), target=(140, 120) [overshooting case]
           → Distance < 2, snap to (140, 120), pathIndex++
Frame N+2: position=(140, 120), target=(140, 160) [vertical segment]
           → X locked to 140 ✓ (snap fixed it)

REAL FAILURE CASE:
Frame N:   position=(138, 122), target=(140, 120) [was off by 2 in Y]
Frame N+1: position=(139.5, 120), target=(140, 120) [Y snapped but X didn't reach]
Frame N+2: position=(140, 120), target=(140, 160) [got lucky, snap aligned it]

WORSE CASE:
Frame N:   position=(137, 122), target=(140, 120)
           → Horizontal branch: Y snaps to 120 ✓, X moves toward 140
Frame N+1: position=(139, 120), target=(140, 120)
           → Still moving, but now aligned
Frame N+2: position=(140, 120), target=(140, 160)
           → Vertical branch: X locks to 140 ✓

The issue: If bug doesn't complete the horizontal segment in one frame,
          the Y snap happens BEFORE bug reaches the corner waypoint.
          Bug visually "slides" onto the horizontal line instead of
          following a smooth curve.
```

### 2. High-Speed Bugs Overshooting Waypoints

**When:** Fast bugs (spider=100, wasp=120) or wave-scaled speeds during high deltaTime frames

**What happens:**
- Bug approaches waypoint with high `moveDistance = speed * slowFactor * deltaTime`
- `distance < 2` check (line 280) triggers snap to exact waypoint ✓ (This works)
- **BUT:** If bug was off-path before snap, the axis lock on PREVIOUS frames caused visible drift
- Snap logic FIXES the position at waypoints but doesn't prevent drift BETWEEN waypoints

**Severity:** MEDIUM - Drift is less visible for fast bugs (they move quickly), but accumulates over multiple waypoints

**Why axis locks make this worse:**
- Fast bug moves 5-10 pixels per frame
- Axis lock snaps perpendicular axis immediately
- If bug was off by 3 pixels, snap is visible as a "jerk"
- Multiple snaps create stuttering visual effect

### 3. Diagonal Segments (Map 15 "Diagonal")

**When:** Path includes diagonal tiles where both X and Y change: `[(2,12), (3,11), (4,10), (5,9)]`

**What happens:**
- Grid deltas: `deltaX = 1`, `deltaY = 1`
- Diagonal branch triggers (line 298) ✓ - Uses normalization, so this actually WORKS
- **No issue here!** The diagonal branch is geometrically correct.

**Severity:** NONE for pure diagonal segments

**However:** Mixed diagonal-orthogonal paths can still fail:
```
Path: [(2,12), (3,11), (4,10), (5,10), (6,10)]  // Diagonal then horizontal

At waypoint (4,10) → (5,10):
  deltaX = 1, deltaY = 0 → Horizontal branch
  Y axis locked → If bug is slightly off in Y, SNAP occurs
```

### 4. Segment-Type Detection Logic Flaw

**When:** Always - the logic itself is flawed, not just edge cases

**The problem:** Branch selection based on grid deltas doesn't account for:

1. **Bug between waypoints:** When bug is at world position (135, 145) but gridPosition is (3,3) and targeting (3,4):
   - `prevGridPos = gridPosition = (3,3)` (line 293)
   - `targetGridPos = (3,4)`
   - `deltaX = 0, deltaY = 1` → Vertical branch
   - But bug might not be aligned at X=140 yet! Snap occurs.

2. **Position error accumulation:** Floating-point errors or previous frame's slowFactor changes:
   - Bug should be at (140, 160) but is at (139.8, 160.1)
   - On next waypoint, axis lock snaps to new coordinate
   - Small errors accumulate into visible drift

3. **Frame timing variance:** Different deltaTime values between frames:
   - Frame 1: deltaTime=0.016 → moves 6 pixels
   - Frame 2: deltaTime=0.020 → moves 7.5 pixels
   - Inconsistent progress can cause bug to be off-axis when branch changes

**Severity:** HIGH - This is the root cause affecting all other failure modes

## Path System Verification

### expandPath() Analysis (`MapConfiguration.swift:71-103`)

**Algorithm:**
```swift
private static func expandPath(_ waypoints: [GridPosition]) -> [GridPosition] {
    guard waypoints.count >= 2 else { return waypoints }
    var expandedPath: [GridPosition] = [waypoints[0]]

    for i in 1..<waypoints.count {
        let start = waypoints[i - 1]
        let end = waypoints[i]
        let dx = end.x - start.x
        let dy = end.y - start.y
        let steps = max(abs(dx), abs(dy))  // ✓ Correctly handles orthogonal AND diagonal

        if steps == 0 { continue }

        for step in 1...steps {
            let x = start.x + (dx * step) / steps  // ✓ Linear interpolation
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

**Verification Results:**

✅ **Path expansion is CORRECT**
- Uses `max(abs(dx), abs(dy))` to calculate steps → Handles both orthogonal and diagonal segments
- Linear interpolation fills ALL intermediate tiles → No gaps possible
- Duplicate prevention ensures clean path array
- Works for horizontal: `steps = max(5, 0) = 5` → 5 intermediate tiles
- Works for vertical: `steps = max(0, 4) = 4` → 4 intermediate tiles
- Works for diagonal: `steps = max(3, 3) = 3` → 3 intermediate tiles

**Tested mentally with Map 1 (Winding Road):**
- Sparse waypoints: `[(1,1), (5,1), (5,5), (10,5)]`
- Expansion: `[(1,1), (2,1), (3,1), (4,1), (5,1), (5,2), (5,3), (5,4), (5,5), (6,5), (7,5), (8,5), (9,5), (10,5)]`
- Every tile included ✓

**Tested mentally with Map 15 (Diagonal):**
- Diagonal segment: `[(2,12), (5,9)]`
- `dx=3, dy=-3, steps=max(3,3)=3`
- Expansion: `[(2,12), (3,11), (4,10), (5,9)]`
- All diagonal tiles included ✓

**Conclusion:** The movement drift is NOT caused by path definition. Paths are geometrically correct and complete. The issue is purely in the movement algorithm (`Bug.swift:292-314`).

## Geometric Analysis of Position Drift

### Mathematical Explanation

**Current approach (FLAWED):**
```
segmentType = inferFromGridDeltas(prevWaypoint, targetWaypoint)
if segmentType == HORIZONTAL:
    lock bug.position.y = target.y  // Assumes bug.y already equals target.y
    move bug.position.x toward target.x
```

**Why this fails mathematically:**

Given:
- Bug current position: `P = (Px, Py)` in world coordinates
- Target waypoint: `T = (Tx, Ty)` in world coordinates
- Previous waypoint: `Pprev` in grid coordinates (not world!)

The algorithm:
1. Calculates `gridDelta = targetGrid - prevGrid` (in GRID SPACE)
2. Infers segment orientation from `gridDelta`
3. Applies axis lock to `P` (in WORLD SPACE)

**The mismatch:**
- `gridDelta` describes the path segment from `Pprev` to `T`
- But `P` is the bug's CURRENT position, which may not lie on the line from `Pprev` to `T`
- Locking an axis forces `P` onto the line, but does so instantly (snap), not smoothly

**Example of geometric incorrectness:**

```
Pprev = GridPosition(2, 3) → world (100, 140)
T = GridPosition(3, 3) → world (140, 140)
P_current = (118, 142)  // Bug is 2 pixels above the line

gridDelta = (1, 0) → horizontal segment detected
Axis lock: P.y = T.y = 140  // SNAP from 142 → 140
Result: Bug visibly "drops" 2 pixels instantly
```

**Correct approach (SMOOTH):**

```
direction = normalize(T - P)  // Direction from current position to target
P += direction * speed * deltaTime  // Move toward target smoothly
```

Using the same example:
```
P_current = (118, 142)
T = (140, 140)
delta = T - P = (22, -2)
distance = sqrt(22² + 2²) = sqrt(488) ≈ 22.09
direction = (22/22.09, -2/22.09) ≈ (0.995, -0.091)

If speed * deltaTime = 5:
P_next = P + direction * 5 = (118 + 4.975, 142 - 0.455) = (122.975, 141.545)

Next frame:
delta = (140, 140) - (122.975, 141.545) = (17.025, -1.545)
distance ≈ 17.09
direction ≈ (0.996, -0.090)
P_next = (122.975 + 4.98, 141.545 - 0.45) = (127.955, 141.095)

... bug smoothly moves toward (140, 140) in both X and Y simultaneously
```

**Key insight:** The correct approach calculates direction from CURRENT position, not from previous waypoint. This ensures smooth movement even when bug is off-path.

### Why Axis Locks Fail on Curves

**At a corner waypoint:**

```
Path: [..., (2,3), (3,3), (3,4), ...]
                  corner

Bug approaching (3,3) horizontally from (2,3):
  - Horizontal branch active: Y locked to 140 (y-coordinate of row 3)
  - Bug reaches (3,3), pathIndex increments to target (3,4)

Bug now targeting (3,4) vertically:
  - Vertical branch activates: X locked to 140 (x-coordinate of column 3)
  - IF bug.x was already 140 → smooth transition ✓
  - IF bug.x was 139.5 due to timing → SNAP to 140 ✗ (visible jerk)
```

**The problem at corners:**
- Axis locks ASSUME perfect alignment at waypoint arrival
- The `distance < 2` check snaps position (line 282), which should fix this
- **BUT:** If bug doesn't trigger the snap (e.g., approaches waypoint at an angle due to previous drift), the axis lock on the NEW segment snaps BEFORE the waypoint is reached

**Real-world corner scenario:**

```
Frame N-2: Bug at (136, 138), target (140, 140) [horizontal segment]
           distance = 5.66, no snap, horizontal branch
           Y locked to 140 → position becomes (136, 140) [SNAP!]
           X moves toward 140 → position becomes (138, 140)

Frame N-1: Bug at (138, 140), target (140, 140)
           distance = 2, no snap yet (≥ 2)
           Horizontal branch: Y=140 ✓, X moves → (140, 140)

Frame N:   Bug at (140, 140), target (140, 140)
           distance = 0 < 2 → SNAP to (140, 140), pathIndex++

Frame N+1: Bug at (140, 140), target (140, 180) [vertical segment]
           distance = 40
           Vertical branch: X locked to 140 ✓ (already aligned)
           Y moves toward 180 → (140, 142)
```

In this scenario, the system worked because the snap happened before the corner. But if Frame N-2 had bug at (136, 141) instead of (136, 138):

```
Frame N-2: Bug at (136, 141), target (140, 140)
           Horizontal branch: Y locked to 140 → (136, 140) [SNAP from 141!]
```

The snap is visible as a 1-pixel "jerk" downward. Multiple such snaps across a path create the "drifting off road" visual effect.

## Recommended Solution

### Vector-Based Movement (Hero.swift Pattern)

**Replace lines 292-314 with:**

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

### Why This Approach Is Correct

**1. Geometric correctness:**
- Direction vector `(dx, dy)` points from current position to target
- Normalization via `ratio = moveDistance / distance` ensures speed is constant
- Bug ALWAYS moves directly toward target, regardless of path shape

**2. Handles all path types:**
- Horizontal segments: `dy ≈ 0`, so `ratio * dy ≈ 0`, Y changes minimally ✓
- Vertical segments: `dx ≈ 0`, so `ratio * dx ≈ 0`, X changes minimally ✓
- Diagonal segments: Both `dx` and `dy` non-zero, both update proportionally ✓
- Curved paths: Direction recalculates each frame based on CURRENT position ✓

**3. No axis assumptions:**
- Never assumes bug is already aligned with any axis
- Works even if bug is off-path due to previous errors
- Naturally corrects position errors over time

**4. Mathematical equivalence to normalization:**

The ratio approach: `position += delta * (moveDistance / distance)`

Is equivalent to: `position += normalize(delta) * moveDistance`

Because: `normalize(delta) = delta / distance`

Therefore: `delta * (moveDistance / distance) = normalize(delta) * moveDistance` ✓

**5. Proven pattern:**

From `Hero.swift:110-127`:
```swift
let dx = targetWorldPos.x - position.x
let dy = targetWorldPos.y - position.y
let distance = sqrt(dx * dx + dy * dy)

if distance < 5.0 {
    position = targetWorldPos
    currentGridPosition = target
    targetPosition = nil
} else {
    let moveDistance = moveSpeed * CGFloat(deltaTime)
    let ratio = min(1.0, moveDistance / distance)
    position.x += dx * ratio
    position.y += dy * ratio
}
```

Hero movement is smooth and doesn't drift. Same logic should apply to bugs.

### What to Preserve

**Keep unchanged:**
- Lines 255-270: Guard check and burrowing logic (unrelated to drift)
- Lines 272-278: Target waypoint and distance calculation (correct)
- Lines 280-285: Waypoint snap logic (prevents division by zero, ensures exact positioning at waypoints)

**Remove entirely:**
- Lines 292-296: Segment direction detection from grid deltas
- Lines 297-314: Three-branch movement logic (diagonal/horizontal/vertical)

**Result:** Simpler, more maintainable code that is geometrically correct.

### Performance Considerations

**Computational complexity:** O(1) per frame per bug (same as current)

**Operations comparison:**

Current approach:
- 2x grid position lookups
- 2x abs() calls (deltaX, deltaY)
- 2-3 comparisons for branching
- 1x sqrt() for distance
- 2-3 arithmetic operations per branch
- **Total: ~10-12 operations**

Proposed approach:
- 1x sqrt() for distance
- 3x divisions (ratio calculation, implicit in multiplication)
- 2x additions for position update
- **Total: ~6 operations**

**Proposed approach is actually SIMPLER and potentially faster!**

No performance concerns. The sqrt() call was already present (line 278), so no new overhead.

## Test Scenarios for Implementation (TASK1)

### Unit Tests (Tests/BugDefenseTests/)

**Test framework:** XCTest
**Test command:** `swift test`
**Pattern:** Follow `BugDefenseTests.swift:1-100` for structure

#### 1. Straight Horizontal Path Test
```swift
@MainActor
func testBugMovementHorizontalPath() {
    // Given: Bug with horizontal path
    let bug = Bug(type: .ant, health: 20, damage: 5, difficulty: 1.0)
    let path: [GridPosition] = [
        GridPosition(x: 1, y: 5),
        GridPosition(x: 2, y: 5),
        GridPosition(x: 3, y: 5),
        GridPosition(x: 4, y: 5),
        GridPosition(x: 5, y: 5)
    ]
    bug.setPath(path)

    let initialY = bug.position.y

    // When: Update multiple times
    for _ in 0..<20 {
        bug.update(deltaTime: 0.016, pathfindingGrid: PathfindingGrid())
    }

    // Then: Y coordinate remains constant (within tolerance)
    XCTAssertEqual(bug.position.y, initialY, accuracy: 1.0)

    // And: Bug progresses in X direction
    XCTAssertGreaterThan(bug.position.x, path[0].toWorldPosition().x)
}
```

#### 2. Straight Vertical Path Test
```swift
@MainActor
func testBugMovementVerticalPath() {
    // Given: Bug with vertical path
    let bug = Bug(type: .ant, health: 20, damage: 5, difficulty: 1.0)
    let path: [GridPosition] = [
        GridPosition(x: 5, y: 1),
        GridPosition(x: 5, y: 2),
        GridPosition(x: 5, y: 3),
        GridPosition(x: 5, y: 4),
        GridPosition(x: 5, y: 5)
    ]
    bug.setPath(path)

    let initialX = bug.position.x

    // When: Update multiple times
    for _ in 0..<20 {
        bug.update(deltaTime: 0.016, pathfindingGrid: PathfindingGrid())
    }

    // Then: X coordinate remains constant
    XCTAssertEqual(bug.position.x, initialX, accuracy: 1.0)

    // And: Bug progresses in Y direction
    XCTAssertGreaterThan(bug.position.y, path[0].toWorldPosition().y)
}
```

#### 3. L-Shaped Curved Path Test (CRITICAL)
```swift
@MainActor
func testBugMovementCurvedPath() {
    // Given: Bug with L-shaped path (corner turn)
    let bug = Bug(type: .ant, health: 20, damage: 5, difficulty: 1.0)
    let path: [GridPosition] = [
        GridPosition(x: 1, y: 3),
        GridPosition(x: 2, y: 3),
        GridPosition(x: 3, y: 3),  // Corner waypoint
        GridPosition(x: 3, y: 4),
        GridPosition(x: 3, y: 5)
    ]
    bug.setPath(path)

    var positions: [CGPoint] = []

    // When: Update and record positions
    for _ in 0..<50 {
        positions.append(bug.position)
        bug.update(deltaTime: 0.016, pathfindingGrid: PathfindingGrid())
    }

    // Then: No sudden position jumps (max delta < 5 pixels per frame)
    for i in 1..<positions.count {
        let deltaX = abs(positions[i].x - positions[i-1].x)
        let deltaY = abs(positions[i].y - positions[i-1].y)
        XCTAssertLessThan(deltaX, 5.0, "Sudden X jump at frame \(i)")
        XCTAssertLessThan(deltaY, 5.0, "Sudden Y jump at frame \(i)")
    }

    // And: Bug reaches the last waypoint
    XCTAssertEqual(bug.gridPosition, path.last!)
}
```

#### 4. Diagonal Path Test
```swift
@MainActor
func testBugMovementDiagonalPath() {
    // Given: Bug with diagonal path (Map 15 style)
    let bug = Bug(type: .ant, health: 20, damage: 5, difficulty: 1.0)
    let path: [GridPosition] = [
        GridPosition(x: 2, y: 12),
        GridPosition(x: 3, y: 11),
        GridPosition(x: 4, y: 10),
        GridPosition(x: 5, y: 9)
    ]
    bug.setPath(path)

    // When: Update until bug reaches end
    for _ in 0..<100 {
        bug.update(deltaTime: 0.016, pathfindingGrid: PathfindingGrid())
        if bug.gridPosition == path.last! { break }
    }

    // Then: Bug reaches last waypoint
    XCTAssertEqual(bug.gridPosition, path.last!)

    // And: Bug position matches world position of last waypoint
    XCTAssertEqual(bug.position.x, path.last!.toWorldPosition().x, accuracy: 2.0)
    XCTAssertEqual(bug.position.y, path.last!.toWorldPosition().y, accuracy: 2.0)
}
```

#### 5. Fast Bug Test (High Speed)
```swift
@MainActor
func testFastBugDoesNotSkipWaypoints() {
    // Given: Fast bug (wasp) with path
    let bug = Bug(type: .wasp, health: 25, damage: 12, difficulty: 1.0)
    let path: [GridPosition] = [
        GridPosition(x: 1, y: 3),
        GridPosition(x: 2, y: 3),
        GridPosition(x: 3, y: 3),
        GridPosition(x: 4, y: 3),
        GridPosition(x: 5, y: 3)
    ]
    bug.setPath(path)

    // When: Update with larger deltaTime (simulate frame drops)
    for _ in 0..<30 {
        bug.update(deltaTime: 0.033, pathfindingGrid: PathfindingGrid())
    }

    // Then: Bug completes path without skipping waypoints
    XCTAssertEqual(bug.gridPosition, path.last!)
}
```

#### 6. Slow Bug Test (Low Speed)
```swift
@MainActor
func testSlowBugMovementIsSmooth() {
    // Given: Slow bug with slow factor
    let bug = Bug(type: .beetle, health: 50, damage: 10, difficulty: 1.0)
    bug.applySlow(factor: 0.1, duration: 10.0)  // Very slow
    let path: [GridPosition] = [
        GridPosition(x: 1, y: 3),
        GridPosition(x: 2, y: 3),
        GridPosition(x: 3, y: 3)
    ]
    bug.setPath(path)

    var positions: [CGPoint] = []

    // When: Update and record positions
    for _ in 0..<100 {
        positions.append(bug.position)
        bug.update(deltaTime: 0.016, pathfindingGrid: PathfindingGrid())
    }

    // Then: Bug makes steady progress (no jitter)
    var totalDistance = 0.0
    for i in 1..<positions.count {
        let dx = positions[i].x - positions[i-1].x
        let dy = positions[i].y - positions[i-1].y
        totalDistance += sqrt(dx*dx + dy*dy)
    }
    XCTAssertGreaterThan(totalDistance, 10.0, "Bug should make some progress")

    // And: No backward movement
    XCTAssertGreaterThanOrEqual(positions.last!.x, positions.first!.x)
}
```

### Manual Testing (Visual Verification)

**Maps to test:**
1. **Map 1 (Winding Road):** Multiple curves, comprehensive path
2. **Map 8 (U-Turns):** Sharp reversals, critical for corner testing
3. **Map 15 (Diagonal):** Diagonal segments, verify straight-line movement

**What to observe:**
- Bugs stay centered on brown road tiles throughout entire path
- No visible "pops" or "jumps" when rounding corners
- Smooth movement even at high wave numbers (speed scaling)
- No stuttering or jittering on straight segments

**Test procedure:**
1. Build project: `swift build`
2. Run game: `open BugDefense.app` or `swift run`
3. Select each test map
4. Start waves and observe bug movement
5. Pay special attention to corners and high-speed bugs

---

## Summary

**Root cause:** Axis-locking heuristic in `Bug.swift:292-314` infers segment direction from grid coordinate deltas and snaps world coordinates, causing visible position jumps when bugs are off-path or rounding corners.

**Path system:** Verified correct (`MapConfiguration.swift:71-103` expandPath() includes all intermediate tiles).

**Solution:** Replace segment detection and axis-locking logic with simple vector-based movement using normalized direction from current position to target waypoint, following the proven pattern from `Hero.swift:110-127`.

**Complexity:** LOW - Localized fix, simpler code, same performance, well-defined test strategy.

**Next step:** TASK1 will implement the fix and run comprehensive tests to verify smooth movement across all path types.
