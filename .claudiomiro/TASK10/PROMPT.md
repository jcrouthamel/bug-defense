## PROMPT
Design Map 30 as a complex labyrinth maze with maximum difficulty and path length.

## COMPLEXITY
Medium

## CONTEXT REFERENCE
**Read:** `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md`

## TASK-SPECIFIC CONTEXT
**Pattern:** Labyrinth Maze (Complex)
**Difficulty:** Hard (70-100 waypoints - longest map)
**Reference:** Map 5 (Maze Runner) at MapConfiguration.swift:205-239

Example maze complexity:
```
├─┬─┐
│ │ └─┐
└─┼───┤
  └───┘ (many twists and turns)
```

## LAYER
1

## PARALLELIZATION
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9]

## CONSTRAINTS
- Maximum complexity within safe zone
- 70-100 waypoints
- No actual dead ends (continuous path)
- No commit/push

## SUCCESS CRITERIA
- ✅ Intricate maze pattern
- ✅ Longest path (70-100 waypoints)
- ✅ Visually complex
- ✅ Compiles and path valid
