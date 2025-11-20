## PROMPT
Create unit tests for the 10 new maps (21-30) to validate path correctness and system integration.

**Your mission:** Write focused tests that verify the new map data is valid, without re-testing the existing game engine.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack, architecture, project structure, coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

**Critical testing guidance:** See AI_PROMPT.md section 5.1 (lines 269-336) for testing philosophy.

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
**Will create:**
- `Tests/BugDefenseTests/MapConfigurationTests.swift` - New test file

**Will reference (read-only):**
- `Sources/BugDefense/MapConfiguration.swift` - To test new maps
- Existing game systems (no modifications)

### Patterns to Follow
**Swift XCTest structure:**
```swift
import XCTest
@testable import BugDefense

final class MapConfigurationTests: XCTestCase {
    func testNewMapsPathValidity() {
        // Test all 10 new maps
    }

    func testMapCountIncludesNewMaps() {
        // Verify MapType.allCases count
    }
}
```

### What to Test (FOCUS HERE)
✅ **New map path validity:**
- Path has at least 2 waypoints
- Path ends at GridPosition(x: 10, y: 7)
- All waypoints within bounds (x: 0-19, y: 0-14)
- No intermediate waypoints overlap house

✅ **Integration:**
- MapType.allCases includes all new maps
- Random selection can access new maps

### What NOT to Test (SKIP THESE)
❌ Bug movement logic (unchanged)
❌ Path expansion algorithm (core system)
❌ Grid rendering (SpriteKit framework)
❌ Vector calculations (already verified)

## EXTRA DOCUMENTATION

### Test Implementation Template

```swift
import XCTest
@testable import BugDefense

final class MapConfigurationTests: XCTestCase {
    func testNewMapsPathValidity() {
        let newMaps: [MapType] = [
            .map21, .map22, .map23, .map24, .map25,
            .map26, .map27, .map28, .map29, .map30
        ]

        for map in newMaps {
            let path = map.roadPath

            // At least 2 points
            XCTAssertGreaterThanOrEqual(path.count, 2,
                "Map \(map.rawValue) has insufficient waypoints")

            // Ends at house
            XCTAssertEqual(path.last, map.housePosition,
                "Map \(map.rawValue) does not end at house")

            // All in bounds
            for pos in path {
                XCTAssertTrue(pos.x >= 0 && pos.x < 20,
                    "Map \(map.rawValue) x out of bounds: \(pos.x)")
                XCTAssertTrue(pos.y >= 0 && pos.y < 15,
                    "Map \(map.rawValue) y out of bounds: \(pos.y)")
            }

            // No house overlap except final waypoint
            for i in 0..<(path.count - 1) {
                XCTAssertNotEqual(path[i], map.housePosition,
                    "Map \(map.rawValue) overlaps house at waypoint \(i)")
            }
        }
    }

    func testMapCountIncludesNewMaps() {
        let allMaps = MapType.allCases
        XCTAssertGreaterThanOrEqual(allMaps.count, 30,
            "Expected at least 30 maps (20 existing + 10 new)")
    }

    func testMapRandomSelectionIncludesNewMaps() {
        let allMaps = MapType.allCases
        XCTAssertTrue(allMaps.contains(.map21))
        XCTAssertTrue(allMaps.contains(.map30))

        let randomMap = MapType.random()
        XCTAssertNotNil(randomMap)
    }
}
```

### Running Tests
```bash
# Compile first
swift build

# Run only MapConfiguration tests
swift test --filter MapConfigurationTests

# Or run all tests
swift test
```

### Expected Output
All tests should pass:
```
Test Suite 'MapConfigurationTests' passed
    testNewMapsPathValidity() passed
    testMapCountIncludesNewMaps() passed
    testMapRandomSelectionIncludesNewMaps() passed
```

## LAYER
2 (Integration layer - depends on all map design tasks)

## PARALLELIZATION
Parallel with: []
Depends on: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]
Blocks: [TASKΩ]

## CONSTRAINTS
- **IMPORTANT:** Do not perform any git commit or git push
- Test only new maps (21-30), not existing maps
- Use Swift XCTest framework
- Include clear assertion messages
- Follow minimal testing philosophy from AI_PROMPT.md

## VALIDATION
Before marking complete:
- [ ] Test file created in correct location
- [ ] Tests compile without errors
- [ ] All tests pass when run
- [ ] Tests cover all 10 new maps
- [ ] Tests verify path validity (bounds, endpoint, house overlap)
- [ ] Integration tests confirm maps in enum and random selection

## SUCCESS CRITERIA
Task is complete when:
- ✅ MapConfigurationTests.swift exists and compiles
- ✅ All unit tests pass
- ✅ Tests validate all 10 new maps (21-30)
- ✅ Integration tests confirm map selection works
- ✅ `swift build` succeeds
- ✅ `swift test --filter MapConfigurationTests` passes
