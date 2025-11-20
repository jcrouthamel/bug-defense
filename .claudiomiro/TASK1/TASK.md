@dependencies [TASK0]
# Task: Design and Implement Map 21 (Zigzag Pattern)

## Summary
Design and implement a new map with a distinctive zigzag/lightning-bolt pattern. This map should feature sharp horizontal direction changes creating a visually striking serpentine path across the grid, providing moderate difficulty with multiple tower placement opportunities between path segments.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack, architecture, coding conventions, and related code patterns

**Task-Specific Context:**
Creating one new map (Map 21) with a zigzag pattern to add visual variety to the map pool.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`:
  - Add `.map21` enum case (around line 5)
  - Implement `map21Path` method (after existing map paths)
  - Add case to `roadPath` switch statement (around line 43)

### Patterns to Follow
- Follow enum naming: `.map21 = "Zigzag Lightning"`
- Follow method pattern: `private var map21Path: [GridPosition]`
- Path structure: Start at grid edge, end at GridPosition(x: 10, y: 7)
- Reference existing zigzag patterns if any exist in maps 1-20

### Design Constraints
- Stay within safe zone: x:1-18, y:1-13
- Start at edge position (x=1, x=18, y=1, or y=13)
- End at house: GridPosition(x: 10, y: 7)
- Create 3-5 sharp horizontal zigzags
- Path length: 30-45 waypoints (moderate difficulty)

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]

## Detailed Steps
1. **Design the path pattern**
   - Sketch zigzag pattern on 20x15 grid
   - Plan spawn point at left or right edge
   - Create alternating horizontal segments with sharp vertical connections
   - Ensure final segment reaches house at center

2. **Define waypoint corners**
   - Identify key turning points
   - Example pattern:
     ```
     Start (1, 3) → (15, 3) → (15, 5) → (5, 5) → (5, 7) → (10, 7) [house]
     ```
   - Adjust for visual balance and spacing

3. **Implement in MapConfiguration.swift**
   - Add enum case: `case map21 = "Zigzag Lightning"`
   - Create path method:
     ```swift
     private var map21Path: [GridPosition] {
         return [
             GridPosition(x: 1, y: 3),
             GridPosition(x: 15, y: 3),
             // ... additional waypoints ...
             GridPosition(x: 10, y: 7)
         ]
     }
     ```
   - Add to roadPath switch: `case .map21: return expandPath(map21Path)`

4. **Verify path validity**
   - All coordinates within bounds
   - No overlap with house position (except final waypoint)
   - Visually distinct from existing maps

5. **Test in-game**
   - Manually select map21 in MapManager
   - Verify bugs spawn at first waypoint
   - Confirm bugs follow zigzag path to house
   - Check road tiles render correctly
   - Test tower placement between path segments

## Acceptance Criteria
- [ ] Map 21 enum case added to MapType
- [ ] map21Path method implemented with zigzag pattern
- [ ] Path added to roadPath switch statement
- [ ] All waypoints within safe zone (x:1-18, y:1-13)
- [ ] Path starts at edge and ends at GridPosition(x: 10, y: 7)
- [ ] Zigzag pattern creates 3-5 distinct horizontal segments
- [ ] Code compiles without errors
- [ ] Bugs navigate path correctly (manual test)
- [ ] Road tiles render along entire path (visual verification)
- [ ] Towers cannot be placed on path tiles

## Code Review Checklist
- [ ] Enum case follows naming convention
- [ ] Path method is private and follows pattern
- [ ] GridPosition coordinates are valid integers
- [ ] Switch statement updated correctly
- [ ] No duplicate waypoints
- [ ] Path is continuous (expandPath will handle interpolation)
- [ ] Comments added if pattern is complex

## Reasoning Trace
**Design Philosophy:**
- Zigzag pattern provides visual variety distinct from winding/spiral/straight patterns
- Sharp horizontal segments create clear tower placement zones
- Moderate difficulty: longer path gives players time to build defenses

**Pattern Choice:**
- Horizontal zigzags (rather than vertical) utilize full grid width
- Alternating direction creates visual rhythm
- Multiple segments increase strategic tower placement options

**Why this specific pattern:**
- Complements existing map variety
- Easy for players to understand visually
- Balanced difficulty (not too easy, not too hard)
- Works well with the grid-based rendering system
