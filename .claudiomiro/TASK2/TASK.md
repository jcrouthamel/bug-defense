@dependencies [TASK1]
# Task: Create Unit Tests for Bug Movement Logic

## Summary
Write focused unit tests for the new vector-based movement logic in `Bug.update()`. Tests should verify that bugs reach waypoints exactly, maintain correct speed, and handle edge cases like slow/fast bugs and various path geometries.

**Why this matters:** Unit tests provide fast, repeatable verification that the movement fix works correctly without requiring manual gameplay testing. They catch regressions and validate edge cases that might be missed in visual testing.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift/SpriteKit), testing approach (Jest/supertest pattern but for Swift), grid system (20x15 tiles, 40pt size), and coding conventions

**Task-Specific Context:**
This task creates new unit tests for the modified Bug movement logic.

### Files This Task Will Create/Modify
- `Tests/BugDefenseTests/BugMovementTests.swift` (NEW) - Unit tests for movement logic
- Potentially modify existing test files if they need updates

### Testing Pattern to Follow
From AI_PROMPT.md Section 5.1 (Testing Guidance):
**Philosophy:** Test changed code with minimum sufficient evidence. Focus on movement correctness.

**Test Scope:**
- Create a bug with a simple multi-waypoint path
- Call `update()` multiple times with fixed deltaTime
- Verify bug reaches each waypoint exactly
- Verify position never drifts significantly from expected path

### Test Cases to Implement
From AI_PROMPT.md Section 5.1:
1. Straight horizontal path - Y coordinate remains constant
2. Straight vertical path - X coordinate remains constant
3. Diagonal path - Moves through intermediate diagonal tiles
4. Complex curved path - Completes full path correctly
5. Edge cases - Very slow bugs, very fast bugs, starting at first waypoint

### Integration Points
- Tests will instantiate `Bug` objects directly
- Will call `Bug.update(deltaTime:pathfindingGrid:)` with controlled inputs
- Will verify `Bug.position` and `Bug.gridPosition` properties
- May need to mock or provide minimal `PathfindingGrid` (can be nil if not used)

## Complexity
Medium

## Dependencies
Depends on: [TASK1]
Blocks: [TASKΩ]
Parallel with: [TASK3]

## Detailed Steps

1. **Set up the test file structure**
   - Check existing test structure in `Tests/BugDefenseTests/`
   - Create `BugMovementTests.swift` following existing test patterns
   - Import necessary modules (SpriteKit, XCTest, BugDefense)

2. **Create test helper functions**
   - Helper to create a bug with a specific path
   - Helper to run multiple update cycles
   - Helper to verify position is close to expected (within tolerance)

3. **Implement Test 1: Straight Horizontal Path**
   - Create bug with path: [(1,5), (2,5), (3,5), (4,5), (5,5)]
   - Run updates until bug completes path
   - Assert: position.y remains constant (within 0.1 points)
   - Assert: bug reaches final waypoint exactly

4. **Implement Test 2: Straight Vertical Path**
   - Create bug with path: [(5,1), (5,2), (5,3), (5,4), (5,5)]
   - Run updates until bug completes path
   - Assert: position.x remains constant (within 0.1 points)
   - Assert: bug reaches final waypoint exactly

5. **Implement Test 3: Diagonal Path**
   - Create bug with path: [(2,2), (3,3), (4,4), (5,5)]
   - Run updates until bug completes path
   - Assert: bug passes through each waypoint in sequence
   - Assert: position doesn't deviate from straight line between waypoints

6. **Implement Test 4: L-Shaped Path (Curve)**
   - Create bug with path: [(1,1), (2,1), (3,1), (3,2), (3,3), (3,4)]
   - Run updates until bug completes path
   - Assert: bug makes the turn correctly (reaches corner exactly)
   - Assert: path completion confirmed

7. **Implement Test 5: Very Slow Bug**
   - Create bug with slowFactor = 0.1
   - Use small deltaTime = 0.016 (60 FPS)
   - Run many update cycles
   - Assert: bug still reaches waypoints exactly, just takes longer

