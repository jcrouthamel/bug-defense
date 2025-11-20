## PROMPT
Perform final system-level validation that all requirements from AI_PROMPT.md have been met. Verify the bug movement fix is complete, correct, and regression-free by cross-referencing all acceptance criteria against the implementation and test results.

**Your objective:** Create a comprehensive verification report that proves (or disproves) that the work is complete and the user's requirement "keep bugs on the path at all times" has been fully satisfied.

## COMPLEXITY
Low

## CONTEXT REFERENCE
**For complete environment context, read:**
- `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Contains full acceptance criteria (Section 4), verification checklist (Section 6), success definition (Section 1), and all requirements

**You MUST read AI_PROMPT.md before executing this task to understand all requirements.**

## TASK-SPECIFIC CONTEXT

### What This Task Does
This is the **Final Ω Validation Task** that depends on all previous tasks:
- **TASK0:** Root cause analysis (foundation)
- **TASK1:** Implementation fix (core work)
- **TASK2:** Unit testing (automated verification)
- **TASK3:** Manual testing (visual verification)

Your job: Verify that together, these tasks fully satisfy the user's requirement.

### The 12 Acceptance Criteria to Verify
From AI_PROMPT.md Section 4, check ALL of these:

1. **Strict Path Adherence** - Bugs visually on road tiles at all times
2. **Waypoint-to-Waypoint Movement** - Sequential waypoint progression
3. **Smooth Visual Motion** - No jerky or teleporting movement
4. **Exact Waypoint Arrival** - Position snaps exactly at waypoints
5. **Preserve Diagonal Path Segments** - Diagonal movement works
6. **Horizontal and Vertical Segments** - Orthogonal alignment perfect
7. **No Regression** - Flying/burrowing bugs unchanged
8. **Speed Consistency** - Speed calculations accurate
9. **Grid Position Sync** - gridPosition stays synchronized
10. **Edge Cases Handled** - Slow/fast bugs, various paths work
11. **All Maps Work** - Fix works across all map geometries
12. **Performance** - No significant performance degradation

### Verification Sources
Each criterion should be verified using outputs from previous tasks:

- **TASK0 output:** Root cause analysis document (in CONTEXT.md or similar)
- **TASK1 output:** Modified Bug.swift with vector-based movement
- **TASK2 output:** Unit tests + test results (`swift test`)
- **TASK3 output:** Manual testing report

### Success Definition
From AI_PROMPT.md Section 1:
> "Bugs move smoothly along the road path without ever visually appearing off the brown dirt road tiles, maintaining precise alignment with the path at all times during their journey from spawn to house."

Your validation should confirm this is TRUE.

### Self-Verification Checklist
From AI_PROMPT.md Section 6, verify these 8 items:

- [ ] Code review: Does the movement logic make geometric sense?
- [ ] Unit tests: Do tests cover the critical cases?
- [ ] Manual testing: Did you actually run the game and watch bugs?
- [ ] Multiple maps: Did you test at least 3 different map types?
- [ ] Bug types: Did you test with both slow and fast bugs?
- [ ] Code clarity: Is the movement logic simple and understandable?
- [ ] No regressions: Do flying bugs and burrowers still work?
- [ ] Documentation: Are any complex decisions explained in comments?

## EXTRA DOCUMENTATION

### Verification Process

**Step 1: Gather Evidence**
- Read TASK0 analysis findings
- Read TASK1 implementation in Bug.swift
- Run `swift test` to see TASK2 test results
- Read TASK3 manual testing report

**Step 2: Cross-Reference Requirements**
For each of the 12 acceptance criteria:
1. Identify which task(s) address it
2. Find the evidence (code, test, report)
3. Make explicit determination: ✅ Met or ❌ Not met
4. Document reasoning

**Step 3: Run Final Tests**
```bash
# Ensure all tests pass
swift test

# Ensure clean build
swift build

