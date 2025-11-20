# Research for TASK0

## Context Reference
**For tech stack and conventions, see:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/TASK.md` - Task-level context
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/PROMPT.md` - Task-specific context

**This file contains ONLY new information discovered during research.**

---

## Task Understanding Summary
Analyze the existing 20 maps in MapConfiguration.swift to understand patterns, constraints, and implementation details. This foundation will guide the creation of 10 new unique map layouts across parallel tasks (TASK1-TASK10).

---

## Files Discovered to Read/Modify
[ONLY files found during research NOT already in PROMPT.md]
- `Sources/BugDefense/GameConfiguration.swift:169-194` - GridPosition struct definition with toWorldPosition() helper
- `Tests/BugDefenseTests/BugMovementTests.swift:1-66` - Test helper patterns and structure for validation

---

## Code Patterns Found
[ONLY new patterns discovered during research]

### Map Pattern Taxonomy (Complete Inventory)
After analyzing all 20 existing maps, they fall into these categories:

**Simple/Straight Paths (Short, Easy):**
- `MapConfiguration.swift:319-332` - Map 9 "Straight Shot" - 10 waypoints, horizontal only
- `MapConfiguration.swift:507-518` - Map 15 "Diagonal" - 9 waypoints, diagonal emphasis

**Winding/Serpentine Paths (Medium):**
- `MapConfiguration.swift:118-137` - Map 1 "Winding Road" - 16 waypoints, classic S-curve
- `MapConfiguration.swift:140-166` - Map 2 "Zigzag" - 23 waypoints, sharp back-and-forth
- `MapConfiguration.swift:169-182` - Map 3 "S-Curve" - 10 waypoints, smooth diagonal S
- `MapConfiguration.swift:242-256` - Map 6 "Long Path" - 11 waypoints, diagonal ascent
- `MapConfiguration.swift:335-347` - Map 10 "Wave Pattern" - 9 waypoints, wave motion

**Loop/Circular Patterns (Medium):**
- `MapConfiguration.swift:185-202` - Map 4 "Double Loop" - 14 waypoints, two interlocking circles
- `MapConfiguration.swift:259-278` - Map 7 "Figure Eight" - 16 waypoints, crossing loops
- `MapConfiguration.swift:522-541` - Map 16 "Cloverleaf" - 16 waypoints, four-leaf pattern
- `MapConfiguration.swift:591-611` - Map 19 "Horseshoe" - 17 waypoints, U-shaped arc

**Maze/Complex Paths (Long, Hard):**
- `MapConfiguration.swift:205-239` - Map 5 "Maze Runner" - 31 waypoints, intricate maze
- `MapConfiguration.swift:280-316` - Map 8 "U-Turns" - 32 waypoints, multiple sharp U-turns
- `MapConfiguration.swift:350-412` - Map 11 "Box Spiral" - 62 waypoints, rectangular spiral from edge to center
- `MapConfiguration.swift:416-457` - Map 12 "Switchback" - 37 waypoints, mountain road zigzag
- `MapConfiguration.swift:614-631` - Map 20 "Labyrinth" - 14 waypoints, compact complex maze

**Geometric/Themed Paths (Medium):**
- `MapConfiguration.swift:460-477` - Map 13 "Cross Roads" - 14 waypoints, staircase-like diagonal
- `MapConfiguration.swift:480-503` - Map 14 "Lightning" - 21 waypoints, jagged lightning bolt
- `MapConfiguration.swift:544-566` - Map 17 "Snake" - 19 waypoints, slithering up-and-down
- `MapConfiguration.swift:569-588` - Map 18 "Pyramid" - 16 waypoints, stepped pyramid ascent

### Pattern Gaps Identified (Opportunities for New Maps)
**Underrepresented patterns:**
- Reverse/Counter-clockwise spirals (Map 11 is clockwise)
- Symmetrical patterns (mirrored paths)
- Dense zigzag patterns (more compressed than Map 2)
- Circular orbits around house before entering
- Cross/X-shaped patterns with multiple path intersections
- Diamond/rhombus shapes
- Staircase patterns (ascending/descending)
- Multiple small loops within one path
- Figure variations (infinity symbol, question mark, etc.)
- Extreme diagonals (more than Map 15)

**Path length distribution:**
- Short (8-12 waypoints): Maps 3, 6, 9, 10, 15 → **5 maps (25%)**
- Medium (13-23 waypoints): Maps 1, 2, 4, 7, 13, 14, 16, 17, 18, 19 → **10 maps (50%)**
- Long (30+ waypoints): Maps 5, 8, 11, 12, 20 → **5 maps (25%)**

