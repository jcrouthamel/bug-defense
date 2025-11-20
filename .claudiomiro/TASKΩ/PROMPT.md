## PROMPT
Perform final cohesion validation to ensure all 10 new maps are correctly integrated and the complete feature is production-ready.

**Your mission:** Verify the entire system works cohesively - all maps integrated, tests pass, no regressions, requirements satisfied.

## COMPLEXITY
Medium

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full tech stack, architecture, project structure, coding conventions, and related code patterns

**You MUST read AI_PROMPT.md before executing this task to understand the environment.**

## TASK-SPECIFIC CONTEXT

### Files This Task Will Verify (Read-Only)
- `Sources/BugDefense/MapConfiguration.swift` - Verify all 10 new maps present
- `Tests/BugDefenseTests/MapConfigurationTests.swift` - Verify tests exist
- All other source files - Verify no regressions

### This Task Does NOT Write Code
This is a **validation and verification task only**. Do not modify code unless fixing critical bugs discovered during validation.

### What to Validate

**1. Completeness:**
- [ ] All 10 new maps (map21-map30) exist in MapType enum
- [ ] All 10 path methods implemented
- [ ] All 10 cases in roadPath switch
- [ ] Tests exist for all new maps

**2. Correctness:**
- [ ] All tests pass: `swift test`
- [ ] Code compiles: `swift build`
- [ ] No warnings or errors

**3. Requirements Traceability:**
- [ ] Every requirement from AI_PROMPT.md addressed
- [ ] All acceptance criteria met (see AI_PROMPT.md lines 121-167)
- [ ] No requirements skipped

**4. Integration:**
- [ ] MapType.allCases includes new maps
- [ ] Random selection works
- [ ] Existing maps (1-20) still work

**5. Quality:**
- [ ] Code style consistent
- [ ] Maps visually distinct
- [ ] Difficulty range appropriate (easy to hard)

## EXTRA DOCUMENTATION

### Validation Procedure

**Step 1: Build and Test**
```bash
swift build
swift test --filter MapConfigurationTests
```
Expected: All pass, no errors.

**Step 2: Code Inspection**
Open `Sources/BugDefense/MapConfiguration.swift`:
- Count new enum cases (should be 10)
- Count new path methods (should be 10)
- Count new switch cases (should be 10)
- Verify naming follows pattern

**Step 3: Requirements Matrix**
For each requirement in AI_PROMPT.md acceptance criteria (lines 121-167):
- [ ] Locate implementation
- [ ] Verify it works
- [ ] Check off as validated

**Step 4: Pattern Variety**
Verify all 10 maps have distinct patterns:
- Zigzag, Cloverleaf, Double Helix, Switchback, Diagonal Cross
- Perimeter Loop, Figure-8, Wave, Starburst, Labyrinth

**Step 5: Manual Testing (If Possible)**
If game can run:
- Test 3-5 new maps
- Verify bugs navigate correctly
- Check visual rendering
- Confirm tower blocking works

**Step 6: Regression Check**
- Verify existing maps (1-20) unchanged
- Verify existing systems work
- No new bugs introduced

### Success Criteria

**This task passes ONLY when ALL of these are true:**
- ✅ 10+ new maps implemented
- ✅ All tests pass
- ✅ Code compiles without errors
- ✅ All requirements from AI_PROMPT.md satisfied
- ✅ No existing functionality broken
- ✅ Maps are visually distinct
- ✅ Integration points work correctly
- ✅ System is production-ready

**If ANY criterion fails:**
- ❌ Return to relevant task to fix
- ❌ Re-run this validation
- ❌ Do not mark complete until all pass

### Traceability Checklist

From AI_PROMPT.md:
- [ ] "create 10 new maps" → Verify 10 new MapType cases
- [ ] "waypoint-based pathfinding" → Verify Bug.swift unchanged, paths work
- [ ] "keep bugs on path" → Manual test or review vector movement
- [ ] "visually distinct paths" → Inspect 10 different patterns
- [ ] "house position consistent" → All paths end at (10, 7)
- [ ] "random map selection" → MapType.random() includes new maps
- [ ] "paths in safe zone" → Unit tests verify bounds
- [ ] "varied difficulty" → Easy (perimeter) to Hard (labyrinth)

## LAYER
Ω (Final validation layer)

## PARALLELIZATION
Parallel with: []
Depends on: [TASK0, TASK1, TASK2, TASK3, TASK4, TASK5, TASK6, TASK7, TASK8, TASK9, TASK10, TASK11]

## CONSTRAINTS
- **IMPORTANT:** Do not perform any git commit or git push
- This is validation only - minimal code changes
- If bugs found, fix them or delegate to relevant task
- Must validate ENTIRE system, not just parts
- Do not skip any validation steps

## VALIDATION CHECKLIST

**Before marking this task complete:**
- [ ] All 10 maps implemented correctly
- [ ] All tests pass (`swift test`)
- [ ] Code compiles (`swift build`)
- [ ] All AI_PROMPT.md requirements satisfied
- [ ] No regressions in existing functionality
- [ ] Maps are visually distinct
- [ ] Integration points validated
- [ ] Code is production-ready
- [ ] Traceability matrix complete
- [ ] Ready for deployment

## FINAL SIGN-OFF

**Only mark TASKΩ complete when you can confidently state:**

> "I have verified that all 10 new maps are correctly implemented, integrated, and tested. The waypoint system works with all new maps. Visual rendering is correct. No existing functionality is broken. All requirements from AI_PROMPT.md are satisfied. The system is cohesive and production-ready."

**If you cannot make this statement, the task is NOT complete.**
