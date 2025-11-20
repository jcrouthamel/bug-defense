# 🎯 Purpose

Create 10 new unique maps for the Bug Defense tower defense game and implement a waypoint-based pathfinding system that keeps bugs strictly on predefined paths to the house.

**Why this matters:** The current game needs more map variety to increase replayability and engagement. Additionally, a waypoint system ensures bugs follow intended paths rather than using dynamic pathfinding, which provides better gameplay control and visual clarity for players.

**Success definition:**
- 10+ distinct, playable map layouts with varied path patterns
- Bugs follow waypoint paths precisely without deviation
- Paths are visually distinct on the grid
- House position remains consistent across maps
- Random map selection works correctly

---

# 📁 Environment & Codebase Context

## Tech Stack
- **Language:** Swift 5.x
- **Framework:** SpriteKit (Apple's 2D game engine)
- **Platform:** macOS and iOS (cross-platform using conditional compilation)
- **Build Tool:** Swift Package Manager
- **Architecture:** Entity-Component pattern with managers

## Project Structure
```
Sources/BugDefense/
├── GameScene.swift           # Main game loop and scene management
├── Bug.swift                 # Enemy entity with movement logic
├── MapConfiguration.swift    # Map definitions and waypoint paths
├── MapManager.swift          # Current map selection (inside MapConfiguration.swift)
├── GameConfiguration.swift   # Global game constants
├── DefenseStructure.swift    # Tower base class
├── GameState.swift          # Game state management
└── [Other game systems...]
```

## Grid System
- **Grid Size:** 20x15 tiles (GameConfiguration.gridWidth x gridHeight)
- **Tile Size:** 40 points (GameConfiguration.tileSize)
- **World Size:** 800x600 points
- **Safe Zone:** Grid positions within x:1-18, y:1-13 (avoiding edges)
- **House Position:** Fixed at GridPosition(x: 10, y: 7) - center of grid
- **Coordinate System:** Origin at bottom-left (standard SpriteKit)

## Current Architecture

### Map System
- **MapType enum:** Defines all available map layouts (currently 20 maps)
- Each map has:
  - `roadPath`: Array of GridPosition waypoints defining the bug path
  - `housePosition`: Where the house is located (always center)
  - `spawnPoints`: Where bugs spawn (first position of roadPath)
- **MapManager:** Singleton that manages current map selection and provides path data

### Bug Movement System (Critical Context)
Bugs use a **waypoint-following system** (Bug.swift:240-302):
1. Each bug receives a path array via `setPath()`
2. In `update()`, bugs move toward the current waypoint using **normalized vector movement**
3. When within 2 points of a waypoint, they snap to it and advance to the next
4. Movement is calculated using: `position += (direction / distance) * moveDistance`

**Key Implementation Detail (Bug.swift:292-300):**
```swift
// Use normalized vector movement for all directions
let normalizedDx = dx / distance
let normalizedDy = dy / distance
position.x += normalizedDx * moveDistance
position.y += normalizedDy * moveDistance
```

This ensures bugs:
- Move in straight lines between waypoints
- Stay precisely on the path
- Handle diagonal, horizontal, and vertical segments identically

### Visual Grid System (GameScene.swift:237-304)
The grid is rendered with:
- Road tiles: Brown dirt color (fills roadPath positions)
- Grass tiles: Green (buildable areas)
- House tile: Dark green
- Decorative elements: Trees, rocks, bushes (randomly placed on non-road tiles)

### Integration Points
- **GameScene.swift:488-504:** `spawnBug()` retrieves the current map's road path and assigns it to bugs
- **GameScene.swift:1009-1018:** `recalculateBugPaths()` updates all active bugs when structures are placed
- **GameScene.swift:305-314:** `redrawGrid()` refreshes visual grid when map changes
- **GameScene.swift:826-856:** `canPlaceStructure()` prevents tower placement on roads

---

# 🧩 Related Code Context

### Similar Map Pattern Examples (MapConfiguration.swift)
- **Map 1 (Winding Road):** Classic serpentine with multiple turns - see lines 118-137
- **Map 9 (Straight Shot):** Simple horizontal path - see lines 319-332
- **Map 11 (Box Spiral):** Complex spiral from outside to center - see lines 350-412
- **Map 5 (Maze Runner):** Intricate maze-like path - see lines 205-239

### Path Expansion System (MapConfiguration.swift:70-103)
The `expandPath()` method takes waypoint corners and fills in all intermediate GridPositions:
- Calculates deltas (dx, dy) between consecutive waypoints
- Interpolates positions using integer division
- Ensures no gaps or duplicates
- This allows defining paths with just key turning points

### Map Selection Flow
1. **Initialization:** MapManager starts with map1
2. **Random Selection:** `MapManager.shared.selectRandomMap()` picks from MapType.allCases
3. **Tier Progression:** Maps change at tier boundaries (every 10 waves) - see GameScene.swift:1287-1290
4. **Map Switching:** Triggers grid redraw and tower reset

### Constraints
- **No structures on roads:** GameScene.swift:840-844 blocks tower placement on roadPath
- **House position blocked:** GameScene.swift:834-838 prevents building on house
- **Grid boundaries:** All positions must be within 0-19 (x) and 0-14 (y)
- **Path connectivity:** First waypoint must be spawn point, last must reach house

---

# ✅ Acceptance Criteria

Each criterion below must be independently verifiable:

## Map Design Requirements
- [ ] Create at least 10 new unique map layouts (beyond existing maps)
- [ ] Each map has a distinct visual pattern (zigzag, spiral, S-curve, etc.)
- [ ] All paths stay within safe zone boundaries (x:1-18, y:1-13)
- [ ] Paths start at an edge position (spawn point)
- [ ] Paths end at house position GridPosition(x: 10, y: 7)
- [ ] No path segment overlaps with house position (except final destination)
- [ ] Path lengths vary (some short and direct, some long and winding)
- [ ] Mix of difficulty levels (easy straight paths, complex maze-like paths)

## Waypoint System Requirements
- [ ] Each map's waypoint array defines the complete bug path
- [ ] Waypoints are stored as `[GridPosition]` arrays
- [ ] Path expansion correctly fills intermediate tiles between waypoints
- [ ] Bugs spawn at the first waypoint position
- [ ] Bugs move sequentially through waypoints using vector-based movement
- [ ] Bugs snap to exact waypoint position when within 2-point threshold
- [ ] Bugs advance to next waypoint after reaching current target
- [ ] Final waypoint matches house position

## Visual Requirements
- [ ] Road tiles (brown) correctly render along entire path
- [ ] Grass tiles (green) render on non-path areas
- [ ] House position renders with distinct darker green
- [ ] No visual gaps in road paths
- [ ] Grid updates correctly when map changes

## Integration Requirements
- [ ] `MapType.random()` can select from all maps including new ones
- [ ] `MapManager.selectRandomMap()` works with expanded map pool
- [ ] Bugs receive correct path via `setPath()` when spawned
- [ ] Tower placement blocked on all road positions
- [ ] Path recalculation works when map changes mid-game
- [ ] Grid redraw reflects new map layout

## Edge Cases & Error Scenarios
- [ ] **Diagonal segments:** Bugs move smoothly on diagonal paths without stair-stepping
- [ ] **Sharp turns:** Bugs navigate 90-degree turns precisely
- [ ] **Long straight segments:** Bugs don't drift off path on extended straight lines
- [ ] **Map switching:** Changing maps mid-game doesn't crash or leave orphaned bugs
- [ ] **Empty paths:** System handles degenerate cases (though shouldn't occur)
- [ ] **Path validation:** No map creates unreachable or blocked paths

---

# ⚙️ Implementation Guidance

## Execution Layers

### Layer 0: Foundation (Must Complete First)
1. **Review existing map patterns** in MapConfiguration.swift (lines 115-631)
2. **Understand GridPosition system** and coordinate mapping
3. **Analyze vector movement implementation** in Bug.swift (lines 275-301)
4. **Study path expansion algorithm** in MapConfiguration.swift (lines 70-103)

### Layer 1: Map Design (Can Parallelize)
For each new map:
1. **Design waypoint pattern** on paper/sketch (20x15 grid)
2. **Define key turning points** as GridPosition array
3. **Name map** with descriptive MapType case (e.g., .map21, .map22, etc.)
4. **Implement path method** returning waypoint array
5. **Add to switch statement** in `var roadPath`

Example new map structure:
```swift
case .map21 = "Creative Name"

private var map21Path: [GridPosition] {
    return [
        GridPosition(x: 1, y: 5),   // Spawn point (edge)
        GridPosition(x: 3, y: 5),
        GridPosition(x: 3, y: 8),
        // ... more waypoints ...
        GridPosition(x: 10, y: 7)   // House position (end)
    ]
}
```

### Layer 2: System Integration
1. **Add new MapType cases** to enum (line 5)
2. **Add to allCases** (automatic via CaseIterable)
3. **Update switch in roadPath** (line 43)
4. **Test random selection** picks new maps

### Layer 3: Visual & Gameplay Validation
1. **Verify grid rendering** shows road correctly
2. **Test bug spawning** at first waypoint
3. **Observe bug movement** through entire path
4. **Confirm tower blocking** on road tiles
5. **Test map switching** between old and new maps

## Expected Artifacts

### Code Changes
- **MapConfiguration.swift:**
  - Add 10+ new MapType enum cases
  - Implement corresponding path methods
  - Update roadPath switch statement

### Tests
**Philosophy:** Test the new maps integration, not the existing engine.

**Scope:**
- Unit tests for new map path validity (paths reach house, stay in bounds)
- Integration test for map selection (random picks from full pool)
- Visual verification (manual playtesting)

**Skip:**
- Vector movement logic (already implemented and working)
- Path expansion algorithm (core system, not changed)
- UI rendering (SpriteKit built-in)

### Configuration
No configuration changes needed - maps are compile-time definitions.

### Documentation
- Update AI_PROMPT.md with implementation notes
- Add inline comments for complex path patterns
- Document map characteristics (difficulty, length, pattern type)

## Constraints

### What NOT to Do
- ❌ Don't modify the vector movement algorithm in Bug.swift (already optimal)
- ❌ Don't change the grid size or tile size (affects entire game balance)
- ❌ Don't move the house position (fixed game design requirement)
- ❌ Don't create paths that go outside safe zone x:1-18, y:1-13
- ❌ Don't add dynamic pathfinding (defeats purpose of waypoint system)
- ❌ Don't modify path expansion algorithm (working correctly)

### Performance Requirements
- Map selection must be O(1) - use enum cases, not dynamic loading
- Path arrays should be pre-computed, not generated at runtime
- Keep path arrays reasonable length (10-50 waypoints typical)

### Design Guidelines
- **Variety:** Mix straight, curved, zigzag, spiral, maze patterns
- **Balance:** Some easy (short/direct), some hard (long/complex)
- **Visual Appeal:** Paths should look intentional, not random
- **Gameplay:** Longer paths = more time to place towers = easier
- **Theming:** Consider naming maps after patterns (Cloverleaf, Lightning, etc.)

---

# 5.1 Testing Guidance (Minimal & Relevant)

## Philosophy
Test changed code with minimum sufficient evidence. Focus on integration of new maps, not re-testing existing engine.

## Testing Approach

### Unit Tests Required
**File to create:** `Tests/BugDefenseTests/MapConfigurationTests.swift`

Test only new map path validity:
```swift
func testNewMapsPathValidity() {
    let newMaps: [MapType] = [.map21, .map22, /* ... */]

    for map in newMaps {
        let path = map.roadPath

        // Must have at least 2 points (start and end)
        XCTAssertGreaterThanOrEqual(path.count, 2)

        // Must end at house
        XCTAssertEqual(path.last, map.housePosition)

        // All points must be in bounds
        for pos in path {
            XCTAssertTrue(pos.x >= 0 && pos.x < 20)
            XCTAssertTrue(pos.y >= 0 && pos.y < 15)
        }
    }
}

func testMapRandomSelectionIncludesNewMaps() {
    // Verify new maps can be randomly selected
    let allMaps = MapType.allCases
    XCTAssertGreaterThanOrEqual(allMaps.count, 30) // 20 existing + 10 new
}
```

### Integration Tests
**Manual testing procedure:**
1. Build and run game
2. Use dev console or code to cycle through new maps
3. Verify:
   - Bugs spawn at start of path
   - Bugs follow path precisely to house
   - Road tiles render along path
   - Towers can't be placed on road
4. Test map switching mid-game (tier progression)

### Skip These Tests
- ❌ Bug movement logic (unchanged, already tested)
- ❌ Path expansion algorithm (core system, not modified)
- ❌ Grid rendering (SpriteKit framework responsibility)
- ❌ Collision detection (no changes)

## Coverage Target
- **100% of new map definitions** (path validity tests)
- **Integration points** (map selection, path assignment)
- **Zero coverage needed** for unchanged systems

## Test Execution
Run tests with:
```bash
swift test --filter MapConfigurationTests
```

Manual playtesting: 5-10 minutes per new map to verify visual and gameplay correctness.

---

# 🔍 Verification and Traceability

## Requirements Mapping
Every aspect of the user's original request must be addressed:

| User Requirement | Implementation Location | Verification Method |
|-----------------|------------------------|---------------------|
| "create 10 new maps" | MapConfiguration.swift enum cases | Count new MapType cases |
| "waypoint system" | Bug.swift setPath() + update() | Observe bug movement |
| "keep bugs on path" | Vector-based movement (Bug.swift:292-300) | Visual confirmation |
| "store waypoints as array of CGPoint" | [GridPosition] arrays (equivalent to CGPoint) | Code inspection |
| "move to next point in game loop" | Bug.update() method | Runtime observation |
| "check proximity" | distance < 2 threshold (Bug.swift:280) | Code inspection |
| "switch target to next waypoint" | pathIndex += 1 (Bug.swift:284) | Code inspection |
| "loop/end behavior" | Path ends at house (no loop) | Game design verification |

## Self-Verification Checklist for AI Agent

Before considering task complete, verify:
- [ ] At least 10 new MapType enum cases added
- [ ] Each new map has corresponding path method implemented
- [ ] All new maps added to roadPath switch statement
- [ ] Compiled successfully without errors
- [ ] Tests pass (if written)
- [ ] Manually tested at least 3 new maps in-game
- [ ] Bugs follow paths precisely (no diagonal drift)
- [ ] Road tiles render correctly
- [ ] Random map selection includes new maps
- [ ] No regression in existing map functionality

## Completeness Criteria
**The task is complete when:**
1. ✅ 10+ new maps are defined in MapConfiguration.swift
2. ✅ All new maps follow existing pattern and conventions
3. ✅ Bugs navigate new maps correctly using waypoint system
4. ✅ Visual grid renders new paths properly
5. ✅ No existing functionality broken
6. ✅ Code compiles and runs without errors
7. ✅ Basic tests validate new map properties

**The task is NOT complete if:**
- ❌ Fewer than 10 new maps
- ❌ Any map paths go outside safe zone
- ❌ Bugs don't reach house or get stuck
- ❌ Road tiles don't render on path
- ❌ Compilation errors exist
- ❌ Existing maps stop working

---

# 🧠 Reasoning Boundaries

## Design Philosophy
- **Favor simplicity:** Follow existing MapType pattern exactly
- **Preserve working systems:** Don't modify Bug movement or path expansion
- **Visual variety over complexity:** Maps should look different, not necessarily be harder
- **Playability first:** Every map must be completable and fair

## When to Ask vs. Assume
**Ask the user if:**
- Desired map difficulty distribution is unclear (easy/medium/hard ratio)
- Specific themes or patterns are requested
- House position should ever vary (current design: always center)
- Path lengths should have min/max limits

**Safe to assume:**
- Follow existing map naming pattern (map21, map22, etc.)
- Use existing GridPosition/waypoint infrastructure
- Maintain current safe zone boundaries
- Keep house at GridPosition(x: 10, y: 7)
- Mix various path patterns for variety

## System Coherence Over Features
- Don't add dynamic pathfinding (contradicts waypoint system goal)
- Don't add multiple paths per map (current design: single path)
- Don't add branching paths (house has one entrance)
- Don't optimize path expansion (already efficient)
- Don't change coordinate system (would break everything)

## Pattern Adherence
**Existing conventions to follow:**
- Map enum cases: `.map##` format
- Path methods: `private var map##Path: [GridPosition]`
- Naming: Descriptive string (e.g., "Winding Road")
- Path structure: Start at edge, end at house, stay in safe zone
- Comment style: `// Map ##: Name - Description`

---

# 📊 Success Metrics

**Quantitative:**
- 10+ new maps added (countable)
- 0 compilation errors
- 0 regression bugs
- 100% of new maps reach house position
- 100% of new maps stay in safe zone

**Qualitative:**
- Maps feel distinct and varied
- Paths look intentional and well-designed
- Bugs move smoothly without visual glitches
- Players can strategically place towers around paths
- Game remains balanced and fair

**Time-to-Completion Estimate:**
- Map design: 1-2 hours (sketching patterns)
- Implementation: 2-3 hours (coding waypoints)
- Testing: 1 hour (validation)
- Total: 4-6 hours for experienced Swift developer

---

# 🎓 Additional Context

## Why Waypoint System Over Dynamic Pathfinding

**Benefits of predefined waypoint paths:**
1. **Predictable gameplay:** Players can plan tower placement strategically
2. **Visual clarity:** Road tiles show exact bug path
3. **Performance:** No A* computation every frame
4. **Control:** Designers specify exact path difficulty and length
5. **Art direction:** Paths can follow aesthetic patterns

**Trade-offs:**
- Less emergent gameplay (towers don't affect pathing)
- Towers can't block paths (by design - roads are unblockable)
- Flying bugs still use dynamic pathfinding (special case)

## Historical Context
The recent commit "Complete TASK1: Implement vector-based bug movement for strict path adherence" (f3c04b3) likely addressed diagonal drift issues. The normalized vector approach ensures bugs don't "stair-step" on diagonal segments.

## Future Extensibility
If more maps are needed later:
- Pattern established, easy to add more
- Could add map difficulty ratings for adaptive selection
- Could implement map packs or themes
- Could allow user-generated maps (save/load waypoint arrays)

But for this task: focus on the 10 new maps requested.

---

# 📝 Final Notes for Implementing Agent

You are receiving a well-defined task with clear boundaries:
- **Input:** Existing 20-map system with waypoint infrastructure
- **Output:** 30+ map system with 10+ new varied layouts
- **Risk:** Low - adding data, not changing algorithms
- **Complexity:** Moderate - requires spatial design creativity

**Start by:**
1. Reading MapConfiguration.swift thoroughly
2. Sketching 10 map patterns on paper/grid
3. Implementing maps one at a time
4. Testing each before moving to next

**Red flags to watch for:**
- Path doesn't reach house (fix immediately)
- Path goes out of bounds (move waypoints inward)
- Bugs get stuck or oscillate (check waypoint spacing)
- Visual gaps in road (path expansion issue - verify waypoints are connected)

**You've got this!** The infrastructure is solid, you're just adding creative map layouts. Trust the existing system, follow the patterns, and deliver variety and quality.
