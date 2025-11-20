## PROMPT
Design and implement Map 24 with a switchback/mountain road pattern featuring sharp 180-degree hairpin turns.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md`

**You MUST read AI_PROMPT.md before executing this task.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
- `Sources/BugDefense/MapConfiguration.swift` (add map24 enum, method, switch case)

### Pattern
**Type:** Switchback (Hairpin Turns)
**Difficulty:** Moderate (35-50 waypoints)
**Visual:** Stack of U-turns ascending/descending vertically

Example:
```
├──────┐
       │
┌──────┘
│
└──────┐
       │
┌──────┘ → House
```

## LAYER
1 (Parallel)

## PARALLELIZATION
Parallel with: [TASK1, TASK2, TASK3, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]

## CONSTRAINTS
- **IMPORTANT:** Do not commit or push
- Create 4-6 sharp U-turn segments
- Vertical progression pattern
- Safe zone: x:1-18, y:1-13

## SUCCESS CRITERIA
- ✅ Compiles successfully
- ✅ Switchback pattern with hairpin turns
- ✅ Visually distinct from zigzag
