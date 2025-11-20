# AI Execution Prompt: Ensure Bugs Stay on Path at All Times

## 1. 🎯 Purpose

**What:** Fix bug movement behavior to ensure bugs remain strictly on the predefined road path at all times, preventing visual drift or deviations during movement between waypoints.

**Why:** Currently, bugs can visually drift off the path during movement, especially when moving between waypoints. This breaks the visual and gameplay expectations that bugs should follow the brown dirt road path visible on the grid. The core game mechanic relies on bugs following predefined winding roads that cannot be blocked by towers.

**Success Definition:** Bugs move smoothly along the road path without ever visually appearing off the brown dirt road tiles, maintaining precise alignment with the path at all times during their journey from spawn to house.

---

## 2. 📁 Environment & Codebase Context

**Tech Stack:**
- Swift 5.x with SpriteKit framework
- macOS/iOS cross-platform game (tower defense)
- Git version control, currently on `feature/bugs-stay-on-path` branch
- Swift Package Manager for build management

**Project Structure:**
- `Sources/BugDefense/` - Main game source code
  - `GameScene.swift` - Main game loop and scene management
  - `Bug.swift` - Bug entity class with movement logic
  - `MapConfiguration.swift` - Map layouts and road path definitions
  - `PathfindingGrid.swift` - A* pathfinding (currently unused for ground bugs)
  - `GameState.swift` - Game state management
  - `GameConfiguration.swift` - Game constants and configuration
- `Tests/BugDefenseTests/` - Unit tests
- Grid system: 20x15 tiles (width x height), tile size 40 points
- Coordinate system: GridPosition (integer grid coords) ↔ world position (CGPoint in SpriteKit)

**Architecture Pattern:**
- Entity-Component pattern with SpriteKit nodes
- Managers handle game systems (GameStateManager, WaveManager, MapManager)
- Main game loop in `GameScene.update(_:)` calls entity updates

**Key Files:**
- **Bug.swift (Lines 254-316)**: `Bug.update(deltaTime:pathfindingGrid:)` method contains movement logic
- **MapConfiguration.swift (Lines 40-103)**: Path definition and expansion to include all tiles
- **GameScene.swift (Lines 488-504, 1009-1018)**: Bug spawning and path assignment
- **GameConfiguration.swift**: Contains tile size (40.0) and grid dimensions (20x15)

**Current Movement System:**
Bugs receive a predefined road path from `MapManager.shared.getCurrentRoadPath()` which is an array of `GridPosition` waypoints. The path includes ALL tiles between major waypoints (expanded via `expandPath()` in MapConfiguration.swift:71-103). Bugs move from waypoint to waypoint using delta-time based movement in `Bug.update()`.

**Existing Conventions:**
- Grid coordinates: (0,0) is bottom-left, (19,14) is top-right
- World coordinates: Converted via `GridPosition.toWorldPosition()` (position * tileSize + tileSize/2)
- Emoji-based sprite rendering for bugs (🐜, 🪲, 🕷️, etc.)
- Movement speed is wave-scaled and can be slowed by towers/traps
- Comments use emoji prefixes (🐛 for bugs, 🗺️ for maps, etc.)

**Current State:**
The movement logic in `Bug.swift:254-316` attempts to lock movement to horizontal or vertical segments, but bugs can still drift diagonally or cut corners between waypoints, especially on curved paths. The issue is in the movement calculation between waypoints (lines 276-315).

---

## 3. 🧩 Related Code Context

**Movement Logic Reference (Bug.swift:254-316):**
The current `update(deltaTime:pathfindingGrid:)` method:
1. Gets target waypoint from `movementPath[pathIndex]`
2. Calculates distance to target
3. Attempts to determine segment direction (horizontal/vertical/diagonal)
4. Moves toward target using `moveSpeed * slowFactor * deltaTime`
5. Snaps to exact position when within 2 points of waypoint

**Problem Areas:**
- Lines 292-315: Movement calculation that attempts axis-locking but uses imprecise heuristics
- Line 298-303: Diagonal movement allows free movement in both axes
- Lines 304-314: Horizontal/vertical locking uses `deltaX > deltaY` heuristic which doesn't guarantee on-path movement

**Path Definition Pattern (MapConfiguration.swift:71-103):**
Paths are defined as sparse waypoints, then expanded to include every grid tile between waypoints. This ensures bugs have fine-grained waypoints to follow. Example:
```swift
// Sparse definition
[GridPosition(x: 1, y: 3), GridPosition(x: 4, y: 3), GridPosition(x: 4, y: 7)]

// Expands to every tile in between
[GridPosition(x: 1, y: 3), GridPosition(x: 2, y: 3), GridPosition(x: 3, y: 3),
 GridPosition(x: 4, y: 3), GridPosition(x: 4, y: 4), GridPosition(x: 4, y: 5), ...]
```

