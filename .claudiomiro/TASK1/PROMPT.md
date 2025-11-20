## PROMPT
Design and implement Map 21 with a distinctive zigzag/lightning-bolt pattern for the Bug Defense game.

**Your mission:** Create a visually striking map with sharp horizontal direction changes that provides moderate difficulty and clear tower placement zones.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack, architecture, project structure, coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
**Will modify:**
- `Sources/BugDefense/MapConfiguration.swift`
  - Add `.map21` case to MapType enum (around line 5)
  - Implement `map21Path` method (after existing maps, before line 631)
  - Add case to `roadPath` switch statement (around line 43)

### Patterns to Follow
**Enum case pattern (see MapConfiguration.swift:5-30):**
```swift
case map21 = "Zigzag Lightning"
```

**Path method pattern (see existing map methods):**
```swift
private var map21Path: [GridPosition] {
    return [
        GridPosition(x: start_x, y: start_y),  // Spawn point (edge)
        // ... zigzag waypoints ...
        GridPosition(x: 10, y: 7)              // House (required end)
    ]
}
```

**Switch update (see MapConfiguration.swift:43+):**
```swift
case .map21: return expandPath(map21Path)
```

### Integration Points
- MapType.allCases automatically includes new map (CaseIterable protocol)
- MapType.random() will select from expanded pool
- GameScene.spawnBug() will assign this path when map21 is active

## EXTRA DOCUMENTATION

### Design Requirements
**Pattern Type:** Zigzag (Lightning Bolt)

**Visual Characteristics:**
- 3-5 sharp horizontal segments
- Alternating left-right or right-left movement
- Clear angular turns (90-degree or sharper)
- Visually distinct from winding/spiral patterns

**Difficulty Target:** Moderate
- Path length: 30-45 waypoints after expansion
- Enough space between segments for tower clusters
- Not too easy (avoid short straight shot)
- Not too hard (avoid extreme maze complexity)

**Example Zigzag Pattern:**
```
Edge → ────────────────┐
                        │
          ┌─────────────┘
          │
          └─────────────┐
                        │
          ┌─────────────┘
          │
          └────→ House (center)
```

### Suggested Waypoint Corners
Starting from left edge (x=1):
1. `GridPosition(x: 1, y: 3)` - Spawn point
2. `GridPosition(x: 16, y: 3)` - Right extension
3. `GridPosition(x: 16, y: 5)` - Turn up
4. `GridPosition(x: 4, y: 5)` - Left extension
5. `GridPosition(x: 4, y: 7)` - Turn up to house level
6. `GridPosition(x: 10, y: 7)` - House (end)

**Note:** expandPath() will interpolate all intermediate positions automatically.

### Validation Checklist
Before submitting:
- [ ] All x coordinates between 1 and 18
- [ ] All y coordinates between 1 and 13
- [ ] First waypoint at grid edge (x=1, x=18, y=1, or y=13)
- [ ] Last waypoint is GridPosition(x: 10, y: 7)
- [ ] Path creates visible zigzag pattern
- [ ] No waypoints overlap house position (except final)

## LAYER
1 (Parallel map design layer)

## PARALLELIZATION
Parallel with: [TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]
Blocks: [TASK11, TASKΩ]

## CONSTRAINTS
- **IMPORTANT:** Do not perform any git commit or git push
- Follow existing MapConfiguration.swift code style exactly
- Use GridPosition struct (not raw CGPoint)
- Path must be continuous (expandPath handles interpolation)
- Test compilation after changes
- Manually verify path in-game if possible

## TESTING
After implementation:
1. **Compilation test:** `swift build`
2. **Manual test (if possible):**
   - Run game
   - Set MapManager to select map21
   - Spawn bugs and verify they follow zigzag path
   - Verify road tiles render correctly
   - Test tower placement blocking

## SUCCESS CRITERIA
Task is complete when:
- ✅ Code compiles without errors
- ✅ Map 21 appears in MapType enum
- ✅ Path method returns valid waypoint array
- ✅ Switch statement routes to map21Path
- ✅ Path creates distinctive zigzag visual pattern
- ✅ All coordinates within safe zone
- ✅ Path starts at edge and ends at house
