# Research for TASK2

## Context Reference
**For tech stack and conventions, see:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (Swift 5.x/SpriteKit, XCTest framework, grid system, conventions)
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/TASK.md` - Task-level context (test requirements and scope)
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/PROMPT.md` - Task-specific context (exact test cases, helper functions, acceptance criteria)

**This file contains ONLY new information discovered during research.**

---

## Task Understanding Summary
Create comprehensive unit tests for Bug movement logic in a new file `BugMovementTests.swift` to verify the TASK1 vector-based movement implementation keeps bugs on path across 7+ scenarios (horizontal, vertical, diagonal, L-shaped, slow/fast bugs, starting position).

---

## Similar Components Found (LEARN FROM THESE)

### 1. CRITICAL DISCOVERY: Tests Already Exist! - `Tests/BugDefenseTests/BugDefenseTests.swift:187-362`
**Why similar:** This is a comprehensive test method `testBugVectorMovementOnPath()` that ALREADY tests the TASK1 implementation!

**What it covers:**
- Test 1 (lines 192-217): Straight horizontal movement - Y constant check
- Test 2 (lines 219-241): Straight vertical movement - X constant check
- Test 3 (lines 243-260): Diagonal movement - waypoint completion
- Test 4 (lines 262-279): Waypoint snap behavior
- Test 5 (lines 281-306): Very slow bug (slowFactor = 0.1)
- Test 6 (lines 308-337): Very fast bug (wasp, wave 50) - no skipping
- Test 7 (lines 339-361): Path completion check

**Patterns to reuse:**
- Lines 189-190: Setup pattern with `PathfindingGrid(width: 20, height: 15)` and `fixedDeltaTime: TimeInterval = 0.016`
- Lines 200-201: Bug creation pattern: `Bug(type: .ant, at: horizontalPath[0], wave: 1, difficulty: .normal)` + `bug.setPath(path)`
- Lines 203: Expected Y calculation: `let expectedY = horizontalPath[0].toWorldPosition().y`
- Lines 206-212: Update loop pattern with inline assertions checking drift during movement
- Lines 210-211: Accuracy-based assertion: `XCTAssertEqual(bug.position.y, expectedY, accuracy: 1.0, "message")`
- Lines 287-289: Slow bug setup: `slowBug.applySlow(factor: 0.1, duration: 10.0)`
- Lines 318-327: Visited waypoints tracking pattern using `Set<GridPosition>`

**Key learnings:**
- Tests use `accuracy: 1.0` for drift tolerance (NOT 0.5 as PROMPT suggests)
- Tests create inline paths as local variables, not helper functions
- Tests use simple for loops (0..<200) instead of helper functions for running updates
- Tests check conditions DURING movement (`if bug.gridPosition != path.last`), not just at end
- Tests are organized as one large test method with multiple subtests, not separate test methods

**MAJOR FINDING:** TASK2 requirements ask us to create similar tests to what ALREADY EXISTS. We need to determine:
1. Should we create a NEW separate test file with duplicate tests?
2. Should we refactor existing tests into the new file structure?
3. Should we extend the existing test with the missing L-shaped test?

---

### 2. Test Structure Pattern - `Tests/BugDefenseTests/BugDefenseTests.swift:1-4, 24, 187`
**Pattern to follow:**
```swift
import XCTest
@testable import BugDefense

final class BugDefenseTests: XCTestCase {
    @MainActor
    func testBugVectorMovementOnPath() {
        // Test implementation
    }
}
```

**Key learnings:**
- Use `@MainActor` annotation for tests involving SpriteKit nodes (Bug is SKShapeNode)
- Tests without SpriteKit (like `testGridPositionConversion:6-15`) don't need `@MainActor`
- Import pattern: `@testable import BugDefense` allows access to internal members

---

### 3. Bug Instantiation Pattern - Used Throughout Tests
**Location:** `Tests/BugDefenseTests/BugDefenseTests.swift:128, 200, 227, 250`

**Standard pattern:**
```swift
let bug = Bug(type: .ant, at: startPosition, wave: 1, difficulty: .normal)
bug.setPath(path)
```