**Grid-World Conversion Pattern (GameConfiguration.swift):**
```swift
// GridPosition to world position
func toWorldPosition() -> CGPoint {
    let tileSize = GameConfiguration.tileSize // 40.0
    return CGPoint(
        x: CGFloat(x) * tileSize + tileSize / 2,
        y: CGFloat(y) * tileSize + tileSize / 2
    )
}
```

**Integration Points:**
- `GameScene.update(_:)` → `Bug.update(deltaTime:pathfindingGrid:)` (called every frame)
- `Bug.setPath(_:)` called when spawning (GameScene.swift:500)
- Movement affects `Bug.position` (SpriteKit world coords) and `Bug.gridPosition` (grid coords)
- Visual rendering automatically follows `position` property

---

## 4. ✅ Acceptance Criteria

The solution must satisfy ALL of the following requirements:

- [ ] **Strict Path Adherence**: Bugs MUST remain visually on the brown dirt road tiles at all times during movement. No part of the bug sprite should appear significantly off-path during transit between waypoints.

- [ ] **Waypoint-to-Waypoint Movement**: Bugs move sequentially through each waypoint in the path array without skipping, cutting corners, or taking shortcuts.

- [ ] **Smooth Visual Motion**: Movement appears smooth and continuous, not jerky or teleporting. Bugs should move at their designated speed (considering wave scaling and slow factors).

- [ ] **Exact Waypoint Arrival**: When a bug reaches a waypoint, its position should snap to the exact world position of that grid tile before advancing to the next waypoint.

- [ ] **Preserve Diagonal Path Segments**: Some map paths include diagonal movements (e.g., Map 15: Diagonal). These must work correctly without causing bugs to drift off-path.

- [ ] **Horizontal and Vertical Segments**: Standard orthogonal movement must remain perfectly aligned with the path tiles.

- [ ] **No Regression**: Flying bugs (mosquito, wasp) are unaffected. Burrowing bugs maintain their special mechanics. All other bug types function correctly.

- [ ] **Speed Consistency**: Movement speed calculations remain accurate. Bugs respect their `moveSpeed`, wave scaling, and `slowFactor` multipliers.

- [ ] **Grid Position Sync**: The `Bug.gridPosition` property stays synchronized with the bug's visual `position` throughout movement.

- [ ] **Edge Cases Handled**:
  - Bugs starting exactly at spawn point (first waypoint)
  - Bugs reaching the house (last waypoint)
  - Very slow bugs (due to slow traps/towers)
  - Very fast bugs (spiders, wasps with wave scaling)
  - Paths with many small segments vs. few long segments

- [ ] **All Maps Work**: The fix must work correctly across all 20 map layouts (map1-map20) without special-casing.

- [ ] **Performance**: No significant performance degradation. The fix should not add expensive calculations per frame per bug.

---

## 5. ⚙️ Implementation Guidance

### Execution Strategy

**Root Cause Analysis:**
The current movement logic (Bug.swift:292-315) tries to infer segment direction from waypoint deltas and lock axes accordingly. However, this approach:
1. Doesn't account for the bug's current position relative to the path
2. Allows diagonal movement that can drift off-path
3. Uses imprecise heuristics (`deltaX > deltaY`) that don't guarantee path alignment

**Recommended Approach:**
Instead of inferring segment direction, **strictly constrain movement to stay on the line between current grid position and target waypoint**. Since the path is already expanded to include all intermediate tiles, the bug should:
1. Move directly toward the target waypoint's exact world position
2. Use proper vector normalization to maintain speed while moving toward target
3. Lock position exactly to the waypoint's world position when close enough
4. Only then advance to the next waypoint

**Alternative: Tile-by-Tile Movement**
An even simpler approach: Since paths are already expanded to every tile, treat each waypoint transition as moving to an adjacent or diagonal tile. Lock movement perfectly to the path by:
1. Moving in a straight line toward the current waypoint's world position
2. Maintaining speed by normalizing the direction vector
3. Snapping precisely when close enough (within 1-2 points)

### Implementation Layers

**Layer 0 (Foundation):**
1. **Analyze current Bug.update() method** (lines 254-316)
   - Understand how `pathIndex` tracks progress
   - Identify where position drift occurs
   - Determine why axis-locking fails

