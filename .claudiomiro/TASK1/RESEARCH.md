# Research for TASK1

## Context Reference
**For tech stack and conventions, see:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/TASK.md` - Task-level context
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/PROMPT.md` - Task-specific context

**This file contains ONLY new information discovered during research.**

---

## Task Understanding Summary
Replace the flawed axis-locking heuristics in Bug.swift:292-315 with normalized vector-based movement to eliminate path drift and ensure bugs stay on road tiles at all times.

---

## Files Discovered to Read/Modify
[ONLY files found during research NOT already in PROMPT.md]

### Already Identified in PROMPT.md:
- `Sources/BugDefense/Bug.swift:254-316` - Main modification target
- `Sources/BugDefense/GameConfiguration.swift:169-182` - GridPosition struct (read-only)
- `Sources/BugDefense/MapConfiguration.swift:71-103` - Path expansion (read-only)
- `Tests/BugDefenseTests/BugDefenseTests.swift:125-185` - Test pattern reference

### New Files Discovered:
- `Sources/BugDefense/Bug.swift:240-252` - `setPath()` method (read-only, important for understanding pathIndex initialization)
- `Sources/BugDefense/GameScene.swift:386-395` - Bug.update() call site in game loop (integration point)
- `Sources/BugDefense/GameScene.swift:488-504` - Bug spawning and path assignment (integration point)

---

## Code Patterns Found

### 1. Vector Normalization Pattern - ALREADY EXISTS in Bug.swift
**Location:** `Sources/BugDefense/Bug.swift:298-303`
```swift
if deltaX > 0 && deltaY > 0 {
    // Diagonal movement - move along both axes toward target
    let normalizedDx = dx / distance
    let normalizedDy = dy / distance
    position.x += normalizedDx * moveDistance
    position.y += normalizedDy * moveDistance
}
```
**Key Finding:** The codebase ALREADY uses normalized vector movement for diagonal segments! The issue is that it only applies this correct approach to diagonals, while horizontal/vertical segments use flawed axis-locking. **Solution: Apply this normalization pattern to ALL movement, not just diagonals.**

### 2. Distance Calculation Pattern - Used Throughout Codebase
**Consistent Pattern Found:**
- `Bug.swift:278` - `let distance = sqrt(dx * dx + dy * dy)`
- `Hero.swift:113` - Same pattern for hero movement
- `DefenseStructure.swift:374` - Same pattern for tower targeting
- `DefenseStructure.swift:428, 442, 486, 512, 560` - Repeated pattern

**Pattern:** All distance calculations use the same Euclidean distance formula. No utility function exists - inline calculation is the convention.

### 3. Movement Snap Pattern - Hero Movement Reference
**Location:** `Sources/BugDefense/Hero.swift:115-127`
```swift
if distance < 5.0 {
    // Reached target
    position = targetWorldPos
    currentGridPosition = target
    targetPosition = nil
    isMoving = false
} else {
    // Move toward target
    let moveDistance = moveSpeed * CGFloat(deltaTime)
    let ratio = min(1.0, moveDistance / distance)
    position.x += dx * ratio
    position.y += dy * ratio
}
```
**Key Learning:** Hero uses a `ratio` approach instead of normalization. However, Bug's current diagonal code uses normalization (divide by distance), which is simpler and already established in the codebase for bugs.

### 4. Test Pattern - XCTest with @MainActor
**Location:** `Tests/BugDefenseTests/BugDefenseTests.swift:1-4, 24-42`
```swift
import XCTest
@testable import BugDefense

final class BugDefenseTests: XCTestCase {
    @MainActor
    func testGameStateManager() {
        // Test implementation
    }
}
```
**Pattern:** Tests use `@MainActor` annotation when testing SpriteKit nodes (Bug is SKShapeNode). Non-SpriteKit tests (like testGridPositionConversion:6-15) don't need @MainActor.

---

## Integration & Impact Analysis

### Functions/Classes/Components Being Modified:

#### 1. `Bug.update(deltaTime:pathfindingGrid:)` in `Sources/BugDefense/Bug.swift:254-316`
- **Called by:**
  - `GameScene.swift:391` - Main game loop, called every frame for each bug
  - Context: `for bug in bugs { bug.update(deltaTime: deltaTime, pathfindingGrid: pathfindingGrid) }`

- **Parameter contract:**
  ```swift
  func update(deltaTime: TimeInterval, pathfindingGrid: PathfindingGrid)
  ```
  - `deltaTime: TimeInterval` - Time since last frame (typically 0.016s for 60fps)
  - `pathfindingGrid: PathfindingGrid` - Grid for A* pathfinding (NOT used by ground bugs)

- **Impact:** Callers expect NO CHANGES to method signature. All bug types use this method.

- **Breaking changes:** NO
  - Method signature unchanged
  - Property updates preserved (`position`, `gridPosition`, `pathIndex`)
  - Return type: void (no return value to break)

#### 2. Properties Updated During Movement:
- `position: CGPoint` - Bug's world position (SpriteKit coordinate)
  - **Observers:** SpriteKit rendering system, DefenseStructure.swift:371-374, Hero.swift:141-143
  - **Contract:** Must be valid CGPoint, updated each frame

