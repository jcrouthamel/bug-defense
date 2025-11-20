@dependencies [TASK0]
# Task: Design and Implement Map 27 (Figure-8 Pattern)

## Summary
Create a map with a figure-8 or infinity symbol pattern where bugs cross through the center point twice.

## Context Reference
**For complete environment context, see:** `../AI_PROMPT.md`

**Task-Specific Context:**
Map 27 - figure-8 pattern for visual interest and center-crossing gameplay.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`: Add `.map27 = "Figure Eight"`, `map27Path`, switch case

### Design Constraints
- Safe zone: x:1-18, y:1-13
- Two loops intersecting at/near center
- Path length: 45-60 waypoints
- End: GridPosition(x: 10, y: 7)

## Complexity
Medium

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK8, TASK9, TASK10]

## Detailed Steps
1. Design figure-8 with two loops
2. Ensure path crosses through center area
3. Implement smooth loop transitions

## Acceptance Criteria
- [ ] Clear figure-8 or infinity pattern
- [ ] Path crosses through center
- [ ] Two distinct loop segments
- [ ] Compiles and tests successfully

## Code Review Checklist
- [ ] Loops are balanced (similar size)
- [ ] Center crossing is clear

## Reasoning Trace
Figure-8 creates visually interesting crossing point, challenges tower placement strategy around dual loops.
