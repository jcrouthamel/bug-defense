@dependencies [TASK0]
# Task: Design and Implement Map 29 (Starburst Pattern)

## Summary
Create a map with starburst/radial pattern where bugs approach house from multiple angles in a spoke-like pattern.

## Context Reference
**For complete environment context, see:** `../AI_PROMPT.md`

**Task-Specific Context:**
Map 29 - starburst/radial pattern for multi-directional approach challenge.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`: Add `.map29 = "Starburst"`, `map29Path`, switch case

### Design Constraints
- Safe zone: x:1-18, y:1-13
- Create 3-4 radial arms pointing toward center
- Path weaves through arms before reaching house
- Path length: 45-60 waypoints
- End: GridPosition(x: 10, y: 7)

## Complexity
Medium

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK10]

## Detailed Steps
1. Design starburst with radial arms from center
2. Create path that visits multiple arms
3. Implement in MapConfiguration.swift

## Acceptance Criteria
- [ ] Clear radial/starburst visual pattern
- [ ] Path visits 3-4 different arms
- [ ] Approaches center from multiple angles
- [ ] Compiles and tests successfully

## Code Review Checklist
- [ ] Radial symmetry visible
- [ ] Path flows through different spokes

## Reasoning Trace
Starburst creates visual interest with radial symmetry, challenges players to defend multiple approach angles.
