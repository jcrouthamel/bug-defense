@dependencies [TASK0, TASK1, TASK2, TASK3]
# Task: Manual Testing Validation Across Map Types

## Summary
Perform comprehensive manual testing of the road enforcement system across multiple map types to verify that tower placement is correctly blocked on roads and that all bugs (ground and flying) follow predefined road paths. This validates the entire feature implementation through gameplay testing.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture (20 map types, tier progression every 10 waves), testing approach (manual gameplay testing only), and related code patterns

**Task-Specific Context:**
This task validates the complete implementation through manual gameplay testing. The project has no automated test framework, so manual validation is the required approach.

**Files This Task Will Touch:**
- No code changes - this is a validation task
- Will interact with the running game application

**Specific Testing Approach:**
Follow the testing guidance from AI_PROMPT.md section 5.1:
1. Happy path: tower placement off-road, bugs follow paths to house
2. Core change: tower placement on road rejected, bugs use predefined paths
3. Edge cases: map transitions, flying bugs, house position protection

**Acceptance Criteria to Validate:**
Reference AI_PROMPT.md section 4 for complete criteria list:
- AC1: Cannot place towers on road tiles (primary requirement)
- AC2: Visual feedback for invalid placement (red preview)
- AC3: No A* fallback for bugs (code inspection + behavior observation)
- AC4: Flying bugs follow roads
- AC5: Path recalculation simplified (code inspection)
- EC1-EC4: All edge cases handled correctly

## Complexity
Medium (requires systematic testing across multiple scenarios)

## Dependencies
Depends on: [TASK0, TASK1, TASK2, TASK3]
Blocks: [TASKΩ]
Parallel with: []

## Detailed Steps

### 1. Build and Launch Game
```bash
swift build
open BugDefense.app  # Or run from Xcode if needed
```

### 2. Test Core Functionality (Map 1 - Winding Road)
- [ ] Start game on Map 1 (default starting map)
- [ ] Attempt to place tower on road tile → should fail with red preview
- [ ] Verify console message: "❌ Cannot place on road: GridPosition(...)"
- [ ] Place tower adjacent to road (not on it) → should succeed
- [ ] Spawn bug (start wave) → observe bug follows road path to house
- [ ] Verify bug movement is smooth (waypoint-to-waypoint with axis locking)

### 3. Test Different Path Geometries
Test maps with different path complexities:
- [ ] **Map 9 (Straight Shot):** Attempt road placement → should fail
- [ ] **Map 11 (Box Spiral):** Attempt road placement → should fail
- [ ] Verify bugs follow respective paths correctly on both maps

### 4. Test Flying Bugs
- [ ] Spawn mosquito bug (flying type) → should follow road path
- [ ] Spawn wasp bug (flying type) → should follow road path
- [ ] Verify flying bugs do NOT take direct line to house (stay on road)

### 5. Test Map Transitions (Tier Progression)
- [ ] Progress through waves to trigger map change (every 10 waves)
- [ ] When map changes, verify new map's road is protected
- [ ] Attempt tower placement on new road → should fail
- [ ] If bugs are alive during transition, verify they recalculate to new road path
- [ ] Towers placed before map change should remain (not removed)

### 6. Test Edge Cases
- [ ] **House position:** Attempt tower placement on house → should still fail (existing check)
- [ ] **Out of bounds:** Attempt placement outside grid → should fail (existing check)
- [ ] **Existing structure:** Attempt placement on existing tower → should fail (existing check)
- [ ] **Road adjacency:** Place towers in all 4 cardinal directions adjacent to road → should succeed

### 7. Spot-Check Additional Maps
Quick validation on diverse map types (5 total spot-checks):
- [ ] Map 1 (Winding Road) - already tested above
- [ ] Map 5 - verify road protection works
- [ ] Map 10 - verify road protection works
- [ ] Map 15 - verify road protection works
- [ ] Map 20 - verify road protection works

### 8. Console Log Validation
Throughout testing, verify:
- [ ] Console logs use "❌" prefix for failures
- [ ] Log verbosity matches existing placement logs
- [ ] No error messages or warnings in console during normal gameplay

## Acceptance Criteria
All criteria from AI_PROMPT.md section 4 must be validated:

### Primary Requirements
- [ ] **AC1:** Players cannot place towers on any road tile (tested on Maps 1, 9, 11)
- [ ] **AC2:** Red preview shows when hovering over road tiles
- [ ] **AC3:** No A* pathfinding fallback (verified through observation + code inspection)
- [ ] **AC4:** Flying bugs (mosquito, wasp) follow road paths
- [ ] **AC5:** Path recalculation simplified (code inspection complete in TASK2)

### Edge Cases
- [ ] **EC1:** Map transitions preserve road protection (tested at wave 10+ transition)
- [ ] **EC2:** House position remains protected (existing behavior preserved)
- [ ] **EC3:** Out-of-bounds placement still rejected (existing behavior preserved)
- [ ] **EC4:** All 20 maps enforce road protection (spot-checked 5 maps: 1, 5, 10, 15, 20)

### Code Quality
- [ ] **CQ1:** Console logging consistency verified
- [ ] **CQ2:** No breaking changes to existing systems (verified through testing)
- [ ] **CQ3:** Dead code removed (verified in TASK3)

## Code Review Checklist
N/A - This is a testing task, not a code change task

## Reasoning Trace
**Why this depends on all previous tasks:**
Must test the complete implementation after all code changes are in place. Testing incomplete code would produce invalid results.

**Why this is not parallel:**
Cannot test code that hasn't been written yet. All implementation tasks (TASK0-TASK3) must complete first.

**Testing Strategy - Manual vs. Automated:**
Project has no unit test framework (confirmed in AI_PROMPT.md section 5.1). Manual testing is the only option and is appropriate for:
1. Gameplay behavior changes (visual/interactive)
2. Small codebase with limited test infrastructure
3. Changes affecting ~10 lines of code across 3 functions

**Coverage Strategy:**
Focus testing on changed behavior:
- **High coverage:** Road placement validation (core change)
- **Medium coverage:** Bug path following (should be unchanged but verify)
- **Low coverage:** Existing systems (bounds, house checks - spot-check only)

**Map Selection Rationale:**
- Map 1 (Winding Road): Complex path with many turns
- Map 9 (Straight Shot): Simple linear path
- Map 11 (Box Spiral): Geometric complexity
- Maps 5, 10, 15, 20: Representative sample across all 20 maps

This ensures road protection works across diverse path geometries.

**Success Criteria:**
All acceptance criteria pass → feature is complete and correct
Any acceptance criteria fail → fix required before TASKΩ
