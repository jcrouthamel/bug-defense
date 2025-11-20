@dependencies [TASK0]
# Task: Design and Implement Map 24 (U-Turn Switchback)

## Summary
Design and implement a new map with a switchback/hairpin turn pattern similar to a mountain road, featuring multiple sharp 180-degree turns that create a vertical ascent pattern.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack, architecture, coding conventions, and related code patterns

**Task-Specific Context:**
Creating Map 24 with switchback pattern - sharp U-turns stacked vertically for a distinctive mountain road aesthetic.

### Files This Task Will Modify
- `Sources/BugDefense/MapConfiguration.swift`:
  - Add `.map24` enum case
  - Implement `map24Path` method
  - Add case to `roadPath` switch statement

### Patterns to Follow
- Enum: `.map24 = "Mountain Switchback"`
- Method: `private var map24Path: [GridPosition]`
- End: GridPosition(x: 10, y: 7)

### Design Constraints
- Safe zone: x:1-18, y:1-13
- Create 4-6 sharp U-turn/hairpin segments
- Vertical progression (ascend or descend grid)
- Path length: 35-50 waypoints

## Complexity
Low

## Dependencies
Depends on: [TASK0]
Blocks: [TASK11, TASKΩ]
Parallel with: [TASK1, TASK2, TASK3, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]

## Detailed Steps
1. Design switchback pattern with U-turns
2. Define waypoints for hairpin segments
3. Implement in MapConfiguration.swift
4. Verify sharp turns are clear visually
5. Test bug navigation through tight turns

## Acceptance Criteria
- [ ] Map 24 added with switchback pattern
- [ ] 4-6 visible U-turn segments
- [ ] Path within safe zone
- [ ] Code compiles
- [ ] Bugs navigate hairpin turns correctly
- [ ] Distinct from zigzag pattern (sharper, more compact turns)

## Code Review Checklist
- [ ] Enum and method follow conventions
- [ ] Sharp 180-degree turns implemented
- [ ] Switch statement updated
- [ ] Visually distinct pattern

## Reasoning Trace
**Pattern Choice:** Switchbacks create tight, challenging layout distinct from broad zigzags or curves. Mimics mountain road aesthetic for thematic variety.
