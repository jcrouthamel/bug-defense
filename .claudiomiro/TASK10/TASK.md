@dependencies [TASK0]
# Task: Design and Implement Map 30 (Labyrinth Maze)

## Summary
Create a complex maze-like map with multiple twists and dead-end appearances, providing the highest difficulty path.

## Context Reference
**For complete environment context, see:** `../AI_PROMPT.md`

**Task-Specific Context:**
Map 30 - complex labyrinth pattern for maximum difficulty and path length.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`: Add `.map30 = "Labyrinth Maze"`, `map30Path`, switch case

### Design Constraints
- Safe zone: x:1-18, y:1-13
- Create intricate maze-like path with many turns
- Path length: 70-100 waypoints (hard difficulty)
- Reference Map 5 (Maze Runner) for inspiration (MapConfiguration.swift:205-239)
- End: GridPosition(x: 10, y: 7)

## Complexity
Medium

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9]

## Detailed Steps
1. Design complex maze path with many segments
2. Create feeling of dead-ends and backtracking (visual illusion)
3. Implement with numerous waypoint corners
4. Ensure path remains valid and reaches house

## Acceptance Criteria
- [ ] Complex maze-like pattern with many turns
- [ ] Path length 70-100 waypoints (longest map)
- [ ] Visually intricate and challenging
- [ ] All waypoints within safe zone
- [ ] Path reaches house correctly
- [ ] Compiles and tests successfully

## Code Review Checklist
- [ ] Path is continuous despite complexity
- [ ] No actual dead ends (visual illusion only)
- [ ] Pattern is distinct from other maze maps

## Reasoning Trace
Labyrinth provides hardest difficulty through sheer path length. Visual complexity creates engaging challenge. Balances easy maps (perimeter loop) for variety.
