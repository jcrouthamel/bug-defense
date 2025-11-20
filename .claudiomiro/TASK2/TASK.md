@dependencies [TASK0]
# Task: Design and Implement Map 22 (Cloverleaf Pattern)

## Summary
Design and implement a new map with a cloverleaf/four-petal pattern where the path loops around the house in four distinct arcs, creating a decorative and challenging layout with multiple opportunities for tower placement in the center and corners.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack, architecture, coding conventions, and related code patterns

**Task-Specific Context:**
Creating one new map (Map 22) with a cloverleaf pattern to add visual variety and moderate-high difficulty.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`:
  - Add `.map22` enum case (around line 5)
  - Implement `map22Path` method (after existing map paths)
  - Add case to `roadPath` switch statement (around line 43)

### Patterns to Follow
- Follow enum naming: `.map22 = "Cloverleaf Loop"`
- Follow method pattern: `private var map22Path: [GridPosition]`
- Path structure: Start at grid edge, loop around house, end at GridPosition(x: 10, y: 7)
- Reference Map 11 (Box Spiral) for complex looping patterns (MapConfiguration.swift:350-412)

### Design Constraints
- Stay within safe zone: x:1-18, y:1-13
- Start at edge position (x=1, x=18, y=1, or y=13)
- End at house: GridPosition(x: 10, y: 7)
- Create 4 arc segments forming cloverleaf around center
- Path length: 50-70 waypoints (moderate-high difficulty)

## Complexity
Medium

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]

## Detailed Steps
1. **Design the path pattern**
   - Sketch cloverleaf pattern on 20x15 grid with house at center
   - Plan four arc/loop segments extending from center area
   - Each petal should reach toward a corner or edge
   - Path should circulate around house before final approach

2. **Define waypoint corners**
   - Create arcs using multiple waypoints per petal
   - Example pattern concept:
     ```
     Start edge → arc to top-left → arc to top-right →
     arc to bottom-right → arc to bottom-left → spiral in to house
     ```

3. **Implement in MapConfiguration.swift**
   - Add enum case: `case map22 = "Cloverleaf Loop"`
   - Create path method with ~15-20 key waypoints
   - Ensure smooth arcs (use multiple intermediate points for curves)

4. **Verify path validity**
   - All coordinates within bounds
   - No overlap with house position until final waypoint
   - Visually forms cloverleaf pattern

5. **Test in-game**
   - Manually select map22 in MapManager
   - Verify bugs follow smooth arcing path
   - Check road tiles form continuous cloverleaf
   - Test tower placement in center and corners

## Acceptance Criteria
- [ ] Map 22 enum case added to MapType
- [ ] map22Path method implemented with cloverleaf pattern
- [ ] Path added to roadPath switch statement
- [ ] All waypoints within safe zone (x:1-18, y:1-13)
- [ ] Path starts at edge and ends at GridPosition(x: 10, y: 7)
- [ ] Pattern creates 4 distinct arc segments (cloverleaf petals)
- [ ] Code compiles without errors
- [ ] Bugs navigate path correctly (manual test)
- [ ] Road tiles render forming cloverleaf shape
- [ ] Towers can be placed in strategic positions around loops

## Code Review Checklist
- [ ] Enum case follows naming convention
- [ ] Path method is private and follows pattern
- [ ] GridPosition coordinates are valid integers
- [ ] Switch statement updated correctly
- [ ] Waypoints create smooth arcs (not jagged)
- [ ] Path is continuous and reaches house
- [ ] Comments explain cloverleaf structure if helpful

## Reasoning Trace
**Design Philosophy:**
- Cloverleaf pattern provides high visual interest
- Looping design creates natural tower placement zones
- Moderate-high difficulty due to longer path length
- Distinct from linear patterns (zigzag, straight) and simple spirals

**Pattern Choice:**
- Four petals utilize full grid space efficiently
- Arcs around center create strategic depth
- Players must defend multiple approach vectors
- Visually appealing and memorable

**Complexity Justification:**
- More waypoints needed than zigzag to create smooth arcs
- Path planning requires spatial reasoning
- Worth the effort for unique visual and gameplay experience
