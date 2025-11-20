## PROMPT
Perform comprehensive final system-level verification to ensure all components work together correctly, all requirements from AI_PROMPT.md are satisfied, no requirements were missed, and the complete road enforcement feature meets the user's intent as expressed in their clarifications.

## COMPLEXITY
Medium

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack (Swift 5.x, SpriteKit), architecture, complete acceptance criteria, user's clarifications and intent, requirements traceability matrix, and self-verification checklist

**You MUST read AI_PROMPT.md before executing this task to understand the complete feature requirements and user's intent.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Touch
- No code changes - this is a verification-only task
- Review all files changed in TASK0-TASK3
- Review test results from TASK4
- Cross-reference with AI_PROMPT.md requirements

### Purpose of This Task
This is the **mandatory final validation** required by step0.2 decomposition guidelines. It serves as the quality gate that confirms:
1. All requirements are implemented (nothing missed)
2. All components integrate correctly (system-level validation)
3. User's intent is fully realized (traceability to clarifications)
4. Feature is production-ready (completeness verification)

### Integration Points
Validates the complete task dependency chain:
```
TASK0 (foundation) → TASK1 & TASK2 (parallel core changes) → TASK3 (cleanup) → TASK4 (testing) → TASKΩ (final verification)
```

### Verification Methodology

**1. Requirements Traceability (AI_PROMPT.md Section 6):**
Every user requirement must trace to implementation + verification

**2. Acceptance Criteria Completeness (AI_PROMPT.md Section 4):**
Every AC, EC, and CQ item must be validated as complete

**3. User Intent Alignment (AI_PROMPT.md Sections 8 & 9):**
Implementation must match user's clarified intent:
- "Prevent tower placement on roads" approach chosen
- Current bug movement preserved (smooth waypoint navigation)
- Flying bugs follow roads (no special behavior)

**4. System Integration:**
All components work together without conflicts or gaps

**5. No Regressions:**
Existing systems (movement, towers, maps) still function correctly

## EXTRA DOCUMENTATION

### Requirements Traceability Matrix (AI_PROMPT.md Section 6)
Verify each row of this matrix:

| User Request | Implementation | Verification |
|--------------|----------------|--------------|
| Keep bugs on map path | spawnBug() uses roadPath | TASK4 observation |
| For each map type | getCurrentRoadPath() | TASK4 multi-map test |
| Road-only movement | Remove A* fallback | TASK1/TASK2/TASK4 |
| Flying bugs on roads | No special logic | TASK4 mosquito/wasp |
| Prevent road placement | canPlaceStructure() | TASK0/TASK4 |

### Acceptance Criteria Reference (AI_PROMPT.md Section 4)
**Primary (AC1-AC5):** Cannot place on road, red preview, no A* fallback, flying bugs follow roads, simplified recalculation

**Edge Cases (EC1-EC4):** Map transitions, house protection, bounds checking, all 20 maps

**Code Quality (CQ1-CQ3):** Console logging, no breaking changes, dead code removed

### User's Clarifications (AI_PROMPT.md Section 8)
From CLARIFICATION_ANSWERS.json referenced in AI_PROMPT.md:
1. ❓ Problem observed: [Empty - no specific issue]
2. ✅ Road blocking: Option B - "Prevent tower placement on roads"
3. ✅ Path adherence: Option A - "Current behavior is fine"
4. ✅ Flying bugs: Option A - "Flying bugs follow roads"

### Success Criteria
**This task passes if:**
- Every verification checkbox is complete
- All requirements trace to implementation
- All acceptance criteria validated
- Test results confirm expected behavior
- Code changes match user's intent
- No regressions detected

**This task fails if:**
- Any requirement is missing or incomplete
- Any acceptance criteria not met
- Test results show unexpected behavior
- Code doesn't match user's clarifications
- Regressions in existing systems detected
- System integration issues found

### Code Files to Review
**Changed files (TASK0-TASK3):**
- `Sources/BugDefense/GameScene.swift`
  - `canPlaceStructure()` - added road check (TASK0)
  - `spawnBug()` - removed A* fallback (TASK1)
  - `recalculateBugPaths()` - removed blocking check (TASK2)
  - `isRoadPathBlocked()` - removed/deprecated (TASK3)

**Unchanged files (verify no impact):**
- `Sources/BugDefense/Bug.swift` - movement logic preserved
- `Sources/BugDefense/MapConfiguration.swift` - all 20 maps unchanged
- `Sources/BugDefense/PathfindingGrid.swift` - A* infrastructure intact

### Final Self-Verification Checklist
From AI_PROMPT.md section 6, verify:
- [ ] swift build succeeds
- [ ] Manual test: tower on road → rejected
- [ ] Manual test: bug spawns → follows road → reaches house
- [ ] Manual test: map changes → new road protected
- [ ] No hardcoded map logic (works generically)
- [ ] Console logs consistent
- [ ] Code cleaner (A* fallback removed)

## LAYER
Ω (Final validation layer)

## PARALLELIZATION
Parallel with: []

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push.
- This is a verification-only task (no code changes allowed)
- Must verify ALL requirements from AI_PROMPT.md (no skipping)
- Must trace every requirement to implementation + verification
- Must confirm user's clarifications were correctly interpreted
- Must validate system integration (not just individual components)
- Must check for regressions in unchanged systems
- If any verification fails, document exactly what failed and why
- Feature is NOT complete until all verifications pass
- This task serves as the final quality gate before feature completion