- `gridPosition: GridPosition` - Bug's grid position
  - **Observers:** GameScene.swift:394 (`bug.hasReachedHouse()` uses this internally)
  - **Contract:** Must sync with position when waypoint reached

- `pathIndex: Int` - Current waypoint index
  - **Observers:** Internal to Bug class only
  - **Contract:** Increments from 0 to movementPath.count

#### 3. Integration with Path System:
- **Path Assignment:** `GameScene.swift:495-500`
  ```swift
  let roadPath = MapManager.shared.getCurrentRoadPath()
  bug.setPath(roadPath)
  ```
- **setPath Behavior:** `Bug.swift:240-252`
  - Sets `movementPath` to provided path
  - Positions bug at first waypoint exactly
  - Sets `pathIndex = 1` (already at waypoint 0, targeting waypoint 1)

- **Impact:** Movement algorithm must handle pathIndex starting at 1, not 0

### API/Database/External Integration:
N/A - This is a local game with no API or database dependencies

### Special Behavior Preservation:
1. **Burrowing:** `Bug.swift:258-270` - MUST remain unchanged
   - Affects `burrower` bug type only
   - Modifies visual alpha, sets `isBurrowed` flag
   - DefenseStructure.swift:137 and Hero.swift:137 check `isBurrowed` to skip targeting

2. **Flying Bugs:** Use same update method but may have different pathfinding in future
   - Currently follow same road path as ground bugs (verified in tests)
   - No special handling needed, but preserve structure

---

## Test Strategy Discovered

### Testing Framework
- **Framework:** XCTest
- **Test command:** `swift test --filter BugDefenseTests`
- **Config:** No explicit config file found (uses Swift Package Manager defaults)

### Test File Pattern
- **Location:** `Tests/BugDefenseTests/BugDefenseTests.swift`
- **Pattern:** Single test file containing all tests
- **Structure:** One class `BugDefenseTests: XCTestCase` with multiple test functions

### Test Structure Pattern
**Found in:** `Tests/BugDefenseTests/BugDefenseTests.swift:125-185`

```swift
@MainActor  // Required for SKNode testing
func testBugSpawningWithRoadPath() {
    // Arrange
    let startPos = GridPosition(x: 0, y: 0)
    let antBug = Bug(type: .ant, at: startPos, wave: 1, difficulty: .normal)
    let roadPath = [GridPosition(x: 0, y: 0), GridPosition(x: 1, y: 0), ...]

    // Act
    antBug.setPath(roadPath)

    // Assert
    XCTAssertEqual(antBug.gridPosition, roadPath.first)
}
```

### Assertion Patterns Used:
- `XCTAssertEqual(actual, expected)` - Exact equality
- `XCTAssertTrue(condition, message)` - Boolean conditions with messages
- `XCTAssertGreaterThan(value1, value2)` - Numeric comparisons
- `XCTAssertFalse(condition, message)` - Negative boolean assertions

### Mock/Test Data Pattern:
**No mock framework found.** Tests create real instances:
```swift
let bug = Bug(type: .ant, at: GridPosition(x: 0, y: 0), wave: 1, difficulty: .normal)
let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
```

### Coverage Expectations:
- No coverage tool configuration found
- Expect to test changed lines directly with unit tests
- Manual testing documented in TODO.md Item 3

---

## Risks & Challenges Identified

### Technical Risks

1. **Division by Zero / NaN from Normalization**
   - **Likelihood:** Low
   - **Impact:** High (crashes or corrupted positions)
   - **Evidence:** Current code already has distance check at line 280 (`if distance < 2`)
   - **Mitigation:** Keep the distance threshold check BEFORE normalization. When distance < 2, snap directly to target instead of normalizing.
   - **Fallback:** If issues occur, increase snap threshold from 2.0 to 5.0

2. **Performance Regression from sqrt() Calls**
   - **Likelihood:** Very Low
   - **Impact:** Medium (frame rate drops)
   - **Evidence:** Current code already calls sqrt() at line 278. Hero.swift and DefenseStructure.swift call sqrt() every frame for all entities. This is standard game math.
   - **Mitigation:** Maintain O(1) complexity. One sqrt per bug per frame is acceptable (verified by existing usage patterns).
   - **Fallback:** Profile with Instruments if performance issues arise

3. **Burrowing Behavior Regression**
   - **Likelihood:** Very Low
   - **Impact:** High (breaks burrower bug type)
   - **Evidence:** Burrowing code is in lines 258-270, completely separate from movement calculation (lines 276-315)
   - **Mitigation:** Only modify lines 292-315. Do NOT touch lines 258-270 or any burrowing-related code.
   - **Verification:** Test burrower bug type specifically in manual testing

4. **Grid Position Desync**
   - **Likelihood:** Medium
   - **Impact:** High (bugs appear in wrong location, house detection fails)
   - **Evidence:** Current code updates gridPosition only at waypoint snap (line 283)
   - **Mitigation:** Ensure `gridPosition = targetGridPos` happens at the EXACT moment `position = targetWorldPos` in the snap logic
   - **Verification:** Unit test will verify gridPosition equals expected value after waypoint reached

