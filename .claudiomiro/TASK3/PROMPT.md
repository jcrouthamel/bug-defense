## PROMPT
Design and implement Map 23 with a double helix/DNA strand pattern featuring interweaving S-curves.

**Your mission:** Create a visually sophisticated map with smooth S-curves that appear to weave around each other like a DNA double helix.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack, architecture, project structure, coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
**Will modify:**
- `Sources/BugDefense/MapConfiguration.swift`
  - Add `.map23` case to MapType enum
  - Implement `map23Path` method
  - Add case to `roadPath` switch statement

### Patterns to Follow
**Reference Map 1 (Winding Road) for serpentine inspiration:**
- See MapConfiguration.swift:118-137

**Pattern:**
```swift
case map23 = "Double Helix"

private var map23Path: [GridPosition] {
    return [
        GridPosition(x: start_x, y: start_y),  // Spawn
        // S-curve segment 1
        // S-curve segment 2
        // S-curve segment 3
        GridPosition(x: 10, y: 7)              // House
    ]
}
```

## EXTRA DOCUMENTATION

### Design Requirements
**Pattern Type:** Double Helix (Interweaving S-Curves)

**Visual Characteristics:**
- 3-4 smooth S-curve segments
- Alternating left-right flow
- Appears to weave or cross visually
- Organic, flowing appearance

**Example S-Curve Flow:**
```
Start (bottom) → curve right → curve left → curve right → center house
      S              S             S
```

**Difficulty:** Moderate (40-55 waypoints)

### Suggested Waypoints
Create smooth curves using multiple intermediate points:
- Start: Edge position (e.g., x=1, y=1)
- First curve: Gradually move right while ascending
- Second curve: Gradually move left while continuing up
- Third curve: Gradually move right toward center
- End: GridPosition(x: 10, y: 7)

**Tip:** Use 4-6 waypoints per curve segment for smoothness.

## LAYER
1 (Parallel map design layer)

## PARALLELIZATION
Parallel with: [TASK1, TASK2, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]

## CONSTRAINTS
- **IMPORTANT:** Do not perform any git commit or git push
- Create smooth curves (not jagged)
- Path must appear to weave visually
- Stay within safe zone boundaries

## SUCCESS CRITERIA
- ✅ Code compiles without errors
- ✅ Pattern creates visible double helix/S-curve effect
- ✅ Smooth curves (not angular)
- ✅ Coordinates within safe zone
- ✅ Path starts at edge and ends at house
