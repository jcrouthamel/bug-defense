@dependencies [TASK0]
# Task: Design and Implement Map 25 (Diagonal Cross Pattern)

## Summary
Design and implement a map with an X-shaped diagonal cross pattern where bugs traverse from one corner, cross through the center, then angle toward the house.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack, architecture, coding conventions, and related code patterns

**Task-Specific Context:**
Creating Map 25 with diagonal cross (X) pattern for visual variety and diagonal path testing.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`: Add `.map25`, `map25Path`, switch case

### Patterns to Follow
- Enum: `.map25 = "Diagonal Cross"`
- Method: `private var map25Path: [GridPosition]`
- Emphasize diagonal movement (tests vector movement system)

### Design Constraints
- Safe zone: x:1-18, y:1-13
- Create X or diagonal slash pattern
- Path length: 25-40 waypoints (easier/shorter)
- End: GridPosition(x: 10, y: 7)

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK6, TASK7, TASK8, TASK9, TASK10]

## Detailed Steps
1. Design diagonal X or slash pattern
2. Define waypoints with strong diagonal segments
3. Implement in MapConfiguration.swift
4. Verify diagonal movement smoothness

## Acceptance Criteria
- [ ] Map 25 added with diagonal pattern
- [ ] Clear X-shape or diagonal slash visible
- [ ] Path within safe zone
- [ ] Code compiles
- [ ] Bugs navigate diagonals smoothly (tests vector movement)

## Code Review Checklist
- [ ] Diagonal segments use proper waypoints
- [ ] No stair-stepping (vector movement handles this)
- [ ] Pattern is visually distinct

## Reasoning Trace
**Pattern Choice:** Diagonal paths specifically test the normalized vector movement system. Provides visual contrast to horizontal/vertical-heavy patterns.
