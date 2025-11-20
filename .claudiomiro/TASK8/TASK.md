@dependencies [TASK0]
# Task: Design and Implement Map 28 (Wave Pattern)

## Summary
Create a map with horizontal wave pattern resembling sine/cosine waves across the grid.

## Context Reference
**For complete environment context, see:** `../AI_PROMPT.md`

**Task-Specific Context:**
Map 28 - wave pattern for smooth, rhythmic visual flow.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`: Add `.map28 = "Wave Flow"`, `map28Path`, switch case

### Design Constraints
- Safe zone: x:1-18, y:1-13
- Create 2-3 wave cycles (peaks and troughs)
- Horizontal wave flow
- Path length: 40-55 waypoints
- End: GridPosition(x: 10, y: 7)

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK9, TASK10]

## Detailed Steps
1. Design sine wave pattern horizontally across grid
2. Define waypoints for smooth wave curves
3. Implement in MapConfiguration.swift

## Acceptance Criteria
- [ ] Clear wave pattern with peaks and troughs
- [ ] 2-3 complete wave cycles
- [ ] Smooth curves (not angular)
- [ ] Compiles and tests successfully

## Code Review Checklist
- [ ] Wave amplitude stays within safe zone
- [ ] Smooth curves using multiple waypoints

## Reasoning Trace
Wave pattern provides natural, flowing visual. Different from S-curves (double helix) by maintaining consistent horizontal direction with vertical oscillation.