8. **Implement Test 6: Very Fast Bug**
   - Create bug with high moveSpeed (wasp-like)
   - Use normal deltaTime
   - Assert: bug doesn't skip waypoints (pathIndex increments properly)
   - Assert: reaches each waypoint despite high speed

9. **Implement Test 7: Starting Exactly at Waypoint**
   - Create bug positioned exactly at first waypoint
   - First update should advance to second waypoint
   - Assert: doesn't get stuck at starting position

10. **Run the tests**
    - Execute `swift test` to run all tests
    - Verify all tests pass
    - Fix any failures

## Acceptance Criteria
- [ ] **Test file created**: `BugMovementTests.swift` exists and follows project test structure
- [ ] **All 7+ test cases implemented**: Horizontal, vertical, diagonal, curved, slow, fast, starting position
- [ ] **Tests are focused**: Each test verifies specific aspect of movement behavior
- [ ] **Tests use realistic values**: deltaTime ≈ 0.016 (60 FPS), tile size = 40, reasonable speeds
- [ ] **Assertions are precise**: Check position within small tolerance (e.g., 0.5 points for drift, exact for waypoint arrival)
- [ ] **All tests pass**: `swift test` completes with 0 failures
- [ ] **No flaky tests**: Tests produce consistent results on multiple runs
- [ ] **Test names are descriptive**: e.g., `testBugMovesAlongStraightHorizontalPathWithoutDrift`
- [ ] **Edge cases covered**: Slow bugs, fast bugs, various path geometries
- [ ] **Grid position verified**: Tests check both `position` and `gridPosition` where applicable

## Code Review Checklist
- [ ] **Test isolation**: Each test is independent (creates own bug instance, doesn't share state)
- [ ] **Clear arrange-act-assert**: Tests follow AAA pattern clearly
- [ ] **Meaningful assertions**: Assertions test the actual requirement, not implementation details
- [ ] **Realistic scenarios**: Test cases reflect actual game conditions
- [ ] **No hard-coded magic numbers**: Use constants like `GameConfiguration.tileSize`
- [ ] **Tolerance values justified**: Drift tolerance (0.5 points) is reasonable given tile size (40 points)
- [ ] **Error messages helpful**: Assertion messages explain what failed and why
- [ ] **Coverage adequate**: Tests cover the changed lines in Bug.update()
- [ ] **No over-testing**: Don't test unchanged behavior (flying bugs, burrowing)
- [ ] **Performance acceptable**: Tests run quickly (< 1 second total)

## Reasoning Trace

**Why unit tests instead of only manual testing?**
- Fast feedback loop during development
- Catch regressions when other code changes
- Verify edge cases that are hard to reproduce manually
- Provide documentation of expected behavior
- Can run in CI/CD pipeline

**What makes a good movement test?**
- Controlled inputs (fixed path, fixed deltaTime, fixed speed)
- Predictable outputs (exact waypoint positions)
- Isolated from game engine complexity (direct Bug instantiation)
- Verifiable with simple math (expected position calculable)

**Why test both position and gridPosition?**
- `position` is the visual world coordinate (what player sees)
- `gridPosition` is the logical grid coordinate (used for tower range, etc.)
- Both must stay synchronized for game logic to work

**Tolerance considerations:**
- Exact match for waypoint arrival (position should snap exactly)
- Small tolerance for drift detection (0.5 points on 40-point tile = 1.25%)
- Too tight tolerance = flaky tests from floating-point precision
- Too loose tolerance = won't catch actual drift

**Why 7+ test cases?**
From AI_PROMPT.md Section 5.1, these cases cover:
- Different path geometries (horizontal, vertical, diagonal, curved)
- Different speeds (slow, fast, normal)
- Different starting conditions (at waypoint, between waypoints)
This provides sufficient coverage without exhaustive testing.

**Alternative testing approaches not chosen:**
- Integration tests: Slower, harder to isolate failures
- Snapshot tests: Overkill for position verification
- Property-based tests: Complex setup for simple movement logic
