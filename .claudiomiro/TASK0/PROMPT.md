## PROMPT
Analyze the existing Bug Defense map system to understand patterns, constraints, and implementation details. Create comprehensive documentation that will guide the creation of 10 new unique map layouts.

**Your goal:** Become an expert on the existing map infrastructure without modifying any code.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack, architecture, project structure, coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
**Read only (no modifications):**
- `Sources/BugDefense/MapConfiguration.swift` - Analyze all existing maps (lines 5-631)
- `Sources/BugDefense/Bug.swift` - Study vector movement (lines 240-302)
- `Sources/BugDefense/GameScene.swift` - Review integration points (lines 488-504, 826-856, 1009-1018)

### Patterns to Follow
This is an analysis task. You are establishing the patterns that future tasks will follow.

### Integration Points
- Understand how GameScene retrieves and assigns paths to bugs
- Identify constraints that prevent tower placement on roads
- Verify path recalculation logic

## EXTRA DOCUMENTATION

### What to Document
Create clear notes covering:

1. **Existing Map Inventory**
   - List all 20 current maps with brief descriptions
   - Categorize by pattern type (straight, winding, spiral, maze, etc.)
   - Note path lengths (approximate waypoint count)

2. **Design Patterns**
   - Naming convention: MapType enum cases (.map##)
   - Path method pattern: `private var map##Path: [GridPosition]`
   - Return type: Array of GridPosition structs

3. **Constraints Checklist**
   - Grid boundaries: 20x15 tiles (0-19 x, 0-14 y)
   - Safe zone: x:1-18, y:1-13 (avoid edges)
   - House position: Fixed at GridPosition(x: 10, y: 7)
   - Path requirements: Start at edge, end at house

4. **Path Expansion Mechanics**
   - How expandPath() interpolates between waypoints
   - Why this allows defining paths with just key corners
   - Verification that intermediate tiles are filled

5. **Visual Variety Opportunities**
   - What patterns are already covered
   - What patterns are missing or underrepresented
   - Ideas for 10 new distinct layouts

6. **Code Integration Points**
   - Where paths are assigned to bugs (file:line)
   - Where tower placement is blocked (file:line)
   - Where grid rendering occurs (file:line)

### Output Format
Create a summary document (can be mental notes or written documentation) that answers:
- "What makes a valid map?"
- "What patterns already exist?"
- "What patterns should new maps explore?"
- "What are the absolute constraints I cannot violate?"

## LAYER
0 (Foundation - must complete before map design tasks)

## PARALLELIZATION
Parallel with: []
Blocks: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]

## CONSTRAINTS
- **IMPORTANT:** Do not perform any git commit or git push
- **Read-only task:** Do not modify any source files
- **No code generation:** This is pure analysis
- Focus on understanding, not implementation
- Document findings clearly for future reference
- Verify waypoint system is working correctly (from recent vector movement improvements)

## VALIDATION
Before marking this task complete, ensure you can answer:
- [ ] How many existing maps are there? (Should be 20)
- [ ] What is the safe zone boundary? (x:1-18, y:1-13)
- [ ] Where is the house always located? (x:10, y:7)
- [ ] What are 3 distinct existing path patterns? (e.g., winding, straight, spiral)
- [ ] How does expandPath() work? (Interpolates intermediate positions)
- [ ] What file contains the Bug movement logic? (Bug.swift)
- [ ] What is the waypoint snap threshold? (2 points distance)
- [ ] How do you add a new map to the enum? (Add case to MapType, implement path method, update switch)
