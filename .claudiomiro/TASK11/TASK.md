@dependencies [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]
# Task: Integration Testing and Unit Test Implementation

## Summary
Create unit tests for all new maps (21-30) to validate path correctness, implement integration tests to ensure random map selection works, and verify compilation and basic runtime behavior of the complete system.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack, architecture, coding conventions, and related code patterns

**Task-Specific Context:**
This task focuses on testing the 10 new maps (not re-testing existing engine systems).

### Files This Task Will Touch
**Will create:**
- `Tests/BugDefenseTests/MapConfigurationTests.swift` - New test file for map validation

**Will verify (read-only):**
- `Sources/BugDefense/MapConfiguration.swift` - Ensure all 10 new maps added correctly
- `Sources/BugDefense/Bug.swift` - Reference for understanding path behavior (no changes)
- `Sources/BugDefense/GameScene.swift` - Reference for integration points (no changes)

### Patterns to Follow
**Swift XCTest pattern:**
```swift
import XCTest
@testable import BugDefense

final class MapConfigurationTests: XCTestCase {
    func testNewMapsPathValidity() { /* ... */ }
    func testMapRandomSelectionIncludesNewMaps() { /* ... */ }
}
```

**Testing philosophy from AI_PROMPT.md (lines 269-336):**
- Test changed code only (new maps, not existing engine)
- Minimum sufficient evidence
- Focus on integration of new maps
- Skip re-testing vector movement, path expansion, rendering

### Critical Requirements
- Test all 10 new maps (map21-map30)
- Verify paths reach house at GridPosition(x: 10, y: 7)
- Verify all waypoints within grid bounds (x: 0-19, y: 0-14)
- Verify safe zone compliance (x: 1-18, y: 1-13 recommended)
- Verify MapType.allCases includes new maps

## Complexity
Low

## Dependencies
Depends on: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]
Blocks: [TASKΩ]
Parallel with: []

## Detailed Steps

### 1. Create Test File
Create `Tests/BugDefenseTests/MapConfigurationTests.swift` with XCTest imports.

### 2. Implement Path Validity Tests
```swift
func testNewMapsPathValidity() {
    let newMaps: [MapType] = [
        .map21, .map22, .map23, .map24, .map25,
        .map26, .map27, .map28, .map29, .map30
    ]

    for map in newMaps {
        let path = map.roadPath

        // Must have at least 2 points (start and end)
        XCTAssertGreaterThanOrEqual(path.count, 2,
            "Map \(map.rawValue) has insufficient waypoints")

        // Must end at house
        XCTAssertEqual(path.last, map.housePosition,
            "Map \(map.rawValue) does not end at house")

        // All points must be in bounds
        for pos in path {
            XCTAssertTrue(pos.x >= 0 && pos.x < 20,
                "Map \(map.rawValue) has x coordinate out of bounds: \(pos.x)")
            XCTAssertTrue(pos.y >= 0 && pos.y < 15,
                "Map \(map.rawValue) has y coordinate out of bounds: \(pos.y)")
        }

        // Verify path doesn't overlap house position (except final waypoint)
        for i in 0..<(path.count - 1) {
            XCTAssertNotEqual(path[i], map.housePosition,
                "Map \(map.rawValue) overlaps house at waypoint \(i)")
        }
    }
}
```

### 3. Implement Map Count Test
```swift
func testMapCountIncludesNewMaps() {
    let allMaps = MapType.allCases
    XCTAssertGreaterThanOrEqual(allMaps.count, 30,
        "Expected at least 30 maps (20 existing + 10 new)")
}
```

### 4. Implement Random Selection Test
```swift
func testMapRandomSelectionIncludesNewMaps() {
    let allMaps = MapType.allCases

    // Verify new maps are in allCases
    XCTAssertTrue(allMaps.contains(.map21))
    XCTAssertTrue(allMaps.contains(.map30))

    // Verify random() can return values
    let randomMap = MapType.random()
    XCTAssertNotNil(randomMap)
}
```

### 5. Compile and Run Tests
```bash
swift build
swift test --filter MapConfigurationTests
```

### 6. Manual Integration Testing (Optional but Recommended)
If possible, run the game and:
- Cycle through maps 21-30 manually
- Verify bugs spawn and navigate correctly
- Check visual rendering of road tiles
- Confirm tower placement blocking works

## Acceptance Criteria

### Unit Tests
- [ ] MapConfigurationTests.swift file created in Tests/BugDefenseTests/
- [ ] testNewMapsPathValidity() implemented and passes
- [ ] testMapCountIncludesNewMaps() implemented and passes
- [ ] testMapRandomSelectionIncludesNewMaps() implemented and passes
- [ ] All 10 new maps (21-30) validated for:
  - [ ] Path has at least 2 waypoints
  - [ ] Path ends at house position GridPosition(x: 10, y: 7)
  - [ ] All waypoints within grid bounds (x: 0-19, y: 0-14)
  - [ ] No intermediate waypoints overlap house position

### Compilation
- [ ] `swift build` completes without errors
- [ ] `swift test` runs without failures

### Integration
- [ ] MapType.allCases contains at least 30 maps
- [ ] All new maps accessible via enum
- [ ] Random map selection includes new maps in pool

## Code Review Checklist
- [ ] Test file follows Swift XCTest conventions
- [ ] Test methods have clear, descriptive names
- [ ] Assertions include helpful failure messages
- [ ] Tests focus on new map data, not existing engine
- [ ] No redundant tests for unchanged systems
- [ ] Code is clean and well-commented

## Reasoning Trace

**Why this task is necessary:**
- Validates all 10 new maps meet basic correctness criteria
- Ensures maps were properly integrated into MapType enum
- Catches common errors (out of bounds, wrong endpoint, etc.)
- Provides automated regression prevention for future changes

**Why it depends on TASK1-10:**
- Cannot test maps that don't exist yet
- Each map task must complete implementation before validation

**What NOT to test (per AI_PROMPT.md guidance):**
- ❌ Bug movement logic (unchanged, already working)
- ❌ Path expansion algorithm (core system, not modified)
- ❌ Grid rendering (SpriteKit framework responsibility)
- ❌ Collision detection (no changes made)
- ❌ Vector movement calculations (already tested via TASK1)

**Testing philosophy:**
- Test the data (new map waypoint arrays)
- Test the integration (maps in enum, random selection)
- Trust the existing, working systems
- Minimal tests for maximum confidence

**Manual testing value:**
- Visual verification is important for map design
- Playtesting validates aesthetic and difficulty
- Ensures road tiles render as expected
- Confirms tower placement strategy works
