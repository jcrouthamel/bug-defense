## PROMPT
Design and implement Map 22 with a cloverleaf/four-petal looping pattern for the Bug Defense game.

**Your mission:** Create a visually striking map where the path loops around the house in four distinct arcs, providing moderate-high difficulty with strategic tower placement opportunities.

## COMPLEXITY
Medium

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack, architecture, project structure, coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
**Will modify:**
- `Sources/BugDefense/MapConfiguration.swift`
  - Add `.map22` case to MapType enum (around line 5)
  - Implement `map22Path` method (after existing maps)
  - Add case to `roadPath` switch statement (around line 43)

### Patterns to Follow
**Reference Map 11 (Box Spiral) for complex looping patterns:**
- See MapConfiguration.swift:350-412 for inspiration on creating multi-segment loops

**Enum and method pattern:**
```swift
case map22 = "Cloverleaf Loop"

private var map22Path: [GridPosition] {
    return [
        GridPosition(x: start_x, y: start_y),  // Spawn at edge
        // Arc 1: top-left petal
        // Arc 2: top-right petal
        // Arc 3: bottom-right petal
        // Arc 4: bottom-left petal
        // Spiral in to center
        GridPosition(x: 10, y: 7)              // House
    ]
}
```

### Integration Points
- CaseIterable automatically includes map22 in MapType.allCases
- Random selection will include this map in pool
- Path will be assigned to bugs via GameScene.spawnBug()

## EXTRA DOCUMENTATION

### Design Requirements
**Pattern Type:** Cloverleaf (Four-Petal Loop)

**Visual Characteristics:**
- Four arc segments extending from center area
- Each petal reaches toward a different quadrant
- Smooth curves (use multiple waypoints per arc)
- Path circulates around house before final approach

**Difficulty Target:** Moderate-High
- Path length: 50-70 waypoints after expansion
- Longer path but more complex layout
- Multiple approach angles challenge tower placement
- Strategic depth from looping pattern

**Example Cloverleaf Concept:**
```
        ┌──┐
        │  │ top-left petal
    ┌───┘  └───┐
    │          │ top-right petal
left│   HOUSE  │right
    │          │ bottom-right petal
    └───┐  ┌───┘
        │  │ bottom-left petal
        └──┘
```

### Suggested Structure
1. **Start:** Edge position (e.g., bottom-left at x=1, y=1)
2. **Petal 1:** Arc toward top-left quadrant
3. **Petal 2:** Arc toward top-right quadrant
4. **Petal 3:** Arc toward bottom-right quadrant
5. **Petal 4:** Arc toward bottom-left quadrant
6. **Spiral in:** Gradual approach to house at center
7. **End:** GridPosition(x: 10, y: 7)

**Tip:** Use 3-5 waypoints per petal to create smooth arcs rather than angular corners.

### Validation Checklist
Before submitting:
- [ ] All coordinates within safe zone (x:1-18, y:1-13)
- [ ] First waypoint at grid edge
- [ ] Last waypoint is GridPosition(x: 10, y: 7)
- [ ] Four distinct arc segments visible in pattern
- [ ] Arcs don't overlap with house until final approach
- [ ] Path forms recognizable cloverleaf shape

## LAYER
1 (Parallel map design layer)

## PARALLELIZATION
Parallel with: [TASK1, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]
Blocks: [TASK11, TASKΩ]

## CONSTRAINTS
- **IMPORTANT:** Do not perform any git commit or git push
- Follow existing MapConfiguration.swift code style
- Use multiple waypoints for smooth arcs (not jagged corners)
- Path must be continuous (expandPath handles interpolation)
- Test compilation after changes

## TESTING
After implementation:
1. **Compilation test:** `swift build`
2. **Manual verification:**
   - Verify path forms cloverleaf visually
   - Test bug navigation (if possible)
   - Check road tile rendering
   - Confirm tower placement works around petals

## SUCCESS CRITERIA
Task is complete when:
- ✅ Code compiles without errors
- ✅ Map 22 appears in MapType enum
- ✅ Path creates distinctive cloverleaf pattern with 4 petals
- ✅ All coordinates within safe zone
- ✅ Path starts at edge and ends at house
- ✅ Arcs are smooth (not angular zigzags)