2. **Review path expansion logic** (MapConfiguration.swift:71-103)
   - Confirm paths include all intermediate tiles
   - Verify waypoints are properly ordered
   - Check for any gaps or issues

**Layer 1 (Core Fix):**
1. **Rewrite movement calculation** (Bug.swift:276-315)
   - Calculate direction vector from current position to target waypoint world position
   - Normalize the direction vector
   - Apply speed and delta time: `moveDistance = moveSpeed * slowFactor * CGFloat(deltaTime)`
   - Move along direction: `position += normalizedDirection * moveDistance`
   - Remove the segment-type detection heuristics (lines 292-314)

2. **Improve waypoint detection** (Bug.swift:280-285)
   - Keep the distance check and snap behavior
   - Ensure position snaps EXACTLY to `targetWorldPos` when waypoint reached
   - Verify `gridPosition` updates correctly
   - Ensure `pathIndex` increments only after snap

**Layer 2 (Validation):**
1. **Add debug logging** (temporary)
   - Log bug position vs. expected waypoint position
   - Track distance from path centerline
   - Verify pathIndex progression

2. **Visual verification**
   - Test on multiple maps (especially Map 15: Diagonal, Map 8: U-Turns)
   - Watch bugs closely during curves and turns
   - Verify no visual drift off brown road tiles

### Expected Code Changes

**Primary File: Bug.swift**
- Modify `update(deltaTime:pathfindingGrid:)` method (lines 254-316)
- Simplify movement logic to direct vector-based movement
- Ensure position snapping is precise

**No changes needed:**
- MapConfiguration.swift (paths are already correct)
- GameScene.swift (spawning logic is fine)
- PathfindingGrid.swift (not used for ground bugs)

### Constraints

**What NOT to do:**
- Do NOT change the path definition system in MapConfiguration.swift
- Do NOT add pathfinding for ground bugs (they use predefined paths)
- Do NOT modify the grid-to-world coordinate conversion logic
- Do NOT change bug speed calculations or wave scaling
- Do NOT add complex state machines or animation systems

**Performance Requirements:**
- Movement calculation is called every frame for every active bug
- Solution must be computationally simple (basic vector math only)
- Avoid allocations in hot path (use existing properties)

**Backward Compatibility:**
- Preserve all bug properties (health, speed, damage, slow factor, etc.)
- Maintain existing burrowing behavior (lines 258-270)
- Keep flying bug behavior unchanged (they use different pathfinding)

---

## 5.1 Testing Guidance (Minimal & Relevant)

**Philosophy:** Test changed code with minimum sufficient evidence. Focus on movement correctness.

**Test Scope:**
- **Unit Tests:** Test the `Bug.update()` movement logic in isolation
  - Create a bug with a simple 3-waypoint path
  - Call `update()` multiple times with fixed deltaTime
  - Verify bug reaches each waypoint exactly
  - Verify position never drifts significantly from expected path

- **Manual Testing:** Visual verification is critical for this fix
  - Run the game and observe bugs on different maps
  - Use Map 1 (Winding Road), Map 8 (U-Turns), Map 15 (Diagonal)
  - Verify bugs stay on brown road tiles throughout journey
  - Test with slow bugs (beetles) and fast bugs (spiders, wasps)

**Test Cases:**

1. **Straight Horizontal Path**
   - Bug moves from (1,5) → (5,5)
   - Position.y should remain constant at world Y for y=5
   - Bug should arrive exactly at each waypoint

2. **Straight Vertical Path**
   - Bug moves from (5,1) → (5,5)
   - Position.x should remain constant at world X for x=5
   - Bug should arrive exactly at each waypoint

3. **Diagonal Path**
   - Bug moves from (2,2) → (5,5)
   - Bug should move in a straight line through intermediate diagonal tiles
   - Should pass through (3,3) and (4,4) if those are waypoints

4. **Complex Curved Path**
   - Use actual map path (e.g., Map 1)
   - Bug completes entire path
   - Visual verification: no drift off road tiles
   - Functional verification: reaches house position

5. **Edge Cases**
   - Very slow bug (slowFactor = 0.1) still moves correctly
   - Very fast bug (wasp with wave 50 scaling) doesn't skip waypoints
   - Bug starting exactly at first waypoint

**Success Criteria:**
- All unit tests pass
- Manual testing shows no visible drift on any of the 20 maps
- Bugs reach house correctly
- No performance degradation

**Coverage Target:**
- 100% of changed lines in Bug.update() method
- If any edge case cannot be covered, document in code comments

