## PROMPT
Modify the `canPlaceStructure()` function in GameScene.swift to prevent tower placement on road tiles by adding a validation check that rejects placements when the position is in the current map's road path array.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (20x15 grid system, MapManager singleton pattern, 20 map types), coding conventions (console logging patterns), and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
- `Sources/BugDefense/GameScene.swift` lines 866-896 - The `canPlaceStructure()` function

### Patterns to Follow
Follow the existing house position validation pattern (GameScene.swift:875-878):
```swift
if position == MapManager.shared.getCurrentHousePosition() {
    print("❌ Cannot place on house: \(position)")
    return false
}
```

Adapt this pattern for road path validation using:
- Road path access: `MapManager.shared.getCurrentRoadPath()` (returns `[GridPosition]`)
- Array contains check: `roadPath.contains(position)`
- Console logging: Use "❌ Cannot place on road: \(position)"

### Integration Points
- Integrates with existing validation chain in `canPlaceStructure()`: bounds → house → structures → road
- Uses MapManager.shared singleton (already instantiated)
- Road path check should be AFTER other checks (most expensive validation)
- Return false immediately when position is on road (early exit pattern)

### Validation Order Rationale
Place road check last because:
1. Bounds check: simple coordinate comparison (fastest)
2. House check: single point comparison (fast)
3. Structure check: small array iteration (medium)
4. Road check: ~10-50 waypoint array iteration (slowest)

## EXTRA DOCUMENTATION

### Current Implementation (GameScene.swift:866-896)
```swift
private func canPlaceStructure(at position: GridPosition) -> Bool {
    // Check bounds (lines 868-872)
    // Check house position (lines 875-878)
    // Check existing structures (lines 887-892)
    // ADD: Check if on road path HERE
    return true
}
```

### Expected Changes
Add after existing validation checks:
```swift
// Check if position is on road path
let roadPath = MapManager.shared.getCurrentRoadPath()
if roadPath.contains(position) {
    print("❌ Cannot place on road: \(position)")
    return false
}
```

### Verification Steps
1. Build project: `swift build` (must succeed)
2. Verify console logging matches existing patterns
3. Verify no changes to existing validation checks
4. Confirm logic works for all 20 map types (no hardcoded map logic)

## LAYER
0

## PARALLELIZATION
Parallel with: []

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push.
- Use existing MapManager.shared pattern (no new managers or systems)
- Match existing console log format ("❌" prefix for failures)
- Place validation check AFTER existing checks (bounds, house, structures)
- Must work generically for all 20 map types (no map-specific logic)
- Do NOT modify Bug.swift, MapConfiguration.swift, or path definitions
- Do NOT add UI elements or visual indicators (out of scope)
- Build must succeed after changes: `swift build`
- No unit tests needed (project uses manual testing only)
