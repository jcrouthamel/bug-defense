# Research for TASK0

## Context Reference
**For tech stack and conventions, see:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (Swift 5.x, SpriteKit, MapManager singleton, 20 map types)
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/TASK.md` - Task-level context (road path validation modification)
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**This file contains ONLY new information discovered during research.**

---

## Task Understanding Summary
Prevent tower placement on predefined road paths and remove A* pathfinding fallback for bugs. Item 1 (road validation) is already complete. Remaining: simplify bug spawning (Item 2), path recalculation (Item 3), and cleanup (Item 4).

---

## Files Discovered to Read/Modify

### Already Modified (Item 1 - COMPLETE ✅)
- `Sources/BugDefense/GameScene.swift:880-884` - Road path validation check **already implemented**
  - Uses `MapManager.shared.getCurrentRoadPath().contains(position)` pattern
  - Logs "❌ Cannot place on road: \(position)"
  - Follows existing house position check pattern at lines 875-878

### To Modify (Items 2-4 - TODO)
- `Sources/BugDefense/GameScene.swift:510-544` - **Item 2:** `spawnBug()` function
  - Lines 522-534: Contains A* fallback logic to remove
  - Currently checks `isRoadPathBlocked()` and switches to A* if blocked
  - Target: Always use `roadPath` directly (remove conditional)

- `Sources/BugDefense/GameScene.swift:1062-1087` - **Item 3:** `recalculateBugPaths()` function
  - Lines 1070-1081: Contains same A* fallback pattern as `spawnBug()`
  - Target: Simplify to always use `roadPath` (match Item 2 pattern)

- `Sources/BugDefense/GameScene.swift:1049-1060` - **Item 4:** `isRoadPathBlocked()` function
  - Will become unused after Items 2-3 complete
  - Only 2 call sites: lines 522 and 1070 (both will be removed)
  - Decision: Deprecate with comment or remove entirely

### Read-Only (DO NOT MODIFY)
- `Sources/BugDefense/Bug.swift:254-316` - Bug movement logic (confirmed working correctly)
  - Lines 286-288: Comment explicitly states ground bugs follow predefined road
  - Smooth waypoint-to-waypoint movement with axis locking
- `Sources/BugDefense/MapConfiguration.swift:40-67` - Road path definitions (static game design)
- `Sources/BugDefense/PathfindingGrid.swift:85-122` - `findFlyingPath()` (currently unused, verify stays unused)

---

## Code Patterns Found

### Validation Pattern (Already Applied in Item 1)
From `Sources/BugDefense/GameScene.swift:875-878` - House position validation:
```swift
if position == MapManager.shared.getCurrentHousePosition() {
    print("❌ Cannot place on house: \(position)")
    return false
}
```
**Applied at lines 880-884 for road path:**
```swift
if MapManager.shared.getCurrentRoadPath().contains(position) {
    print("❌ Cannot place on road: \(position)")
    return false
}
```

### Logging Pattern (Consistent Throughout GameScene.swift)
- Success: `print("✅ [description]")`
- Failure: `print("❌ [description]")`
- Road-specific: `print("🛣️ [description]")`
- Blocked road (to remove): `print("🚧 [description]")`

### Path Assignment Pattern (Current Implementation)
From `Sources/BugDefense/GameScene.swift:516-534`:
```swift
let roadPath = MapManager.shared.getCurrentRoadPath()
if isRoadPathBlocked(roadPath) {
    // A* fallback (REMOVE THIS)
    path = pathfindingGrid.findPath(from:to:)
} else {
    // Predefined path (KEEP THIS as only behavior)
    path = roadPath
}
```
**Target simplified pattern:**
```swift
let roadPath = MapManager.shared.getCurrentRoadPath()
// All bugs follow the road path (towers cannot block roads)
bug.setPath(roadPath)
```

---

## Integration & Impact Analysis

### Functions/Classes/Components Being Modified:

#### 1. `spawnBug(_ bug: Bug)` in `Sources/BugDefense/GameScene.swift:510-544`
**Called by:**
- `Sources/BugDefense/GameScene.swift:210` - WaveManager callback for regular spawning
- `Sources/BugDefense/GameScene.swift:565` - Split bug spawning (breeders)
- `Sources/BugDefense/GameScene.swift:1615` - Manual spawn (dev/debug)
- `Sources/BugDefense/WaveManager.swift:36` - Wave spawn timer callback
- `Sources/BugDefense/WaveManager.swift:45` - WaveManager's own spawnBug (different signature)

**Parameter contract:** `private func spawnBug(_ bug: Bug)`
- Input: `Bug` instance (already initialized with position, type, stats)
- Output: void (adds bug to scene and `bugs` array)
- Side effect: Bug receives path via `bug.setPath(path)`

**Impact:** NO BREAKING CHANGES
- Function signature remains unchanged
- All callers continue to work identically
- Behavior change: Bugs now always receive `roadPath` (no A* fallback)
- Callers don't need modification - they just pass a `Bug` instance

**Breaking changes:** NO - Internal implementation change only

---

#### 2. `recalculateBugPaths()` in `Sources/BugDefense/GameScene.swift:1062-1087`
**Called by:**
- `Sources/BugDefense/GameScene.swift:472` - Map transition (every 10 waves)
- `Sources/BugDefense/GameScene.swift:1005` - After structure placement (line within `placeStructure()`)

**Parameter contract:** `private func recalculateBugPaths()`
- Input: void (operates on instance `bugs` array)
- Output: void (updates paths for all living bugs)
- Side effect: All bugs receive new path via `bug.setPath(path)`

**Impact:** NO BREAKING CHANGES
- Function signature unchanged
- Call sites at lines 472 and 1005 continue to work
- Behavior change: Bugs now always receive `roadPath` (no A* fallback)
- **Critical for map transitions:** When map changes every 10 waves, bugs must adapt to new road path

**Breaking changes:** NO - Internal implementation change only

**Integration note:** Line 1005 call happens after tower placement. With Item 1 complete, towers can't be placed on roads, so `recalculateBugPaths()` will never need to handle blocked roads. This call becomes a no-op unless bugs are mid-transit or map has changed.

---

#### 3. `isRoadPathBlocked(_ roadPath: [GridPosition])` in `Sources/BugDefense/GameScene.swift:1049-1060`
**Called by:**
- `Sources/BugDefense/GameScene.swift:522` - Within `spawnBug()` (Item 2 will remove)
- `Sources/BugDefense/GameScene.swift:1070` - Within `recalculateBugPaths()` (Item 3 will remove)

**Parameter contract:** `private func isRoadPathBlocked(_ roadPath: [GridPosition]) -> Bool`
- Input: Array of grid positions representing road path
- Output: `Bool` (true if any road tile is blocked)
- Logic: Iterates road path, checks `pathfindingGrid.isBlocked(at:)` for each position

**Impact:** FUNCTION BECOMES UNUSED
- After Items 2-3, zero call sites remain
- Function can be deprecated or removed entirely
- No external consumers (function is `private`)

**Breaking changes:** NO - Private function, no external dependencies

**Recommendation:** Add deprecation comment in Item 4:
```swift
// DEPRECATED: No longer used - towers cannot be placed on roads (as of Item 1)
private func isRoadPathBlocked(_ roadPath: [GridPosition]) -> Bool {
    // ... existing implementation ...
}
```
Or remove entirely if confident no other code references it (grep verification confirms clean removal).

---

### API/Database/External Integration:
**N/A** - This is a single-player game with no API or database dependencies.
- All changes are internal to `GameScene.swift`
- No save game format changes
- No network communication
- No external services

---

## Test Strategy Discovered

### Testing Framework
**Framework:** None detected (manual testing only)
**Test command:** `swift build` for compilation, then manual gameplay testing
**Test location:** No `Tests/` directory or `.test.swift` files found

### Manual Testing Approach
**From TODO.md verification section (lines 369-393):**

#### Build Verification
```bash
swift build  # Must succeed with no errors
swift test   # Run existing test suite (if any)
```

#### Manual Testing Checklist
```bash
swift run BugDefenseApp
# Then perform these checks:
# 1. Start Wave 1 on Map 1 (Winding Road)
# 2. Attempt to place tower on road tile → should fail with red preview
# 3. Place tower adjacent to road → should succeed
# 4. Start wave → observe bugs following road path smoothly
# 5. Check console logs:
#    - "❌ Cannot place on road: [pos]" when attempting road placement (Item 1)
#    - "🛣️ Using predefined road path" when bugs spawn (Item 2)
#    - NO "🚧 Road is blocked!" messages (removed in Items 2-3)
# 6. Progress to Wave 10 → map changes → bugs adapt to new road
# 7. Spawn flying bug (mosquito/wasp) → follows road path (not direct line)
# 8. Test multiple maps: 1, 5, 10, 15, 20 (different path geometries)
```

### Console Logging Pattern
**Success indicators:**
- ✅ "✅ Bug spawned: [bugType] at position [pos]"
- ✅ "🛣️ Using predefined road path for [bugType]"
- ✅ "🛣️ [Recalc] Using predefined road path for [bugType]"
- ✅ "❌ Cannot place on road: [pos]" (placement blocked)

**Failure indicators (should NOT appear after implementation):**
- ❌ "🚧 Road is blocked! Using A* pathfinding" (remove in Item 2)
- ❌ "🚧 [Recalc] Road is blocked!" (remove in Item 3)
- ❌ "❌ Failed to spawn bug: No path found" (should never happen with valid road paths)

---

## Risks & Challenges Identified

### Technical Risks

#### Risk 1: Bug Movement Glitches During Path Recalculation
- **Description:** When `recalculateBugPaths()` is called (map transitions or structure placement), bugs mid-movement might experience visual glitches if path changes abruptly
- **Likelihood:** Low
- **Impact:** Medium (visual/UX issue, not game-breaking)
- **Evidence:** Function is called at GameScene.swift:472 (map change) and :1005 (structure placement)
- **Mitigation:** Existing bug movement logic (Bug.swift:254-316) handles path updates via `pathIndex` - bugs continue from current waypoint. This already works in current implementation.
- **Fallback:** Acceptable risk - current implementation already handles this, no reason to expect new issues

#### Risk 2: Empty Road Path Edge Case
- **Description:** If `MapManager.shared.getCurrentRoadPath()` returns empty array, bugs would have no path and fail to spawn
- **Likelihood:** Very Low (maps are static, all 20 defined in MapConfiguration.swift)
- **Impact:** High (bugs fail to spawn, game unplayable)
- **Evidence:** Road paths are computed properties in MapType enum (MapConfiguration.swift:40-67), guaranteed to return non-empty arrays for all 20 maps
- **Mitigation:** No code changes needed - this is validated by game design
- **Fallback:** If concern remains, could add assertion: `assert(!roadPath.isEmpty, "Road path cannot be empty")`

#### Risk 3: Performance Regression from Frequent `getCurrentRoadPath()` Calls
- **Description:** Items 2-3 will call `MapManager.shared.getCurrentRoadPath()` every time a bug spawns or paths recalculate
- **Likelihood:** Low
- **Impact:** Low (minor performance concern)
- **Evidence:** Current code already calls this in `spawnBug()` (line 518). Function returns computed property (MapConfiguration.swift:40), which expands base path to full tile array.
- **Mitigation:** Existing implementation hasn't shown performance issues. Road paths are ~10-50 waypoints, expansion is O(n).
- **Fallback:** If profiling shows issues, could cache expanded path in MapManager (out of scope for this task)

#### Risk 4: Flying Bugs Might Need Special Behavior
- **Description:** User confirmed flying bugs should follow roads, but they have `canFly` property (Bug.swift:106-113) and `findFlyingPath()` exists in PathfindingGrid (line 85)
- **Likelihood:** Very Low (clarified by user)
- **Impact:** Low (design decision, not technical issue)
- **Evidence:** User's CLARIFICATION_ANSWERS.json states "Flying bugs follow roads" (Option A). Bug.swift:286-288 comment confirms ground bugs follow predefined road.
- **Mitigation:** Keep `findFlyingPath()` unused (verify in Item 4). No special logic for flying bugs.
- **Fallback:** If future requirement changes, `findFlyingPath()` is available in PathfindingGrid

### Complexity Assessment
- **Overall complexity:** Low
- **Reasoning:**
  - Item 1 already complete (road validation working)
  - Items 2-3 are simplifications (removing code, not adding)
  - Item 4 is cleanup (deprecation/removal of unused function)
  - No new systems, no new dependencies, no breaking changes
  - All changes confined to single file (GameScene.swift)
- **Complex areas:**
  - None - straightforward code removal and simplification

### Missing Information / Ambiguities
- [ ] **Item 4 decision: Deprecate or remove `isRoadPathBlocked()`?**
  - **Context:** Function will have zero callers after Items 2-3
  - **Impact:** Low - function is private, no external consumers
  - **Recommendation:** Start with deprecation comment. If grep confirms no other references, full removal is safe.

---

## Execution Strategy Recommendation

**Based on research findings, execute in this order:**

### Step 1: Item 2 - Simplify `spawnBug()` (CORE CHANGE)
- **Read:** `Sources/BugDefense/GameScene.swift:510-544` (current implementation)
- **Pattern to follow:** Remove conditional logic, always use `roadPath`
- **Modify:**
  - Remove lines 522-534 (entire `if isRoadPathBlocked(roadPath) { ... } else { ... }` block)
  - Replace with simple assignment: `bug.setPath(roadPath)`
  - Keep logging: "🛣️ Using predefined road path for \(bug.bugType)"
- **Expected result:**
  ```swift
  let roadPath = MapManager.shared.getCurrentRoadPath()
  print("📍 Road path has \(roadPath.count) waypoints...")
  print("🛣️ Using predefined road path for \(bug.bugType) with \(roadPath.count) waypoints")
  bug.setPath(roadPath)
  bugs.append(bug)
  addChild(bug)
  print("✅ Bug spawned: \(bug.bugType) at position \(bug.gridPosition)")
  ```
- **Test with:** `swift build` (must succeed), then manual gameplay testing

---

### Step 2: Item 3 - Simplify `recalculateBugPaths()` (CONSISTENCY)
- **Read:** `Sources/BugDefense/GameScene.swift:1062-1087` (current implementation)
- **Pattern to follow:** Match simplified pattern from Step 1 (Item 2)
- **Modify:**
  - Remove lines 1070-1081 (entire conditional block inside for loop)
  - Replace with simple assignment: `bug.setPath(roadPath)`
  - Keep outer `for bug in bugs` loop (still needed to update all bugs)
  - Keep logging: "🛣️ [Recalc] Using predefined road path for \(bug.bugType)"
- **Expected result:**
  ```swift
  private func recalculateBugPaths() {
      print("🔄 Recalculating bug paths for \(bugs.count) bugs")
      let roadPath = MapManager.shared.getCurrentRoadPath()

      for bug in bugs {
          print("🛣️ [Recalc] Using predefined road path for \(bug.bugType) at \(bug.gridPosition)")
          bug.setPath(roadPath)
      }
  }
  ```
- **Test with:** `swift build`, then test map transition at Wave 10

---

### Step 3: Item 4 - Clean Up Dead Code (HYGIENE)
- **Verify no other callers:**
  ```bash
  grep -n "isRoadPathBlocked" Sources/BugDefense/GameScene.swift
  # Should only show definition at line 1049, no call sites

  grep -rn "findFlyingPath" Sources/BugDefense/
  # Should only show definition in PathfindingGrid.swift:85, no calls
  ```
- **Decision path:**
  - If grep confirms clean: Remove `isRoadPathBlocked()` entirely (lines 1049-1060)
  - If uncertain: Add deprecation comment and keep function body
  ```swift
  // DEPRECATED: No longer used - towers cannot be placed on roads (Item 1 prevents blocking)
  // Kept for reference only. Remove in future cleanup.
  private func isRoadPathBlocked(_ roadPath: [GridPosition]) -> Bool {
      // ... existing implementation ...
  }
  ```
- **Update comments:**
  - Search for "A*", "pathfinding", "blocked road" in GameScene.swift
  - Update to reflect new behavior: "All bugs follow predefined road paths"
  - Bug.swift:286-288 comments are still valid (preserve them)
- **Verify `findFlyingPath()` unused:**
  - Confirm PathfindingGrid.swift:85-122 has no callers
  - Add/verify comment: `// Future use: Special flying paths (not currently used)`
- **Test with:** `swift build` (must succeed with no broken references)

---

### Step 4: Final Verification (ALL ITEMS)
- **Build:** `swift build` (must succeed)
- **Manual testing:** Follow checklist in "Test Strategy Discovered" section above
- **Acceptance criteria:** Verify all items in TODO.md:412-475 are checked off
- **Console log check:**
  - ✅ See "🛣️ Using predefined road path" messages
  - ✅ See "❌ Cannot place on road" when attempting road placement
  - ❌ Do NOT see "🚧 Road is blocked!" messages
- **Map testing:** Test maps 1, 5, 10, 15, 20 (different geometries)
- **Flying bug testing:** Spawn mosquito/wasp, verify they follow road path

---

**Research completed:** 2025-11-20
**Total similar components found:** 3 (house validation, existing logging patterns, path assignment)
**Total reusable components identified:** 2 (MapManager.shared pattern, console logging conventions)
**Estimated complexity:** Low (simplification task, mostly code removal)
**Primary discovery:** Item 1 is already complete, focus execution on Items 2-4
