# AI Prompt: Enforce Road-Only Bug Movement in Bug Defense

## 1. 🎯 Purpose

**What:** Modify the bug pathfinding system to prevent tower placement on predefined road paths, ensuring all bugs (ground and flying) stay on designated map routes for each of the 20 map types.

**Why:** The user wants to guarantee that bugs always follow the intended map path design without using A* pathfinding fallbacks. This maintains the integrity of each map's strategic challenge by keeping bugs on predictable routes.

**Success Definition:**
- Players cannot place towers on road tiles (placement blocked with visual feedback)
- All bugs (ground and flying) exclusively follow predefined road paths
- Current smooth waypoint-to-waypoint movement behavior is preserved
- All 20 map types maintain their unique path characteristics

---

## 2. 📁 Environment & Codebase Context

### Tech Stack
- **Language:** Swift 5.x
- **Framework:** SpriteKit (Apple's 2D game engine)
- **Platform:** macOS and iOS (cross-platform)
- **Architecture:** Object-oriented with manager pattern
- **Build System:** Swift Package Manager

### Project Structure
```
Sources/BugDefense/
├── Bug.swift                    # Bug entity with movement logic
├── GameScene.swift              # Main game orchestration and placement
├── MapConfiguration.swift       # 20 map types with predefined paths
├── PathfindingGrid.swift        # A* pathfinding and flying paths
├── DefenseStructure.swift       # Base class for towers/traps
├── Tower.swift                  # Tower implementation
├── GameConfiguration.swift      # Global game constants
└── GridPosition.swift           # Grid coordinate system
```

### Current State
**Grid System:**
- Game uses a 20x15 tile grid (constants in GameConfiguration.swift)
- Each tile is 40x40 points (GameConfiguration.tileSize)
- GridPosition struct handles coordinate conversions
- World coordinates are centered, camera positioned at grid center

**Map System:**
- 20 unique map types (MapType enum with .map1 through .map20)
- Each map has a `roadPath: [GridPosition]` computed property
- Paths are defined as waypoint arrays, then expanded to include all intermediate tiles
- MapManager singleton (MapManager.shared) tracks current map selection
- Maps change every 10 waves (tier progression system)

**Current Bug Movement:**
- Bugs spawn at first waypoint of current map's road path
- When road is CLEAR: bugs follow predefined roadPath array
- When road is BLOCKED: bugs switch to A* pathfinding (GameScene.swift:1049-1087)
- Movement is smooth waypoint-to-waypoint with axis locking (Bug.swift:254-316)
  - Horizontal segments: Y-axis locked to target (line 308)
  - Vertical segments: X-axis locked to target (line 313)
  - Diagonal segments: Both axes move toward target (lines 299-303)

**Current Tower Placement:**
- canPlaceStructure() in GameScene.swift:866-896
- Currently checks: bounds, house position, existing structures
- Does NOT check if position is on road (this is the key change needed)
- Players can place towers anywhere except house and existing structures

**Flying Bugs:**
- Mosquito and wasp have canFly property (Bug.swift:106-113)
- Currently follow same paths as ground bugs (they don't use special behavior)
- PathfindingGrid has unused findFlyingPath() function (PathfindingGrid.swift:85-122)

---

## 3. 🧩 Related Code Context

### Key Files and Patterns to Follow

**Road Path Access Pattern:**
```swift
// Getting current road path (used throughout GameScene.swift)
let roadPath = MapManager.shared.getCurrentRoadPath()
// Returns: [GridPosition] expanded array of all tiles on the road
```

**Placement Validation Pattern (GameScene.swift:866-896):**
```swift
private func canPlaceStructure(at position: GridPosition) -> Bool {
    // Check bounds (lines 868-872)
    // Check house position (lines 875-878)
    // Check existing structures (lines 887-892)
    // ADD: Check if on road path
    return true/false
}
```

**Road Blocking Detection (GameScene.swift:1049-1060):**
```swift
private func isRoadPathBlocked(_ roadPath: [GridPosition]) -> Bool {
    // Currently used to decide if bugs should use A*
    // This function will become obsolete once towers can't be placed on roads
}
```

**Bug Path Assignment (GameScene.swift:510-544):**
```swift
private func spawnBug(_ bug: Bug) {
    let roadPath = MapManager.shared.getCurrentRoadPath()
    if isRoadPathBlocked(roadPath) {
        // A* fallback - REMOVE THIS
    } else {
        // Use predefined path - KEEP THIS as only behavior
    }
    bug.setPath(path)
}
```

**Similar Checks to Reference:**
- House position check: `if position == MapManager.shared.getCurrentHousePosition()`
- Array contains check: `if MapManager.shared.getCurrentRoadPath().contains(position)`

---

## 4. ✅ Acceptance Criteria

### Primary Requirements (Must Complete)

- [ ] **AC1:** Players cannot place towers on any road tile
  - [ ] `canPlaceStructure()` returns false when `position` is in current map's road path
  - [ ] Print message: "❌ Cannot place on road: \(position)" when placement attempted on road
  - [ ] Test on Map 1 (Winding Road), Map 9 (Straight Shot), and Map 11 (Box Spiral) - different path complexities

- [ ] **AC2:** Placement preview shows visual feedback for invalid road placement
  - [ ] Preview turns red when hovering over road tiles (already partially implemented for invalid placement)
  - [ ] Verify in `mouseMoved()` (macOS) and `touchesMoved()` (iOS) handlers

- [ ] **AC3:** Remove A* pathfinding fallback for all bugs
  - [ ] `spawnBug()` no longer checks `isRoadPathBlocked()`
  - [ ] All bugs receive `roadPath` directly without conditional logic
  - [ ] Remove or comment out the A* path assignment code block (GameScene.swift:522-528)

- [ ] **AC4:** Flying bugs follow road paths
  - [ ] Mosquito and wasp bugs use same road path as ground bugs
  - [ ] No special flying behavior active (keep current implementation where canFly is unused)
  - [ ] Verify by spawning mosquito/wasp bugs and observing they follow the road

- [ ] **AC5:** Path recalculation logic simplified
  - [ ] `recalculateBugPaths()` (GameScene.swift:1062-1087) removes road blocking check
  - [ ] All bugs always receive `roadPath` on recalculation
  - [ ] Function still needed when map changes during tier transitions

### Edge Cases and Error Scenarios

- [ ] **EC1:** Map transitions preserve road protection
  - [ ] When map changes (every 10 waves), new map's road path is protected
  - [ ] Towers placed before map change are not removed (already handled by resetAllTowers)

- [ ] **EC2:** House position remains protected
  - [ ] Existing house position check remains in place
  - [ ] House is always on/near the end of the road path - both checks should pass

- [ ] **EC3:** Out-of-bounds placement still rejected
  - [ ] Bounds checking happens before road checking
  - [ ] Order: bounds → house → existing structures → road path

- [ ] **EC4:** All 20 maps enforce road protection
  - [ ] Spot-check maps: 1, 5, 10, 15, 20
  - [ ] Each map's unique path geometry is correctly protected

### Code Quality Requirements

- [ ] **CQ1:** Console logging consistency
  - [ ] Use existing print patterns: "❌" for failures, "✅" for success
  - [ ] Match verbosity of existing placement logs

- [ ] **CQ2:** No breaking changes to existing systems
  - [ ] Bug movement logic (Bug.swift:254-316) unchanged
  - [ ] Tower attack behavior unaffected
  - [ ] Map path definitions remain identical

- [ ] **CQ3:** Remove dead code
  - [ ] If `isRoadPathBlocked()` becomes unused, mark as deprecated or remove
  - [ ] Clean up any orphaned A* path assignment logic

---

## 5. ⚙️ Implementation Guidance

### Execution Strategy

**Layer 0 (Foundation) - Must Complete First:**
1. Modify `canPlaceStructure()` to check road path
   - Add road path check after existing validation
   - Use pattern: `MapManager.shared.getCurrentRoadPath().contains(position)`
   - Return false if position is on road

**Layer 1 (Core Changes) - Can Run in Parallel:**
2. Simplify `spawnBug()` path assignment
   - Remove `isRoadPathBlocked()` conditional
   - Always assign `roadPath` to bugs
   - Test with ground bugs (ants, beetles) and flying bugs (mosquito, wasp)

3. Simplify `recalculateBugPaths()`
   - Remove road blocking check
   - Always use `roadPath` for recalculation

**Layer 2 (Cleanup) - After Core Works:**
4. Code cleanup
   - Mark `isRoadPathBlocked()` as unused or remove
   - Verify `findFlyingPath()` in PathfindingGrid remains unused
   - Update any misleading comments about A* fallback

**Layer 3 (Validation):**
5. Test across map types
   - Start wave on Map 1, verify bugs follow path
   - Place towers adjacent to road (should work) and on road (should fail)
   - Progress to wave 10+ to trigger map change, verify new road is protected

### Expected Artifacts

**Code Changes:**
- `Sources/BugDefense/GameScene.swift` (primary file)
  - `canPlaceStructure()` - add road check
  - `spawnBug()` - remove A* fallback
  - `recalculateBugPaths()` - remove road blocking check
  - Optional: remove or deprecate `isRoadPathBlocked()`

**No Changes Needed:**
- `Bug.swift` - movement logic stays identical
- `MapConfiguration.swift` - all 20 map paths stay identical
- `PathfindingGrid.swift` - A* remains available for potential future use
- `Tower.swift`, `DefenseStructure.swift` - no changes

**Testing Approach:**
- Manual testing in-game (no unit tests exist in this project)
- Test with build command: `swift build`
- Run game and verify:
  1. Cannot place towers on road (red preview)
  2. Bugs follow road path visually
  3. Works across multiple maps

### Constraints

**What NOT to Do:**
- ❌ Do NOT modify the 20 map path definitions in MapConfiguration.swift
- ❌ Do NOT change bug movement smoothness (keep waypoint-to-waypoint animation)
- ❌ Do NOT add new UI elements or visual path indicators (out of scope)
- ❌ Do NOT allow flying bugs to ignore roads (user wants them on roads too)
- ❌ Do NOT keep A* fallback behavior (user explicitly wants road-only movement)

**Performance Requirements:**
- `contains()` check on road path array is O(n), acceptable for ~10-50 waypoints
- No need to optimize with Set conversion unless profiling shows issue

**Backward Compatibility:**
- No save game format changes
- Existing towers placed on roads before this change remain (will be cleared on tier transition anyway)

---

## 5.1 Testing Guidance (Minimal & Relevant)

**Philosophy:** This is a gameplay behavior change affecting placement validation and path assignment. Focus on testing the modified logic paths.

**Testing Approach:**
- **Manual Testing Required:** Run the game and validate behavior changes
- **No Unit Tests:** This project uses manual testing (no test framework detected)

**Test Scenarios to Validate:**

1. **Happy Path:**
   - Place tower off-road → success (existing behavior preserved)
   - Bug spawns → follows road path → reaches house (core behavior preserved)

2. **Core Change:**
   - Attempt tower placement on road tile → rejected with red preview and console message
   - Bug spawns when road is clear → uses predefined path (not A*)

3. **Edge Cases:**
   - Map changes at wave 10 → new road is protected
   - Flying bug (mosquito/wasp) spawns → follows road path, not direct line
   - Tower placement on house position → still rejected (existing check preserved)

**Build & Run:**
```bash
swift build
open BugDefense.app  # Or run from Xcode
```

**Coverage Target:**
- 100% of changed lines validated through manual gameplay testing
- Spot-check 5 maps (1, 5, 10, 15, 20) for different path geometries

---

## 6. 🔍 Verification and Traceability

### Requirement Traceability Matrix

| User Request Element | Implementation Location | Verification Method |
|---------------------|------------------------|---------------------|
| "keep bugs on map path" | `spawnBug()` always uses roadPath | Observe bugs following road |
| "for each map type" | Uses `MapManager.shared.getCurrentRoadPath()` | Test multiple maps |
| Road-only movement | Remove A* fallback in `spawnBug()` | Check code: no `isRoadPathBlocked()` call |
| Flying bugs on roads | No special flying path logic | Spawn mosquito/wasp, verify road-following |
| Prevent road placement | `canPlaceStructure()` road check | Try placing tower on road → fail |

### Self-Verification Checklist

**Before marking task complete, verify:**
- [ ] All acceptance criteria (AC1-AC5) are met
- [ ] All edge cases (EC1-EC4) are handled
- [ ] Console logs match existing patterns
- [ ] No hardcoded map-specific logic (solution works for all 20 maps)
- [ ] Game builds without errors: `swift build`
- [ ] Manual test: Place tower on road → rejected
- [ ] Manual test: Bug spawns → follows road → reaches house
- [ ] Manual test: Map changes at wave 10 → new road protected
- [ ] Code is cleaner (removed dead A* fallback code)

---

## 7. 🧠 Reasoning Boundaries

### Development Philosophy
- **Simplicity over complexity:** Remove A* fallback entirely rather than adding conditions
- **Follow existing patterns:** Use `MapManager.shared.getCurrentRoadPath()` like existing code does
- **Preserve what works:** Keep smooth bug movement, axis-locking, waypoint navigation
- **Grid-based design:** All placement decisions are grid-aligned, no pixel-perfect math needed

### When to Preserve, When to Change

**Preserve:**
- Bug movement animation logic (Bug.swift:254-316) - it's working correctly
- Map path definitions (MapConfiguration.swift) - these are game design, not code changes
- Tower attack and damage systems - unrelated to path enforcement
- Camera, HUD, and UI systems - out of scope

**Change:**
- `canPlaceStructure()` validation - add road check (core requirement)
- `spawnBug()` path assignment - remove A* conditional (core requirement)
- `recalculateBugPaths()` - simplify to always use road (consistency)

**Remove/Deprecate:**
- `isRoadPathBlocked()` - no longer needed if towers can't block roads

### Decision-Making Guidelines
- If uncertain about a map's path geometry: reference MapConfiguration.swift definitions
- If uncertain about placement logic: follow same pattern as house position check
- If uncertain about movement: **don't change it** - user confirmed current movement is fine
- If A* pathfinding code is complex to remove: comment it out clearly with `// No longer used: roads cannot be blocked`

### Code Style to Match
```swift
// Existing pattern for invalid placement
print("❌ Cannot place on house: \(position)")
// Your pattern for road placement
print("❌ Cannot place on road: \(position)")

// Existing pattern for success
print("✅ Can place at: \(position)")
```

---

## 8. 📋 Summary: What Changed and Why

**User Request:** "Can we find a way to keep the bugs on the map path for each map type?"

**User's Clarifications (from CLARIFICATION_ANSWERS.json):**
1. ❓ **Problem observed:** [Empty answer - no specific problem described]
2. ✅ **Road blocking behavior:** Option B - "Prevent tower placement on roads"
3. ✅ **Path adherence:** Option A - "Current behavior is fine" (keep smooth movement)
4. ✅ **Flying bugs:** Option A - "Flying bugs follow roads" (same as ground bugs)

**Solution Summary:**
- Modify placement validation to reject towers on road tiles
- Remove A* pathfinding fallback (no longer needed if roads can't be blocked)
- Keep all bug movement behavior exactly as-is (smooth waypoint-following)
- Ensure flying bugs use road paths (confirm existing behavior, don't add special logic)

**Impact Analysis:**
- **Player Experience:** More predictable bug paths, clearer strategic choices
- **Difficulty:** Slightly easier (can't accidentally block paths), but maintains intended map design
- **Code Complexity:** **Reduced** (removes conditional A* logic)
- **Performance:** **Improved** (no A* pathfinding overhead during gameplay)

---

## 9. 🎓 Context for the Downstream Agent

You are receiving this task after the user has provided clarifications. This is a **simplification task** - you are removing complexity (A* fallback) and adding a simple validation rule (road blocking).

**What the user really wants:**
- Predictable gameplay where bugs always follow the designed map paths
- No surprises where towers accidentally block routes and bugs path around them
- Enforcement of the "tower defense" strategic layer: place towers *near* paths, not *on* them

**Key insight from clarifications:**
- User confirmed current bug movement is fine (smooth, axis-locked waypoint navigation)
- User chose "prevent tower placement" over other approaches like "bugs fail to spawn" or "keep A* fallback"
- Flying bugs should NOT have special behavior - they follow roads like ground bugs

**This is NOT about:**
- Fixing bugs leaving the path visually (current movement already has axis-locking)
- Adding path visualization (out of scope)
- Making paths adjustable or dynamic (paths are static map design)

**Red flags to watch for:**
- Don't overcomplicate: this is a ~10 line change to GameScene.swift
- Don't modify Bug.swift movement logic (confirmed working correctly)
- Don't add new systems or managers (use existing MapManager.shared)
- Don't make map-specific changes (solution must work for all 20 maps generically)

**You should feel confident this is a straightforward task:** Add one validation check, remove one fallback branch, done. The user has explicitly confirmed they want the simple approach.