# Quick smoke test (optional)
swift run
```

**Step 4: Create Traceability Matrix**
Map each requirement to its implementation and verification:

| Requirement | Where Implemented | How Verified | Status |
|-------------|-------------------|--------------|--------|
| Path adherence | TASK1: Bug.swift vector movement | TASK2 tests + TASK3 visual | ✅ |
| ... | ... | ... | ... |

**Step 5: Final Decision**
Based on all evidence, determine:
- ✅ **COMPLETE:** All criteria met, work is done
- ❌ **INCOMPLETE:** Some criteria not met, specify which tasks need rework
- ⚠️ **NEEDS REVIEW:** Uncertain, needs discussion

### Evidence Locations

**TASK0 Evidence:**
- Root cause analysis should be in TASK0/CONTEXT.md or similar
- Should explain why drift occurs and why vector normalization fixes it

**TASK1 Evidence:**
- Modified code in `Sources/BugDefense/Bug.swift` (lines 276-315)
- Should show vector normalization implementation
- Should have clear comments explaining approach

**TASK2 Evidence:**
- Test file: `Tests/BugDefenseTests/BugMovementTests.swift`
- Test results: Output of `swift test`
- Should show 7+ tests, all passing, covering edge cases

**TASK3 Evidence:**
- Manual testing report (in TASK3/CONTEXT.md or separate file)
- Should document testing Maps 1, 8, 9, 15
- Should confirm visual quality and no drift observed

### Traceability Matrix Template

```markdown
# Requirement Traceability Matrix

## 1. Strict Path Adherence
- **Requirement:** Bugs MUST remain visually on brown dirt road tiles at all times
- **Implementation:** TASK1 - Vector normalization in Bug.swift:XXX-YYY
- **Verification:**
  - TASK2: Unit tests verify position stays within tolerance
  - TASK3: Manual testing on Maps 1, 8, 15 confirms visual adherence
- **Status:** ✅ Met
- **Evidence:** [Specific test names or report sections]

## 2. Waypoint-to-Waypoint Movement
- **Requirement:** Bugs move sequentially through each waypoint
- **Implementation:** TASK1 - pathIndex increment logic in Bug.swift:XXX
- **Verification:**
  - TASK2: Tests verify pathIndex increments correctly
  - TASK2: Tests verify no waypoint skipping
- **Status:** ✅ Met
- **Evidence:** [Specific test names]

[Continue for all 12 criteria...]
```

### Final Validation Report Template

```markdown
# Final Validation Report - Bug Movement Fix

## Executive Summary
[Overall status: COMPLETE / INCOMPLETE / NEEDS REVIEW]
[Brief summary of findings]

## Acceptance Criteria Verification

### ✅ Criteria Met (X/12)
[List criteria that are fully satisfied with evidence]

### ❌ Criteria Not Met (Y/12)
[List criteria that are not satisfied with explanation]

### ⚠️ Criteria Uncertain (Z/12)
[List criteria where verification is unclear]

## Test Results

### Unit Tests (TASK2)
- Total tests: X
- Passing: Y
- Failing: Z
- Coverage: Changed lines in Bug.update()

### Manual Tests (TASK3)
- Maps tested: [List]
- Bug types tested: [List]
- Visual quality: [Assessment]
- Regression testing: [Results]

## Code Quality Review

### Implementation (TASK1)
- Code clarity: [Assessment]
- Follows conventions: [Yes/No]
- Performance: [No regressions / Issues found]
- Documentation: [Adequate / Needs improvement]

## Traceability Matrix
[Full matrix linking all 12 requirements to implementation and verification]

## Issues Found
[List any issues, gaps, or concerns]

## Recommendations
[Any follow-up work suggested]

## Final Decision
**Status:** ✅ COMPLETE / ❌ INCOMPLETE / ⚠️ NEEDS REVIEW

**Reasoning:** [Explanation of decision]

**Next Steps:** [If incomplete, what needs to be done]
```

## LAYER
Ω (Final validation - depends on all other tasks)

## PARALLELIZATION
Parallel with: []
This task must run after all other tasks complete.

## CONSTRAINTS
- IMPORTANT: Do not perform any git commit or git push
- **No new implementation** - only verify existing work
- **Be thorough** - check all 12 acceptance criteria explicitly
- **Be honest** - if something is not verified, say so
- Run actual tests (`swift test`) - don't assume they pass
- Read actual outputs from previous tasks - don't assume they exist
- Create clear, documented traceability matrix
- Make explicit final decision: COMPLETE / INCOMPLETE / NEEDS REVIEW

## DELIVERABLES

1. **Requirement Traceability Matrix**
   - All 12 acceptance criteria mapped to implementation and verification
   - Clear status (✅/❌/⚠️) for each

2. **Final Validation Report**
   - Executive summary
   - Detailed verification results
   - Test results summary
   - Code quality assessment
   - Issues found (if any)
   - Clear final decision

3. **Self-Verification Checklist**
   - All 8 items from AI_PROMPT.md Section 6 checked
   - Evidence documented for each

4. **Overall Status Determination**
   - Clear statement: Work is COMPLETE / INCOMPLETE / NEEDS REVIEW
   - Reasoning for the decision
   - Next steps if incomplete