**Recommendation:** Maintain similar distribution in new maps (3 short, 5 medium, 2 long).

### Safe Zone Boundary Validation
All existing maps respect: **x:1-18, y:1-13**

**Edge cases found:**
- Closest to edge x=0: Map 1 starts at x=1 ✓
- Closest to edge x=19: Map 11 reaches x=17 (2 tiles from edge) ✓
- Closest to edge y=0: Maps 6, 12, 18 start at y=1 ✓
- Closest to edge y=14: Map 11 reaches y=12 (2 tiles from edge) ✓

**Critical constraint:** No waypoint ever uses x=0, x=19, y=0, or y=14.

### House Position Consistency
- `MapConfiguration.swift:106-108` - housePosition always returns `GridPosition(x: 10, y: 7)`
- All 20 maps end at exactly this position
- No exceptions or variations
- House is at grid center (20x15 grid, house at 10,7 = center)

### Path Expansion Algorithm Details
- `MapConfiguration.swift:70-103` - expandPath() implementation
- **Key insight:** Define only corner/turning waypoints, algorithm fills intermediate tiles
- Uses integer division: `x = start.x + (dx * step) / steps`
- Avoids duplicates by checking `position != expandedPath.last`
- **Pattern to follow:** For a 90-degree turn, only specify the corner point, not every tile

**Example from Map 1:**
```swift
GridPosition(x: 4, y: 3),  // corner
GridPosition(x: 4, y: 8),  // after vertical run - expandPath fills x:4, y:4-7
```

---

## Integration & Impact Analysis

### Functions/Classes/Components Being Modified:
**None** - This is a read-only research task. No code modifications.

### Key Integration Points Discovered:
1. **MapType enum (MapConfiguration.swift:5-26)**
   - CaseIterable protocol auto-includes new cases in `.allCases`
   - `.random()` method (line 36-38) uses `allCases.randomElement()`
   - New maps automatically available to random selection without additional code

2. **roadPath computed property (MapConfiguration.swift:41-68)**
   - Switch statement must be exhaustive (Swift compiler enforces)
   - Each new case must map to its path method
   - expandPath() called automatically on return

3. **Bug.setPath() (Bug.swift:240-252)**
   - Accepts `[GridPosition]` array
   - Bug starts at first waypoint, targets second (pathIndex = 1)
   - Integration already complete, no changes needed

4. **GameScene.spawnBug() (GameScene.swift:488-504)**
   - Retrieves path via `MapManager.shared.getCurrentRoadPath()`
   - Logs waypoint count for debugging
   - No changes needed for new maps

### Reusable Components Discovered:
1. **GridPosition struct (GameConfiguration.swift:169-194)**
   - Lightweight value type: `Equatable, Hashable, CustomStringConvertible`
   - Helper method: `toWorldPosition()` converts grid coords to world coords
   - Helper method: `distance(to:)` calculates Manhattan distance
   - **Usage:** `GridPosition(x: Int, y: Int)` - use this for all waypoints

2. **MapType.expandPath() (MapConfiguration.swift:70-103)**
   - Static method, reusable for validation
   - **Do not modify** - working correctly
   - Use to test new paths manually if needed

3. **MapManager singleton (MapConfiguration.swift:635-664)**
   - Handles map selection and provides current map data
   - Methods: `selectMap()`, `selectRandomMap()`, `getCurrentRoadPath()`
   - **No changes needed** - automatically works with new enum cases

---

## Test Strategy Discovered