### Complexity Assessment
- **Overall complexity:** Low to Medium
- **Reasoning:**
  - Code change is isolated to 23 lines (292-315)
  - Algorithm is simpler than current implementation (remove heuristics, apply one pattern)
  - Vector math is straightforward and already partially implemented
  - Risk is low because pattern already exists in codebase
- **Complex areas:** NONE - this is a simplification, not an addition

### Missing Information / Ambiguities
- [x] **How does pathIndex work?** - RESOLVED: Starts at 1 after setPath() because bug is positioned at waypoint 0
- [x] **Is there a vector utility library?** - RESOLVED: No, inline calculations are the convention
- [x] **Do flying bugs need different logic?** - RESOLVED: No, they currently use the same update method and road paths

### External Dependencies
- **None** - All code is self-contained within the game
- SpriteKit framework is already imported and used extensively

---

## Execution Strategy Recommendation

**Based on research findings, execute in this order:**

### Step 1: Read and Understand Current Implementation
- **Action:** Read `Sources/BugDefense/Bug.swift:254-316` completely
- **Purpose:** Understand the exact structure before modifying
- **Key focus:** Lines 292-315 (the section to replace)

### Step 2: Implement Vector-Based Movement
- **Action:** Replace lines 292-315 with normalized vector movement
- **Pattern to follow:** Lines 300-303 (existing diagonal movement code)
- **Algorithm:**
  ```swift
  // Remove lines 292-314 entirely (segment detection heuristics)
  // Replace with:
  let direction = CGPoint(x: dx, y: dy)
  let normalizedDirection = CGPoint(
      x: direction.x / distance,
      y: direction.y / distance
  )
  position.x += normalizedDirection.x * moveDistance
  position.y += normalizedDirection.y * moveDistance
  ```
- **Preserve:** Lines 254-291 (burrowing, path validation, distance calculation)
- **Preserve:** Snap logic at lines 280-289 (waypoint arrival handling)
- **Add:** Comment with 🐛 emoji explaining the approach

### Step 3: Build and Verify Compilation
- **Command:** `swift build`
- **Expected:** No errors, no warnings
- **If errors:** Fix syntax issues before proceeding

### Step 4: Add Unit Test (Item 2 from TODO.md)
- **Action:** Add `testBugVectorMovementOnPath()` to BugDefenseTests.swift
- **Location:** After line 185
- **Pattern:** Follow existing test at lines 125-185
- **Test cases:**
  1. Straight horizontal path - verify Y stays constant
  2. Straight vertical path - verify X stays constant
  3. Diagonal path - verify bug reaches all waypoints
  4. Waypoint snap - verify exact position match
- **Run:** `swift test --filter BugDefenseTests.testBugVectorMovementOnPath`

### Step 5: Run All Tests
- **Command:** `swift test --filter BugDefenseTests`
- **Expected:** All tests pass (new + existing)
- **If failures:** Debug and fix before manual testing

### Step 6: Manual Verification (Item 3 from TODO.md)
- **Command:** `swift run BugDefenseApp`
- **Test maps:** Map 1 (Winding Road), Map 8 (U-Turns), Map 9 (Straight Shot), Map 15 (Diagonal)
- **Bug types:** Test ant (baseline), beetle (slow), spider (fast), wasp (very fast), burrower (special)
- **Verify:** No visual drift off brown road tiles
- **Verify:** Smooth movement, no jerkiness or teleporting
- **Verify:** Burrowing still works (burrower bug disappears/reappears)

---

## Key Insights from Research

### 1. The Solution Already Exists in the Codebase!
The diagonal movement code (lines 300-303) already implements correct normalized vector movement. The fix is to **apply this pattern to ALL movement**, not just diagonals. This makes the change a simplification, not a new invention.

### 2. No Utilities Needed
The codebase has no vector math utilities or helper functions. Inline calculations are the established pattern. Do NOT create abstractions or helper methods - follow the existing inline style.

### 3. PathIndex Starts at 1, Not 0
This was discovered by reading setPath(). The bug is positioned at waypoint 0 and starts targeting waypoint 1. The movement algorithm must handle this correctly (which it does via the guard check at line 255).

### 4. Integration Surface is Small
Only GameScene calls Bug.update(). No other code directly manipulates bug position or movement. The change is well-isolated with minimal integration risk.

### 5. Test Pattern is Simple
No mocking framework, no complex test setup. Tests create real instances and call methods directly. This makes testing straightforward.

---

**Research completed:** 2025-11-20
**Total similar components found:** 3 (Hero.swift movement, DefenseStructure.swift distance calculations, existing Bug.swift diagonal movement)
**Total reusable components identified:** 0 (inline calculations are the pattern, not reusable utilities)
**Estimated complexity:** Low-Medium (simplification of existing code)
**Recommended approach:** Apply existing diagonal movement pattern to all movement directions