**Variations found:**
- Fast bug: `Bug(type: .wasp, at: pos, wave: 50, difficulty: .hard)` - lines 314
- Slow bug: `Bug(type: .beetle, ...)` then `bug.applySlow(factor: 0.1, duration: 10.0)` - lines 287-289

**Key learning:** Bug types have different speeds: beetle (slow), ant (normal), spider (fast), wasp (very fast)

---

## Reusable Components (USE THESE, DON'T RECREATE)

### 1. GridPosition.toWorldPosition() - `Sources/BugDefense/GameConfiguration.swift:177-182`
**Purpose:** Convert grid coordinates to world position (center of tile)
**Formula:** `CGPoint(x: gridX * 40 + 20, y: gridY * 40 + 20)`
**How to use:**
```swift
let gridPos = GridPosition(x: 5, y: 3)
let worldPos = gridPos.toWorldPosition()  // Returns CGPoint(x: 220, y: 140)
```
**Integration into task:** Used to calculate expected positions for assertions

---

### 2. PathfindingGrid Initialization - `Tests/BugDefenseTests/BugDefenseTests.swift:189`
**Purpose:** Required parameter for `bug.update()` method
**How to use:**
```swift
let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
bug.update(deltaTime: 0.016, pathfindingGrid: pathfindingGrid)
```
**Integration into task:** Create once at test start, reuse for all update calls

---

### 3. Bug.setPath() - `Sources/BugDefense/Bug.swift:240-252`
**Purpose:** Assigns movement path and positions bug at first waypoint
**Side effects:**
- Sets `bug.gridPosition = path.first`
- Sets `bug.position = path.first.toWorldPosition()`
- Sets `bug.pathIndex = 1` (targeting second waypoint)
**How to use:**
```swift
let path = [GridPosition(x: 1, y: 5), GridPosition(x: 2, y: 5)]
bug.setPath(path)
// Bug is now at (1,5) and will move toward (2,5)
```

---

### 4. Bug.applySlow() - `Sources/BugDefense/Bug.swift:308-318`
**Purpose:** Apply slow factor to bug speed (for trap/tower effects)
**How to use:**
```swift
bug.applySlow(factor: 0.1, duration: 10.0)  // 10% speed for 10 seconds
```
**Integration into task:** Used for testing very slow bug edge case

---

## Codebase Conventions Discovered

### File Organization
**Pattern found in:** `Tests/BugDefenseTests/BugDefenseTests.swift`
```
1. Imports (XCTest, @testable import BugDefense)
2. Test class declaration (final class, XCTestCase)
3. Test methods (func test...() with @MainActor if needed)
4. Each test method: Arrange → Act → Assert pattern
```

### Naming Conventions
- **Test files:** `*Tests.swift` (e.g., `BugDefenseTests.swift`, `BugMovementTests.swift`)
- **Test classes:** PascalCase matching filename (e.g., `BugDefenseTests`, `BugMovementTests`)
- **Test methods:** `testCamelCaseDescriptiveName()` (e.g., `testBugVectorMovementOnPath()`)
- **Local variables:** camelCase (e.g., `horizontalBug`, `expectedY`, `pathfindingGrid`)
- **Constants in tests:** camelCase (e.g., `fixedDeltaTime`)

### Assertion Pattern
**Pattern from:** `Tests/BugDefenseTests/BugDefenseTests.swift:210-211, 216-217`
```swift
// With tolerance/accuracy
XCTAssertEqual(actualValue, expectedValue, accuracy: 1.0,
    "Descriptive message with \(actualValue)")

// Exact equality
XCTAssertEqual(bug.gridPosition, expectedPosition,
    "Bug should end at final waypoint")

// Comparisons
XCTAssertGreaterThan(value, threshold,
    "Description of what should be greater")
```

**Key convention:** Descriptive messages in assertions that explain WHAT failed, not just that it failed

