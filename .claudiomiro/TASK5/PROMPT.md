## PROMPT
Design Map 25 with diagonal cross (X-pattern) emphasizing diagonal movement paths.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**Read:** `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md`

## TASK-SPECIFIC CONTEXT
**Files:** MapConfiguration.swift (add map25)
**Pattern:** Diagonal X or slash - tests vector movement on diagonals
**Difficulty:** Easy (25-40 waypoints)

Example diagonal pattern:
```
Corner → ╲
          ╲ diagonal
           ╲ → House
```

## LAYER
1

## PARALLELIZATION
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK6, TASK7, TASK8, TASK9, TASK10]

## CONSTRAINTS
- No commit/push
- Strong diagonal segments
- Tests smooth diagonal movement

## SUCCESS CRITERIA
- ✅ Compiles
- ✅ Clear diagonal pattern
- ✅ Smooth bug movement (no stair-stepping)
