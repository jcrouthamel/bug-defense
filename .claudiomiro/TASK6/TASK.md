@dependencies [TASK0]
# Task: Design and Implement Map 26 (Perimeter Loop)

## Summary
Create a map where bugs travel around the outer perimeter of the grid before spiraling into the house at center.

## Context Reference
**For complete environment context, see:** `../AI_PROMPT.md`

**Task-Specific Context:**
Map 26 - perimeter loop pattern for maximum path length and easy difficulty.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`: Add `.map26 = "Perimeter Loop"`, `map26Path`, switch case

### Design Constraints
- Safe zone: x:1-18, y:1-13
- Path follows grid edges (near safe zone boundary)
- Path length: 60-80 waypoints (long but easy)
- End: GridPosition(x: 10, y: 7)

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK7, TASK8, TASK9, TASK10]

## Detailed Steps
1. Design perimeter path (clockwise or counter-clockwise around edge)
2. Add spiral inward to center house
3. Implement in MapConfiguration.swift

## Acceptance Criteria
- [ ] Path follows perimeter of safe zone
- [ ] Long path (60-80 waypoints) but straightforward
- [ ] Spirals to center house
- [ ] Compiles and tests successfully

## Code Review Checklist
- [ ] Follows perimeter without going outside safe zone
- [ ] Clear spiral inward at end

## Reasoning Trace
Long path = easier (more time to build towers). Simple pattern but effective for beginner-friendly gameplay.