### Test Iteration Pattern
**Pattern from:** `Tests/BugDefenseTests/BugDefenseTests.swift:206-213`
```swift
for _ in 0..<200 {
    bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)
    // Inline assertions during movement
    if bug.gridPosition != path.last {
        XCTAssertEqual(bug.position.y, expectedY, accuracy: 1.0, "message")
    }
}
```

**NOT a separate helper function** - iteration is inline with test logic

---

## Integration & Impact Analysis

### Functions/Classes/Components Being Tested:

#### 1. `Bug.update(deltaTime:pathfindingGrid:)` in `Sources/BugDefense/Bug.swift:254-302`
**What it does:**
- Moves bug toward current waypoint target (movementPath[pathIndex])
- Uses normalized vector movement: `position += (dx/distance, dy/distance) * moveDistance`
- Snaps to exact position when within 2 points
- Increments pathIndex when waypoint reached
- Handles burrowing behavior (lines 258-270)

**Called by:**
- `GameScene.swift:391` - Main game loop (every frame, all bugs)
- Test code - Controlled testing with fixed deltaTime

**Parameter contract:**
```swift
func update(deltaTime: TimeInterval, pathfindingGrid: PathfindingGrid)
```

**Impact of tests:** Tests verify the TASK1 implementation (lines 292-300) works correctly without changing production code

**Breaking changes:** NO - Tests only, no production code changes

---

#### 2. `Bug.setPath(_:)` in `Sources/BugDefense/Bug.swift:240-252`
**Tested indirectly:** All tests call this to set up bug path before testing movement

**What tests verify:**
- Bug positions correctly at first waypoint
- pathIndex initializes to 1 (targeting second waypoint)

---

#### 3. `Bug.applySlow(factor:duration:)` in `Sources/BugDefense/Bug.swift:308-318`
**Tested in:** Slow bug edge case test

**What tests verify:**
- Slow bugs still move correctly (no NaN, no infinite, still progresses)

---

### Test File Dependencies:
**New file will depend on:**
- `XCTest` framework (Swift standard library)
- `BugDefense` module (testable import)
- Specifically: `Bug`, `GridPosition`, `PathfindingGrid`, `BugType`, `Difficulty`

**No database/API/external dependencies** - Pure unit tests

---

## Test Strategy Discovered

### Testing Framework
- **Framework:** XCTest (Swift standard testing framework)
- **Test command:** `swift test --filter BugMovementTests`
- **Config:** No special config needed (Swift Package Manager default)

### Test Patterns Found

**Test file location:** `Tests/BugDefenseTests/*.swift`

**Test structure from existing tests:**
```swift
@MainActor  // Required for SpriteKit tests
func testDescriptiveName() {
    // Arrange
    let pathfindingGrid = PathfindingGrid(width: 20, height: 15)
    let fixedDeltaTime: TimeInterval = 0.016
    let path = [GridPosition(...), ...]
    let bug = Bug(type: .ant, at: path[0], wave: 1, difficulty: .normal)
    bug.setPath(path)

    // Act
    for _ in 0..<iterations {
        bug.update(deltaTime: fixedDeltaTime, pathfindingGrid: pathfindingGrid)
        // Inline assertions during movement
    }

    // Assert
    XCTAssertEqual(bug.gridPosition, expectedPosition, "message")
}
```

**Example from:** `Tests/BugDefenseTests/BugDefenseTests.swift:192-217`

---

### Current Test Coverage Analysis

**What TASK1 implementation test (`testBugVectorMovementOnPath`) already covers:**
- ✅ Horizontal straight path (Y drift check)
- ✅ Vertical straight path (X drift check)
- ✅ Diagonal path
- ✅ Waypoint snap behavior
- ✅ Slow bug (slowFactor = 0.1)
- ✅ Fast bug (wasp wave 50, no waypoint skipping)
- ✅ Path completion (bug stops at end)

**What TASK2 requires that's MISSING:**
- ❌ **L-shaped curved path** - Turn behavior test (horizontal → vertical turn)
- ❌ **Starting exactly at waypoint** - Explicit test that bug doesn't get stuck
- ❌ **Separate test methods** - Current tests are all in one method
- ❌ **Helper functions** - Current tests use inline loops
- ❌ **Separate test file** - Tests are in main BugDefenseTests.swift

