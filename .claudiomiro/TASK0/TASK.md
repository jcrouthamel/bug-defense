@dependencies []
# Task: Foundation Analysis and Map Pattern Research

## Summary
Thoroughly analyze the existing MapConfiguration.swift codebase to understand map patterns, waypoint system implementation, and grid coordinate constraints. This foundation task ensures all subsequent map design tasks have the necessary context and understanding to create valid, well-structured map layouts.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack, architecture, coding conventions, and related code patterns

**Task-Specific Context:**
This task focuses on understanding the existing map infrastructure before creating new maps.

### Files This Task Will Analyze
- `Sources/BugDefense/MapConfiguration.swift` - All existing map patterns (lines 115-631)
- `Sources/BugDefense/Bug.swift` - Vector movement implementation (lines 240-302)
- `Sources/BugDefense/GameScene.swift` - Integration points (lines 488-504, 826-856, 1009-1018)

### Patterns to Understand
- Map enum case pattern (MapConfiguration.swift:5+)
- Path method implementation pattern (e.g., map1Path, map9Path)
- Path expansion algorithm (MapConfiguration.swift:70-103)
- Vector-based movement logic (Bug.swift:292-300)

### Critical Constraints to Document
- Safe zone boundaries: x:1-18, y:1-13
- House position: GridPosition(x: 10, y: 7) - always fixed
- Path connectivity: First waypoint = spawn point (edge), last = house
- Grid system: 20x15 tiles, 40-point tile size

## Complexity
Low

## Dependencies
Depends on: []
Blocks: [TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10]
Parallel with: []

## Detailed Steps
1. **Read MapConfiguration.swift completely**
   - Identify all existing map patterns (currently 20 maps)
   - Document the naming convention (map##Path methods)
   - Analyze diverse path patterns: winding, straight, spiral, maze

2. **Study existing map examples**
   - Map 1 (Winding Road): Classic serpentine with multiple turns (lines 118-137)
   - Map 9 (Straight Shot): Simple horizontal path (lines 319-332)
   - Map 11 (Box Spiral): Complex spiral pattern (lines 350-412)
   - Map 5 (Maze Runner): Intricate maze-like path (lines 205-239)

3. **Understand path expansion algorithm**
   - Read expandPath() method (lines 70-103)
   - Understand how waypoint corners are interpolated
   - Verify no gaps or duplicates in expanded paths

4. **Review vector movement implementation**
   - Read Bug.swift update() method (lines 275-301)
   - Confirm normalized vector approach prevents diagonal drift
   - Understand waypoint snap threshold (2 points)

5. **Document integration points**
   - spawnBug() path assignment (GameScene.swift:488-504)
   - Tower placement blocking (GameScene.swift:826-856)
   - Path recalculation on structure placement (GameScene.swift:1009-1018)

6. **Create design guidelines document**
   - Compile list of "safe" path patterns
   - Identify visual variety opportunities
   - Document difficulty spectrum (path length vs. complexity)

## Acceptance Criteria
- [ ] All existing map patterns analyzed and documented
- [ ] Path expansion algorithm understood and verified
- [ ] Vector movement logic confirmed working correctly
- [ ] Safe zone boundaries and constraints clearly documented
- [ ] Integration points with GameScene identified
- [ ] Design guidelines created for new map creation
- [ ] Pattern examples categorized by type (straight, zigzag, spiral, maze)
- [ ] Naming conventions and code structure patterns documented

## Code Review Checklist
- [ ] No code changes made (this is analysis only)
- [ ] Documentation is clear and actionable for map designers
- [ ] All constraints are explicitly stated
- [ ] Pattern examples reference specific line numbers

## Reasoning Trace
**Why this task is necessary:**
- Prevents duplication of existing patterns in new maps
- Ensures new maps follow established conventions
- Identifies the full range of visual variety already present
- Validates that waypoint system is working correctly before adding new maps
- Creates a knowledge base for parallel map design tasks

**Why it blocks other tasks:**
- Map designers (TASK1-TASK10) need this foundation knowledge to avoid:
  - Creating out-of-bounds paths
  - Duplicating existing patterns
  - Violating naming conventions
  - Missing critical constraints

**Trade-offs:**
- Adds upfront time but prevents rework
- Sequential bottleneck, but necessary for quality
- Could be skipped if designer is already familiar with codebase (not safe to assume)