### Testing Framework
- **Framework:** XCTest (Swift's built-in testing framework)
- **Test runner command:** `swift test` or `swift test --filter MapConfigurationTests`
- **Config location:** Package.swift defines test targets

### Test Structure Pattern
**Found in:** `Tests/BugDefenseTests/BugMovementTests.swift:1-66`

```swift
@MainActor
final class MapConfigurationTests: XCTestCase {
    // Helper functions first (lines 8-65 pattern)

    func testNewMapsPathValidity() {
        // Test each new map
    }
}
```

### Test Helper Patterns
- `createTestBug(path:bugType:wave:slowFactor:)` - Creates configured Bug instance
- `runUpdatesUntilCompletion(bug:finalWaypoint:maxIterations:)` - Simulates movement
- `assertPositionNear(_:_:tolerance:)` - Custom assertion for position validation

### Recommended Tests for New Maps
**File to create:** `Tests/BugDefenseTests/MapConfigurationTests.swift`

**Test cases needed:**
1. `testNewMapsExist()` - Verify MapType.allCases.count >= 30
2. `testNewMapsPathValidity()` - Validate each new map:
   - Path has at least 2 waypoints
   - Last waypoint equals housePosition (10, 7)
   - All waypoints within safe zone (x:1-18, y:1-13)
   - First waypoint at grid edge (x=1, x=18, y=1, or y=13)
3. `testRandomSelectionIncludesNewMaps()` - Verify new maps can be randomly selected

### Mock/Fixture Patterns
Not needed for map validation tests - maps are self-contained data structures.

---

## Risks & Challenges Identified

### Technical Risks

1. **Duplicate Pattern Names**
   - **Likelihood:** Medium
   - **Impact:** Low (compile-time error, easy to fix)
   - **Evidence:** Existing maps use unique descriptive names
   - **Mitigation:** Check all 20 existing names before naming new maps
   - **Fallback:** Use generic "Map 21" format if creative names are duplicates

2. **Out-of-Bounds Waypoints**
   - **Likelihood:** Medium
   - **Impact:** High (breaks gameplay, bugs may disappear)
   - **Evidence:** Safe zone is strictly enforced (x:1-18, y:1-13)
   - **Mitigation:** Validate each waypoint during design phase
   - **Fallback:** Unit tests will catch violations before runtime

3. **Path Doesn't Reach House**
   - **Likelihood:** Low
   - **Impact:** Critical (bugs never reach destination)
   - **Evidence:** All 20 existing maps end at GridPosition(x: 10, y: 7)
   - **Mitigation:** Always end path array with `GridPosition(x: 10, y: 7)`
   - **Fallback:** Unit test will catch this immediately

4. **Forgetting to Add Switch Case**
   - **Likelihood:** Medium
   - **Impact:** High (compile error, blocks all development)
   - **Evidence:** Swift requires exhaustive switch statements
   - **Mitigation:** Swift compiler will error if case missing
   - **Fallback:** Compiler error message will point to exact issue

5. **Unintentional Pattern Duplication**
   - **Likelihood:** Medium
   - **Impact:** Low (reduces variety, but functional)
   - **Evidence:** 20 existing patterns cover many common shapes
   - **Mitigation:** Review all maps before implementing, use taxonomy above
   - **Fallback:** Visual playtesting will reveal similarity

### Complexity Assessment
- **Overall complexity:** Low
- **Reasoning:** Adding data, not changing algorithms. Well-defined constraints. Clear patterns to follow.
- **Complex areas:**
  1. **Map design creativity:** Requires spatial visualization and variety
  2. **Balancing path lengths:** Must maintain difficulty distribution

### Missing Information / Ambiguities
None identified - task is well-specified with clear constraints and abundant examples.

---

## Execution Strategy Recommendation

**Based on research findings, execute in this order:**

### Step 1: Design Phase (Mental/Sketch)
- Review existing 20 maps visually (reference lines above)
- Sketch 10 new patterns on paper or grid tool
- Target pattern gaps: reverse spiral, symmetrical, dense zigzag, orbits, X-pattern, diamond, staircase, multi-loop, infinity, extreme diagonal
- Ensure variety: 3 short (8-12), 5 medium (13-23), 2 long (30+)
- Name each map descriptively

### Step 2: Implementation Phase
For each new map (map21 through map30):
1. **Add enum case** at `MapConfiguration.swift:~26`
   - Format: `case map21 = "Descriptive Name"`
2. **Implement path method** after line 632
   - Format: `private var map21Path: [GridPosition] { return [...] }`
   - Comment: `// Map 21: Name - Description`
3. **Add switch case** in roadPath property (~line 64)
   - Format: `case .map21: basePath = map21Path`

### Step 3: Validation Phase
1. **Compile check:** `swift build`
   - Ensures syntax correctness
   - Verifies exhaustive switch statement
2. **Create unit tests:** `Tests/BugDefenseTests/MapConfigurationTests.swift`
   - Follow pattern from `BugMovementTests.swift:1-10` for structure
   - Implement tests listed in "Test Strategy" section above
3. **Run tests:** `swift test --filter MapConfigurationTests`
4. **Manual playtesting (optional):**
   - Build and run game
   - Force map selection to new maps
   - Verify visual appearance and playability

### Step 4: Documentation Phase
- Document findings in this RESEARCH.md
- No additional documentation needed (maps are self-documenting via names)

---

**Research completed:** 2025-11-20
**Total similar components found:** 20 existing maps analyzed
**Total reusable components identified:** 3 (GridPosition, expandPath, MapManager)
**Estimated complexity:** Low
**Ready for parallel execution:** Yes - TASK1 through TASK10 can implement maps independently following these patterns