---

## 6. 🔍 Verification and Traceability

**Requirement Traceability:**
Every acceptance criterion must be explicitly addressed in the implementation or test plan. The implementation must demonstrate:

1. **Path adherence** → Verified by unit tests checking position against waypoint path
2. **Waypoint-to-waypoint movement** → Verified by pathIndex progression logic
3. **Smooth motion** → Verified by normalized vector movement calculation
4. **Exact arrival** → Verified by position snap when distance < threshold
5. **Diagonal paths** → Verified by testing Map 15 specifically
6. **Orthogonal paths** → Verified by testing Map 9 (Straight Shot)
7. **No regression** → Verified by maintaining existing special bug behavior code
8. **Speed consistency** → Verified by preserving speed calculation formula
9. **Grid sync** → Verified by updating gridPosition on waypoint arrival
10. **Edge cases** → Verified by specific test cases
11. **All maps** → Verified by testing representative sample of maps
12. **Performance** → Verified by profiling or ensuring O(1) calculations per frame

**Self-Verification Checklist for Downstream Agent:**
Before marking the task complete, verify:
- [ ] Code review: Does the movement logic make geometric sense?
- [ ] Unit tests: Do tests cover the critical cases?
- [ ] Manual testing: Did you actually run the game and watch bugs?
- [ ] Multiple maps: Did you test at least 3 different map types?
- [ ] Bug types: Did you test with both slow and fast bugs?
- [ ] Code clarity: Is the movement logic simple and understandable?
- [ ] No regressions: Do flying bugs and burrowers still work?
- [ ] Documentation: Are any complex decisions explained in comments?

---

## 7. 🧠 Reasoning Boundaries

**System Coherence:**
- Follow the existing pattern of entity updates in `GameScene.update()` → entity `update(deltaTime:)` chain
- Maintain the SpriteKit node hierarchy and coordinate system
- Preserve the grid-world dual representation pattern used throughout the codebase

**Existing Patterns to Follow:**
- Use CGPoint for world positions, GridPosition for grid coordinates
- Update both `position` and `gridPosition` properties
- Use emoji-prefixed print statements for logging
- Follow Swift naming conventions (camelCase, descriptive names)

**When to Simplify:**
- If the current axis-locking logic is complex and error-prone, replace it entirely with simpler vector math
- Don't add abstraction layers for a single-purpose movement calculation
- Don't create separate classes/structs for movement when inline calculation suffices

**When Uncertain:**
- If the fix requires changing map path definitions → Stop and ask
- If performance testing shows significant slowdown → Stop and discuss optimization
- If flying bugs are affected → Stop and verify separation of concerns
- If the fix seems to require major refactoring → Stop and propose simpler alternative

**Preserve Over Rewrite:**
- Keep the burrowing behavior section (lines 258-270) exactly as-is
- Keep the path assignment system (setPath method) unchanged
- Keep the health bar and damage logic untouched
- Only modify the movement calculation section

---

## 8. 📝 Additional Context

**User's Original Request:**
"keep bugs on the path at all times"

**Clarifications:**
No clarification answers were provided (CLARIFICATION_ANSWERS.json was empty), so the prompt assumes:
- "Path" refers to the predefined road paths defined in MapConfiguration.swift
- "At all times" means during all movement between spawn and house
- The issue is a visual/behavioral bug, not a design change request

**Current Branch:**
`feature/bugs-stay-on-path` - Already created and checked out

**Recent Changes:**
Based on git status, recent work includes:
- Tier progression system modifications
- GameState and GameScene updates
- Test fixes related to currency

These changes are unrelated to the bug movement issue and should not be affected by this fix.

**Success Looks Like:**
A player watching bugs move along the winding road paths should see them follow the brown dirt road tiles precisely, like a train on tracks, with smooth continuous movement but no deviation from the path.

---

## 9. 🎓 Learning Notes

**Why This Matters:**
Tower defense games rely on predictable enemy movement. If bugs drift off the visible path, it creates confusion about:
- Where to place towers for optimal coverage
- Whether the pathfinding is working correctly
- Game balance (path length affects difficulty)

**Key Insight:**
Since paths are pre-expanded to include every tile, the solution doesn't need complex pathfinding or curve-following algorithms. Simple point-to-point movement with proper vector math is sufficient.

**Potential Pitfall:**
Normalizing very small direction vectors can cause NaN or divide-by-zero errors. The distance check (line 280) prevents this by snapping to the waypoint when close enough, avoiding the need to normalize when distance approaches zero.
