## PROMPT
Design Map 26 with perimeter loop pattern - bugs travel around grid edges before spiraling to center.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**Read:** `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md`

## TASK-SPECIFIC CONTEXT
**Pattern:** Perimeter Loop → Spiral In
**Difficulty:** Easy (long path = more tower building time)
**Length:** 60-80 waypoints

## LAYER
1

## PARALLELIZATION
Parallel with: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK7, TASK8, TASK9, TASK10]

## CONSTRAINTS
- Follow safe zone perimeter (x:1-18, y:1-13)
- No commit/push

## SUCCESS CRITERIA
- ✅ Path follows perimeter
- ✅ Spirals to house
- ✅ Compiles
