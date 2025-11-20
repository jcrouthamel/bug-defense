@dependencies [TASK0]
# Task: Design and Implement Map 23 (Double Helix Pattern)

## Summary
Design and implement a new map with a double helix/DNA strand pattern where the path creates two interweaving curves that wrap around each other, providing visual complexity and strategic tower placement challenges.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack, architecture, coding conventions, and related code patterns

**Task-Specific Context:**
Creating one new map (Map 23) with a double helix pattern for high visual appeal and moderate difficulty.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`:
  - Add `.map23` enum case (around line 5)
  - Implement `map23Path` method (after existing map paths)
  - Add case to `roadPath` switch statement (around line 43)

### Patterns to Follow
- Follow enum naming: `.map23 = "Double Helix"`
- Follow method pattern: `private var map23Path: [GridPosition]`
- Path structure: Start at edge, create S-curves weaving across grid, end at GridPosition(x: 10, y: 7)
- Reference Map 1 (Winding Road) for serpentine concepts (MapConfiguration.swift:118-137)

### Design Constraints
- Stay within safe zone: x:1-18, y:1-13
- Start at edge position
- End at house: GridPosition(x: 10, y: 7)
- Create 3-4 S-curve segments that appear to weave
- Path length: 40-55 waypoints (moderate difficulty)

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]

## Detailed Steps
1. **Design the path pattern**
   - Sketch double helix on 20x15 grid
   - Create alternating S-curves flowing vertically or horizontally
   - Curves should appear to cross over each other visually

2. **Define waypoint corners**
   - Example: Start bottom → curve right → curve left → curve right → center house
   - Use smooth gradual turns rather than sharp angles

3. **Implement in MapConfiguration.swift**
   - Add enum case: `case map23 = "Double Helix"`
   - Create path method with S-curve waypoints

4. **Verify path validity**
   - All coordinates within bounds
   - Path creates visual weaving effect
   - Smooth curves without sharp corners

5. **Test in-game**
   - Verify bugs follow S-curve pattern
   - Check visual appeal of road tiles
   - Test tower placement between curves

## Acceptance Criteria
- [ ] Map 23 enum case added to MapType
- [ ] map23Path method implemented with double helix pattern
- [ ] Path added to roadPath switch statement
- [ ] All waypoints within safe zone (x:1-18, y:1-13)
- [ ] Path starts at edge and ends at GridPosition(x: 10, y: 7)
- [ ] Pattern creates 3-4 visible S-curve segments
- [ ] Code compiles without errors
- [ ] Bugs navigate smoothly along curves
- [ ] Road tiles form continuous weaving pattern
- [ ] Visual effect resembles DNA helix or interweaving strands

## Code Review Checklist
- [ ] Enum case follows naming convention
- [ ] Path method is private and follows pattern
- [ ] GridPosition coordinates are valid
- [ ] Switch statement updated correctly
- [ ] Curves are smooth (adequate waypoints)
- [ ] Pattern is visually distinct from simple winding paths

## Reasoning Trace
**Design Philosophy:**
- Double helix provides organic, flowing visual pattern
- S-curves create natural defensive zones between segments
- Moderate difficulty with elegant appearance

**Pattern Choice:**
- Weaving effect adds visual sophistication
- Different from angular patterns (zigzag) and circular patterns (spiral)
- Natural path flow feels less artificial

**Visual Appeal:**
- Recognizable pattern (DNA helix reference)
- Smooth curves more visually pleasing than sharp turns
- Creates visual rhythm as bugs navigate
