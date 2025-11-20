## PROMPT
Create comprehensive unit tests for the bug movement logic to verify that the vector-based movement fix keeps bugs on the path across various scenarios and edge cases.

**Your objective:** Write focused, fast, repeatable tests that verify bugs reach waypoints exactly, maintain proper speed, and handle edge cases without requiring manual gameplay testing.

## COMPLEXITY
Medium

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x/SpriteKit), grid system (20x15 tiles, 40pt tile size), testing philosophy (minimal & relevant), and coding conventions

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### What TASK1 Implemented
TASK1 rewrote the movement calculation in `Bug.update()` to use vector normalization. Your tests verify this implementation works correctly.

### File to Create
**`Tests/BugDefenseTests/BugMovementTests.swift`** (NEW)
- Contains unit tests for Bug movement logic
- Tests the modified `update(deltaTime:pathfindingGrid:)` method
- Focuses on changed code, not entire Bug class

### Testing Philosophy
From AI_PROMPT.md Section 5.1:
> Test changed code with minimum sufficient evidence. Focus on movement correctness.

**This means:**
- Test the movement calculation, not the entire game system
- Create isolated tests with controlled inputs
- Verify specific behaviors (waypoint arrival, no drift, correct speed)
- Don't test unchanged functionality (flying bugs, burrowing, health)

### Required Test Cases
From AI_PROMPT.md Section 5.1, implement these 7 test cases:

1. **Straight Horizontal Path**
   - Path: (1,5) → (5,5)
   - Verify: position.y remains constant at world Y for y=5
   - Verify: Bug arrives exactly at each waypoint

2. **Straight Vertical Path**
   - Path: (5,1) → (5,5)
   - Verify: position.x remains constant at world X for x=5
   - Verify: Bug arrives exactly at each waypoint

3. **Diagonal Path**
   - Path: (2,2) → (3,3) → (4,4) → (5,5)
   - Verify: Bug moves in straight line through intermediate tiles
   - Verify: Passes through each waypoint

4. **Complex Curved Path (L-shape)**
   - Path: Horizontal segment then vertical turn
   - Verify: Bug completes entire path
   - Verify: No drift off path during turn

5. **Very Slow Bug**
   - slowFactor = 0.1
   - Verify: Still reaches waypoints exactly, just takes longer iterations

6. **Very Fast Bug**
   - High moveSpeed (wasp-like)
   - Verify: Doesn't skip waypoints
   - Verify: pathIndex increments correctly

7. **Bug Starting Exactly at Waypoint**
   - Initial position = first waypoint world position
   - Verify: Doesn't get stuck, advances properly

### Test Structure Pattern
```swift
import XCTest
@testable import BugDefense

final class BugMovementTests: XCTestCase {
    func testBugMovesAlongStraightHorizontalPathWithoutDrift() {
        // Arrange
        let path = [GridPosition(x: 1, y: 5), GridPosition(x: 2, y: 5), ...]
        let bug = createTestBug(path: path)
        let expectedY = GridPosition(x: 1, y: 5).toWorldPosition().y

        // Act
        runUpdatesUntilCompletion(bug: bug)

        // Assert
        // Check that bug stayed on the horizontal line
        // Check that bug reached final waypoint
    }
}
```

### Helper Functions to Create
1. **`createTestBug(path: [GridPosition]) -> Bug`**
   - Creates a Bug instance with the given path
   - Sets reasonable defaults (normal speed, no slow factor)
   - Positions bug at first waypoint

2. **`runUpdatesUntilCompletion(bug: Bug, maxIterations: Int = 1000)`**
   - Calls `bug.update(deltaTime: 0.016, pathfindingGrid: nil)` repeatedly
   - Stops when bug reaches end of path or maxIterations reached
   - Uses realistic deltaTime (0.016 ≈ 60 FPS)

3. **`assertPositionNear(_ actual: CGPoint, _ expected: CGPoint, tolerance: CGFloat)`**
   - Asserts actual position is within tolerance of expected
   - Provides clear error message with distance if assertion fails

### Coordinate Conversion Reference
From AI_PROMPT.md Section 2:
```swift
// Grid to world position
GridPosition(x: 5, y: 3).toWorldPosition()
// Returns: CGPoint(x: 5 * 40 + 20, y: 3 * 40 + 20)
//        = CGPoint(x: 220, y: 140)
```

Tile size = 40 points, center offset = 20 points

### Tolerance Values
- **Waypoint arrival:** Exact match (0.0 tolerance) - position should snap exactly
- **Drift detection:** 0.5 points tolerance
  - Tile size is 40 points
  - 0.5 points = 1.25% deviation
  - This catches significant drift while allowing floating-point imprecision

## EXTRA DOCUMENTATION

### Example Test Implementation
```swift
func testBugMovesAlongStraightHorizontalPathWithoutDrift() {
    // Arrange
    let path = [
        GridPosition(x: 1, y: 5),
        GridPosition(x: 2, y: 5),
        GridPosition(x: 3, y: 5),
        GridPosition(x: 4, y: 5)
    ]
    let bug = createTestBug(path: path)
    let expectedY = path[0].toWorldPosition().y

    var positions: [CGPoint] = []

    // Act
    for _ in 0..<1000 {
        if bug.pathIndex >= path.count {
            break
        }
        positions.append(bug.position)
        bug.update(deltaTime: 0.016, pathfindingGrid: nil)
    }

    // Assert
    // All positions should have Y coordinate within 0.5 points of expected
    for position in positions {
        XCTAssertEqual(position.y, expectedY, accuracy: 0.5,
                      "Bug drifted off horizontal path at position \(position)")
    }

    // Bug should have completed the path
    XCTAssertEqual(bug.pathIndex, path.count,
                   "Bug did not complete the path")

    // Final position should be exactly at last waypoint
    let finalExpected = path.last!.toWorldPosition()
    XCTAssertEqual(bug.position.x, finalExpected.x, accuracy: 0.1)
    XCTAssertEqual(bug.position.y, finalExpected.y, accuracy: 0.1)
}
```

### Running Tests
```bash
# Run all tests
swift test

# Run specific test file
swift test --filter BugMovementTests

# Run specific test case
swift test --filter testBugMovesAlongStraightHorizontalPathWithoutDrift
```

## LAYER
2 (Validation - can run in parallel with TASK3)

## PARALLELIZATION
Parallel with: [TASK3]
Both TASK2 (unit tests) and TASK3 (manual testing) validate the TASK1 implementation and can run simultaneously.

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push
- **Create new test file** - don't modify existing tests unless necessary
- **Test changed code only** - focus on Bug.update() movement logic
- **Use realistic values** - deltaTime ≈ 0.016 (60 FPS), tile size = 40, actual game speeds
- **Fast tests** - all tests should complete in < 1 second total
- **No flakiness** - tests must be deterministic and repeatable
- **Isolated tests** - each test creates its own bug instance, no shared state
- Follow Swift testing conventions (XCTest framework)
- Use descriptive test names that explain what is being tested
- Include helpful assertion messages for debugging failures

## DELIVERABLES
1. **`BugMovementTests.swift`** with 7+ test cases
2. All tests passing (`swift test` shows 0 failures)
3. Tests verify:
   - Horizontal path movement (no Y drift)
   - Vertical path movement (no X drift)
   - Diagonal path movement
   - Curved path handling
   - Slow bug edge case
   - Fast bug edge case
   - Starting position edge case
4. Clear, maintainable test code with helper functions