---

## Risks & Challenges Identified

### Technical Risks

#### 1. **Test Duplication Risk**
- **Description:** TASK2 asks to create tests that already exist in `BugDefenseTests.swift:187-362`
- **Likelihood:** High - Requirements clearly specify creating new tests
- **Impact:** Medium - Duplicate test coverage, maintenance burden
- **Evidence:** `testBugVectorMovementOnPath` covers 6 of 7 required test cases
- **Mitigation:**
  - Option A: Create new file with refactored/separated tests, remove old test
  - Option B: Create only missing tests in new file, keep existing
  - Option C: Create new file with all tests as specified, mark old test as deprecated
- **Recommendation:** Create new file with all 7 tests as separate methods per TASK2 spec, then propose removing old consolidated test

---

#### 2. **Tolerance Value Inconsistency**
- **Description:** PROMPT.md suggests 0.5 tolerance, existing tests use 1.0
- **Likelihood:** High - Direct conflict
- **Impact:** Low - Test may be stricter or looser
- **Evidence:**
  - PROMPT.md:122-125: "0.5 points tolerance"
  - BugDefenseTests.swift:210: `accuracy: 1.0`
- **Mitigation:** Use 0.5 as TASK2 spec requires (stricter is better for drift detection)
- **Fallback:** If tests are flaky with 0.5, document and adjust to 1.0

---

#### 3. **Helper Function vs Inline Pattern**
- **Description:** TASK2 requires helper functions, existing tests use inline loops
- **Likelihood:** High - Design decision
- **Impact:** Low - Code organization preference
- **Evidence:** TODO.md:24-43 specifies helper functions, existing tests don't use them
- **Mitigation:** Create helper functions as specified for better test readability
- **Benefit:** Reduces duplication across 7+ test methods

---

### Complexity Assessment
- **Overall complexity:** Low to Medium
- **Reasoning:** Tests are straightforward (arrange-act-assert), but requires careful setup and understanding of movement mechanics
- **Complex areas:**
  1. **L-shaped path test:** Need to verify turn behavior without drift - requires position tracking during turn
  2. **Helper function design:** Must be reusable across different test scenarios
  3. **Tolerance tuning:** Finding right balance between strict (catches bugs) and loose (avoids flakiness)

---

### Missing Information
- ✅ **L-shaped path definition:** Need to determine exact path coordinates for turn test
  - **Recommendation:** Use path like `[(1,1), (2,1), (3,1), (3,2), (3,3), (3,4)]` - horizontal then vertical
  - **Reasoning:** Simple 90-degree turn, easy to verify drift on each segment

---

## Execution Strategy Recommendation

**Based on research findings, execute in this order:**

### Phase 1: Create Test File and Helper Functions
1. **Create new file** - `Tests/BugDefenseTests/BugMovementTests.swift`
   - Follow pattern from: `BugDefenseTests.swift:1-4`
   - Use `@MainActor` annotation on class or individual tests
   - Import: `XCTest`, `@testable import BugDefense`

2. **Implement helper functions** (TODO.md:24-43)
   - `createTestBug(path:speed:slowFactor:) -> Bug`
     - Pattern from: `BugDefenseTests.swift:200-201`
     - Create Bug, call setPath(), return configured instance
   - `runUpdatesUntilCompletion(bug:maxIterations:)`
     - Pattern from: `BugDefenseTests.swift:206-207, 255`
     - Loop calling update() until pathIndex >= path.count
     - Use `pathfindingGrid = PathfindingGrid(width: 20, height: 15)`
   - `assertPositionNear(_:_:tolerance:file:line:)`
     - Calculate distance: `sqrt((actual.x-expected.x)^2 + (actual.y-expected.y)^2)`
     - Use `XCTAssertLessThanOrEqual(distance, tolerance, message, file: file, line: line)`

3. **Test helper functions work**
   - Create simple 2-waypoint test to verify helpers function correctly

---

