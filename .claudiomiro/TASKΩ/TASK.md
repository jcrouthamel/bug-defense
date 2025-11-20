@dependencies [TASK0, TASK1, TASK2, TASK3, TASK4]
# Task: Final Integration Verification and System Completeness

## Summary
Perform final system-level verification to ensure all components work together correctly, no requirements were missed, and the complete feature implementation meets the user's intent. This validates the entire road enforcement system holistically across code, behavior, and requirements.

## Context Reference
**For complete environment context, see:**
- `../AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture, complete acceptance criteria, user's intent from clarifications, and related code patterns

**Task-Specific Context:**
This is the mandatory final validation task that confirms system-wide completeness and correctness.

**Files This Task Will Touch:**
- No code changes - this is a verification and traceability task
- Review all changed files from TASK0-TASK3
- Review test results from TASK4

**Integration Points:**
Validates the complete feature stack:
1. TASK0: Road placement blocking (foundation)
2. TASK1: Bug spawn simplification (removes A* at spawn)
3. TASK2: Path recalculation simplification (removes A* at transitions)
4. TASK3: Dead code cleanup (maintains code quality)
5. TASK4: Manual testing (validates observable behavior)

## Complexity
Medium (requires thorough cross-verification)

## Dependencies
Depends on: [TASK0, TASK1, TASK2, TASK3, TASK4]
Blocks: []
Parallel with: []

## Detailed Steps

### 1. Requirements Traceability Verification
Using AI_PROMPT.md section 6 (Verification and Traceability Matrix), confirm:

- [ ] **"Keep bugs on map path"**
  - Implementation: TASK1 `spawnBug()` always uses roadPath
  - Verification: TASK4 observed bugs following roads

- [ ] **"For each map type"**
  - Implementation: Uses `MapManager.shared.getCurrentRoadPath()` (generic for all 20 maps)
  - Verification: TASK4 tested Maps 1, 5, 9, 10, 11, 15, 20

- [ ] **"Road-only movement"**
  - Implementation: TASK1 & TASK2 remove A* fallback
  - Verification: TASK4 confirmed no A* behavior, code inspection in TASK3

- [ ] **"Flying bugs on roads"**
  - Implementation: TASK1 treats all bugs identically, no special flying logic
  - Verification: TASK4 tested mosquito/wasp bugs following roads

- [ ] **"Prevent road placement"**
  - Implementation: TASK0 `canPlaceStructure()` road check
  - Verification: TASK4 confirmed placement rejection with visual/console feedback

### 2. Acceptance Criteria Completeness
Verify all criteria from AI_PROMPT.md section 4 are met:

**Primary Requirements (AC1-AC5):**
- [ ] AC1: Cannot place towers on road (validated in TASK4)
- [ ] AC2: Red preview on invalid placement (validated in TASK4)
- [ ] AC3: No A* fallback (code changes in TASK1/TASK2, verified in TASK4)
- [ ] AC4: Flying bugs follow roads (validated in TASK4)
- [ ] AC5: Path recalculation simplified (implemented in TASK2)

**Edge Cases (EC1-EC4):**
- [ ] EC1: Map transitions preserve protection (validated in TASK4)
- [ ] EC2: House position protected (validated in TASK4)
- [ ] EC3: Out-of-bounds rejected (validated in TASK4)
- [ ] EC4: All 20 maps protected (spot-checked in TASK4)

**Code Quality (CQ1-CQ3):**
- [ ] CQ1: Console logging consistent (validated in TASK4)
- [ ] CQ2: No breaking changes (validated in TASK4)
- [ ] CQ3: Dead code removed (completed in TASK3)

### 3. Code Change Verification
Inspect each changed file to confirm implementation correctness:

**GameScene.swift:**
- [ ] `canPlaceStructure()` has road path check (TASK0)
- [ ] Road check uses `MapManager.shared.getCurrentRoadPath().contains(position)`
- [ ] Console log: "❌ Cannot place on road: \(position)"
- [ ] `spawnBug()` no longer has `isRoadPathBlocked()` conditional (TASK1)
- [ ] All bugs receive `roadPath` directly (TASK1)
- [ ] `recalculateBugPaths()` no longer checks road blocking (TASK2)
- [ ] `isRoadPathBlocked()` function removed or deprecated (TASK3)
- [ ] No misleading comments about A* fallback remain (TASK3)

**Build Verification:**
- [ ] Project builds successfully: `swift build`
- [ ] No compiler warnings about unused code
- [ ] No runtime errors during testing (confirmed in TASK4)

### 4. User Intent Alignment
Reference AI_PROMPT.md section 9 (Context for Downstream Agent):

- [ ] **User's goal:** "Predictable gameplay where bugs always follow designed map paths"
  - **Verified:** TASK4 confirmed predictable bug behavior

- [ ] **User's clarification:** "Prevent tower placement on roads" (not "bugs fail to spawn" or "keep A* fallback")
  - **Verified:** TASK0 implements prevention approach

- [ ] **User's clarification:** "Current bug movement is fine" (keep smooth waypoint navigation)
  - **Verified:** Bug.swift unchanged (TASK1-3 never modified movement logic)

- [ ] **User's clarification:** "Flying bugs follow roads" (same as ground bugs)
  - **Verified:** TASK4 confirmed, no special flying logic added

### 5. System Integration Validation
Cross-check interactions between components:

- [ ] **Tower placement → Bug spawning:** Prevented road placement ensures clear paths for bugs
- [ ] **Map transitions → Path recalculation:** TASK2 ensures bugs update to new road when map changes
- [ ] **Visual feedback → Validation logic:** Red preview matches `canPlaceStructure()` logic
- [ ] **Console logging → Debug experience:** Consistent ❌/✅ patterns aid troubleshooting
- [ ] **Flying bugs → Ground bugs:** Same behavior (no special cases introduced)

### 6. No Regressions Verification
Confirm existing systems still work:

- [ ] Bug movement smoothness preserved (axis-locking, waypoint-to-waypoint)
- [ ] Tower attack behavior unchanged
- [ ] Map path definitions unchanged (all 20 maps)
- [ ] Camera and HUD systems unaffected
- [ ] Tier progression system intact
- [ ] House position protection still enforced

### 7. Documentation and Traceability
- [ ] All tasks (TASK0-TASK4) have clear documentation
- [ ] Each task's acceptance criteria were met
- [ ] Requirements matrix (AI_PROMPT.md section 6) fully satisfied
- [ ] No requirements from AI_PROMPT.md were missed or skipped

### 8. Final Self-Verification Checklist
From AI_PROMPT.md section 6 (Self-Verification Checklist):

- [ ] All acceptance criteria (AC1-AC5) are met
- [ ] All edge cases (EC1-EC4) are handled
- [ ] Console logs match existing patterns
- [ ] No hardcoded map-specific logic (works for all 20 maps)
- [ ] Game builds without errors: `swift build`
- [ ] Manual test: Place tower on road → rejected
- [ ] Manual test: Bug spawns → follows road → reaches house
- [ ] Manual test: Map changes at wave 10 → new road protected
- [ ] Code is cleaner (removed dead A* fallback code)

## Acceptance Criteria
- [ ] All requirements from AI_PROMPT.md are traceable to implementation
- [ ] All acceptance criteria from AI_PROMPT.md section 4 are verified complete
- [ ] All tasks (TASK0-TASK4) completed successfully
- [ ] No missing or overlooked requirements
- [ ] User's intent (from clarifications in AI_PROMPT.md section 8) is fully satisfied
- [ ] System integration verified (components work together correctly)
- [ ] No regressions in existing systems
- [ ] Code quality standards met (clean, consistent, no dead code)
- [ ] Feature is production-ready

## Code Review Checklist
- [ ] Cross-reference all code changes against acceptance criteria
- [ ] Verify test results (TASK4) cover all acceptance criteria
- [ ] Confirm no requirements were merged, skipped, or forgotten
- [ ] Validate that user's clarifications were correctly interpreted
- [ ] Ensure simplification goal achieved (code is simpler, not more complex)

## Reasoning Trace
**Why this task is mandatory:**
Step0.2 decomposition requirements state: "Always create a Final Ω Task that depends on all others, verifies all modules interact correctly, ensures no requirement was forgotten, and confirms contracts, logs, tests, and flows align with system intent."

**What makes this different from TASK4:**
- **TASK4:** Validates observable behavior through manual testing
- **TASKΩ:** Validates system completeness, requirements traceability, and cross-component integration

**Why all tasks must complete first:**
Cannot verify system completeness until all implementation and testing tasks are done. This task provides the "zoom out" view to catch anything missed.

**Success criteria for this task:**
- Every checkbox is checked ✅
- No discrepancies between requirements and implementation
- No gaps in test coverage
- No overlooked edge cases
- User's intent fully realized in code and behavior

**If this task finds issues:**
Document exactly what is missing or incorrect, then create follow-up tasks or fixes as needed. This task serves as the final quality gate.

**Feature completion definition:**
This task passing means:
1. All user requirements implemented
2. All acceptance criteria met
3. All tests passed
4. Code is clean and maintainable
5. Feature is ready for production use

The feature is NOT complete until TASKΩ passes all verification steps.