### Phase 2: Implement Core Path Tests (Items 2-3)
4. **Implement horizontal path test** - `testBugMovesAlongStraightHorizontalPathWithoutDrift()`
   - Path: `[(1,5), (2,5), (3,5), (4,5), (5,5)]`
   - Pattern from: `BugDefenseTests.swift:192-217`
   - Track positions during movement
   - Assert Y within 0.5 points of expected throughout
   - Assert completion and final position exact

5. **Implement vertical path test** - `testBugMovesAlongStraightVerticalPathWithoutDrift()`
   - Path: `[(5,1), (5,2), (5,3), (5,4), (5,5)]`
   - Pattern from: `BugDefenseTests.swift:219-241`
   - Assert X within 0.5 points of expected throughout

6. **Implement diagonal path test** - `testBugMovesAlongDiagonalPath()`
   - Path: `[(2,2), (3,3), (4,4), (5,5)]`
   - Pattern from: `BugDefenseTests.swift:243-260`
   - Verify waypoint progression and final arrival

7. **Implement L-shaped path test** - `testBugMovesAlongLShapedCurvedPath()`
   - Path: `[(1,1), (2,1), (3,1), (3,2), (3,3), (3,4)]`
   - NEW TEST - not in existing code
   - Verify horizontal segment (Y constant at world y=1)
   - Verify vertical segment (X constant at world x=3)
   - Verify corner waypoint (3,1) reached before turn

---

### Phase 3: Implement Edge Case Tests (Item 4)
8. **Implement slow bug test** - `testVerySlowBugStillReachesWaypoints()`
   - Pattern from: `BugDefenseTests.swift:281-306`
   - Path: `[(1,1), (2,1), (3,1)]`
   - Use `bug.applySlow(factor: 0.1, duration: 10.0)`
   - Use maxIterations = 5000 for slow movement
   - Verify completion and no NaN/infinite values

9. **Implement fast bug test** - `testVeryFastBugDoesNotSkipWaypoints()`
   - Pattern from: `BugDefenseTests.swift:308-337`
   - Use `Bug(type: .wasp, wave: 50, difficulty: .hard)`
   - Track visited waypoints with Set<GridPosition>
   - Verify all waypoints visited in sequence

10. **Implement starting position test** - `testBugStartingExactlyAtWaypointAdvancesProperly()`
    - Path: `[(1,1), (2,1), (3,1)]`
    - NEW TEST - not explicitly in existing code
    - Verify bug.position == path[0].toWorldPosition() after setPath()
    - Call update() once
    - Verify bug moved toward path[1], not stuck

---

### Phase 4: Verification
11. **Run all tests**
    - Command: `swift test --filter BugMovementTests`
    - Verify all 7 tests pass
    - Check for flakiness (run 2-3 times)

12. **Adjust tolerances if needed**
    - If 0.5 tolerance causes flakiness, increase to 1.0
    - Document any adjustments

13. **Verify test quality**
    - Tests are independent (no shared state)
    - Tests are deterministic (same result every time)
    - Assertions are clear and helpful
    - Tests complete quickly (< 5 seconds total)

---

**Research completed:** 2025-11-20
**Total similar components found:** 1 (comprehensive existing test)
**Total reusable components identified:** 4 (GridPosition.toWorldPosition, PathfindingGrid, Bug.setPath, Bug.applySlow)
**Estimated complexity:** Low-Medium (straightforward tests, but requires careful setup and L-shaped test is new)

---

## Key Decision: Handle Existing Tests

**CRITICAL FINDING:** `testBugVectorMovementOnPath` (lines 187-362) already covers 6 of 7 required test cases.

**Recommendation:**
1. Create `BugMovementTests.swift` with all 7 tests as separate methods (per TASK2 spec)
2. Create helper functions as specified (better maintainability)
3. Use 0.5 tolerance (stricter than existing 1.0)
4. After TASK2 completion, can optionally remove/deprecate old consolidated test to avoid duplication

**Rationale:**
- TASK2 spec is explicit about structure (separate file, helper functions, separate tests)
- Having tests in both files provides redundancy during transition
- New tests with helper functions will be more maintainable
- Can decide later whether to remove old test or keep both
