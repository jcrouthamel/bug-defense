Fully implemented: NO

## Context Reference

**For complete environment context, read these files in order:**
1. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md` - Universal context (tech stack, architecture, conventions)
2. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/TASK.md` - Task-level context (what this task is about)
3. `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/PROMPT.md` - Task-specific context (files to touch, patterns to follow)

**You MUST read these files before implementing to understand:**
- Tech stack (Swift 5.x + SpriteKit, XCTest framework)
- Project structure and architecture (Entity-Component pattern)
- Coding conventions and patterns (emoji prefixes, grid-world dual coordinates)
- Complete acceptance criteria (12 requirements in AI_PROMPT.md Section 4)
- Verification checklist (8-item checklist in AI_PROMPT.md Section 6)
- Dependencies from TASK0-3 and their outputs

**DO NOT duplicate this context below - it's already in the files above.**

## Implementation Plan

- [ ] **Item 1 — Verify Dependency Task Completion and Gather Evidence**
  - **What to do:**
    1. Read each dependency task's TASK.md and PROMPT.md files to understand expected deliverables
    2. For TASK0: Verify root cause analysis documentation exists (check for CONTEXT.md, RESEARCH.md, or analysis in TASK0 directory)
    3. For TASK1: Read the modified `Sources/BugDefense/Bug.swift` file (lines 254-316) to verify vector-based movement implementation
    4. For TASK2: Verify unit tests exist in `Tests/BugDefenseTests/` (look for BugMovementTests.swift or similar)
    5. For TASK3: Verify manual testing documentation exists (check TASK3 directory for test report or CONTEXT.md)
    6. Document findings: which tasks are complete, which deliverables are present, which are missing
    7. Create evidence inventory list with file paths and brief descriptions

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/TASK.md` — Expected deliverables for root cause analysis
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/TASK.md` — Expected deliverables for implementation
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/TASK.md` — Expected deliverables for unit testing
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/TASK.md` — Expected deliverables for manual testing
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/Bug.swift:254-316` — Current movement implementation
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Tests/BugDefenseTests/` — Test directory

  - **Touched (will modify/create):**
    - CREATE: Working notes file (optional, for tracking evidence)

  - **Interfaces / Contracts:**
    N/A - This is a verification task, no contracts to define

  - **Tests:**
    N/A - This item is about gathering evidence, not testing

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    N/A - No observability requirements

  - **Security & Permissions:**
    N/A - Read-only verification

  - **Performance:**
    N/A - No performance requirements for verification

  - **Commands:**
    ```bash
    # List TASK0 directory contents to find documentation
    ls -la /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK0/

    # List TASK1 directory contents
    ls -la /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK1/

    # List TASK2 directory contents
    ls -la /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK2/

    # List TASK3 directory contents
    ls -la /Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK3/

    # List test files to find unit tests
    ls -la /Users/jrc/Code/bug-defense/bug-defense-main/Tests/BugDefenseTests/
    ```

  - **Risks & Mitigations:**
    - **Risk:** Previous tasks may be incomplete or documentation missing
      **Mitigation:** Document what's missing and either flag for completion or note as limitation
    - **Risk:** Implementation may not match task descriptions
      **Mitigation:** Clearly document discrepancies and assess impact on acceptance criteria

- [ ] **Item 2 — Cross-Reference All 12 Acceptance Criteria Against Implementation and Tests**
  - **What to do:**
    1. Read AI_PROMPT.md Section 4 to get the complete list of 12 acceptance criteria
    2. For EACH criterion (1-12), perform the following analysis:
       - Identify WHERE it should be verified (TASK1 code, TASK2 tests, TASK3 manual testing)
       - Find the EVIDENCE in the deliverables (specific code lines, test names, test report sections)
       - Make EXPLICIT determination: ✅ Met, ❌ Not Met, or ⚠️ Uncertain
       - Document REASONING for the status (why is it met/not met?)
    3. Create a detailed traceability matrix in markdown table format
    4. Pay special attention to criteria that require both automated AND manual verification
    5. Note any criteria that have NO verification evidence at all
    6. Follow the template from PROMPT.md lines 100-103

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:105-137` — Complete list of 12 acceptance criteria
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/PROMPT.md:27-41` — Summary of the 12 criteria
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/Bug.swift:254-316` — Implementation to verify
    - TASK1 deliverables (implementation code and comments)
    - TASK2 deliverables (unit tests)
    - TASK3 deliverables (manual test report)

  - **Touched (will modify/create):**
    - CREATE: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/TRACEABILITY_MATRIX.md`

  - **Interfaces / Contracts:**
    N/A - Verification task

  - **Tests:**
    N/A - This item analyzes existing tests, doesn't create new ones

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    N/A - No observability requirements

  - **Security & Permissions:**
    N/A - Read-only analysis

  - **Performance:**
    N/A - Performance is one of the 12 criteria being verified, not a requirement of this item

  - **Commands:**
    ```bash
    # Read Bug.swift to analyze implementation
    # (Use Read tool instead - this is informational)

    # Read test files to identify test coverage
    # (Use Read tool instead - this is informational)
    ```

  - **Risks & Mitigations:**
    - **Risk:** Some criteria may be subjective or hard to verify objectively
      **Mitigation:** Mark as ⚠️ Uncertain and document what additional evidence would be needed
    - **Risk:** Implementation may partially satisfy a criterion
      **Mitigation:** Mark as ❌ Not Met and document what's missing, or note as "Partially Met" with explanation

- [ ] **Item 3 — Run Complete Test Suite and Build Verification**
  - **What to do:**
    1. Run the full XCTest suite using `swift test` command
    2. Capture the complete output (number of tests, pass/fail count, any failures)
    3. If there are failures, analyze whether they are:
       - Related to the bug movement fix (critical)
       - Pre-existing failures unrelated to this work (document as known limitation)
       - Flaky tests (run again to confirm)
    4. Run `swift build` to ensure clean compilation
    5. Capture any compiler warnings or errors
    6. Document test results with specific counts and any failure details
    7. Verify that TASK2 movement tests specifically are present and passing

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Tests/BugDefenseTests/BugDefenseTests.swift` — Existing test file
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Package.swift:26-28` — XCTest framework configuration

  - **Touched (will modify/create):**
    - CREATE: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/TEST_RESULTS.md`

  - **Interfaces / Contracts:**
    N/A - Verification task

  - **Tests:**
    Type: Running existing XCTest unit tests
    - All existing tests should pass (or pre-existing failures documented)
    - TASK2 movement tests should be present and passing
    - No new test failures introduced by the bug movement fix
    - Test output should show 0 failures for changed code

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    N/A - No observability requirements

  - **Security & Permissions:**
    N/A - Build and test verification

  - **Performance:**
    - Build should complete in reasonable time (< 5 minutes)
    - Test suite should complete in reasonable time (< 1 minute)

  - **Commands:**
    ```bash
    # Run complete test suite
    swift test

    # Run build to verify compilation
    swift build

    # If you need to run tests with verbose output
    swift test --verbose
    ```

  - **Risks & Mitigations:**
    - **Risk:** Tests may fail due to environment issues (missing dependencies, wrong Swift version)
      **Mitigation:** Document environment issues separately from code issues
    - **Risk:** Pre-existing test failures may mask new failures
      **Mitigation:** Compare test results to git history or note which failures are new vs. pre-existing
    - **Risk:** Flaky tests may cause intermittent failures
      **Mitigation:** Run tests multiple times if failures are observed, document flaky tests

- [ ] **Item 4 — Perform Self-Verification Checklist Review**
  - **What to do:**
    1. Read AI_PROMPT.md Section 6 to get the 8-item self-verification checklist
    2. For EACH of the 8 checklist items, perform review:
       - **Code review:** Read Bug.swift:254-316, verify movement logic is geometrically sound (vector normalization, distance calculation, waypoint snapping)
       - **Unit tests:** Verify TASK2 tests cover critical cases (horizontal, vertical, diagonal, edge cases)
       - **Manual testing:** Verify TASK3 report confirms game was actually run and bugs observed
       - **Multiple maps:** Verify TASK3 tested at least Maps 1, 8, 9, 15 (or 3+ different map types)
       - **Bug types:** Verify TASK3 or TASK2 tested both slow bugs (beetle) and fast bugs (spider, wasp)
       - **Code clarity:** Verify Bug.swift has clear variable names, comments explaining key decisions
       - **No regressions:** Verify TASK3 tested flying bugs (mosquito, wasp) and burrowing bugs still work
       - **Documentation:** Verify Bug.swift has emoji-prefixed comments (🐛) explaining complex logic
    3. Mark each item as ✅ Pass, ❌ Fail, or ⚠️ Uncertain
    4. Document evidence for each determination (file:line references, test names, report sections)

  - **Context (read-only):**
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:309-318` — 8-item self-verification checklist
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/PROMPT.md:56-67` — Checklist reference
    - `/Users/jrc/Code/bug-defense/bug-defense-main/Sources/BugDefense/Bug.swift:254-316` — Implementation to review
    - TASK2 test deliverables
    - TASK3 manual testing report

  - **Touched (will modify/create):**
    - UPDATE: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/TRACEABILITY_MATRIX.md` (add checklist section)

  - **Interfaces / Contracts:**
    N/A - Verification task

  - **Tests:**
    N/A - This item reviews existing tests

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    N/A - No observability requirements

  - **Security & Permissions:**
    N/A - Code review

  - **Performance:**
    N/A - Performance review is part of the checklist items, not a requirement of this task item

  - **Commands:**
    N/A - This is a manual code review task

  - **Risks & Mitigations:**
    - **Risk:** Subjective assessment of "code clarity" or "simple and understandable"
      **Mitigation:** Use concrete criteria (comments present, variable names descriptive, < 50 lines of logic)
    - **Risk:** Missing evidence for manual testing
      **Mitigation:** Mark as ⚠️ Uncertain and note what evidence is missing

- [ ] **Item 5 — Create Final Validation Report and Make Completion Decision**
  - **What to do:**
    1. Synthesize all findings from Items 1-4 into a comprehensive validation report
    2. Create executive summary stating overall status
    3. List acceptance criteria results (X/12 met, Y/12 not met, Z/12 uncertain)
    4. Summarize test results (tests passing/failing, build status)
    5. Include the complete traceability matrix from Item 2
    6. Document self-verification checklist results from Item 4
    7. List any issues found, gaps in verification, or outstanding concerns
    8. Provide clear recommendations for next steps (if any)
    9. Make EXPLICIT final decision: ✅ COMPLETE, ❌ INCOMPLETE, or ⚠️ NEEDS REVIEW
    10. Justify the decision with concrete evidence
    11. If INCOMPLETE, specify which tasks need rework and what must be done
    12. Follow the Final Validation Report Template from PROMPT.md:159-215

  - **Context (read-only):**
    - All evidence gathered in Items 1-4
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/PROMPT.md:159-215` — Report template
    - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/AI_PROMPT.md:1-9` — Success definition

  - **Touched (will modify/create):**
    - CREATE: `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/FINAL_VALIDATION_REPORT.md`

  - **Interfaces / Contracts:**
    N/A - Final reporting

  - **Tests:**
    N/A - This item summarizes test results, doesn't run tests

  - **Migrations / Data:**
    N/A - No data changes

  - **Observability:**
    N/A - No observability requirements

  - **Security & Permissions:**
    N/A - Documentation task

  - **Performance:**
    N/A - Performance results are reported, not a requirement

  - **Commands:**
    N/A - This is a documentation task

  - **Risks & Mitigations:**
    - **Risk:** Premature conclusion that work is complete when issues remain
      **Mitigation:** Use conservative criteria - if uncertain, mark NEEDS REVIEW rather than COMPLETE
    - **Risk:** Overly critical assessment that flags minor issues as blockers
      **Mitigation:** Distinguish between critical issues (acceptance criteria not met) vs. nice-to-have improvements

## Verification (global)

- [ ] All 5 implementation items completed successfully
- [ ] Evidence gathered from all dependency tasks (TASK0-3)
- [ ] All 12 acceptance criteria explicitly verified with status (✅/❌/⚠️)
- [ ] Traceability matrix complete with all requirements mapped
- [ ] Test suite run with results documented (`swift test` output captured)
- [ ] Build verification complete (`swift build` successful or issues documented)
- [ ] Self-verification checklist (8 items) all checked with evidence
- [ ] Final validation report created with clear decision
- [ ] If INCOMPLETE status, specific next steps documented
- [ ] No assumptions made - all verifications based on actual evidence

## Acceptance Criteria

From TASK.md, this TASKΩ task succeeds when:

- [ ] **All 12 acceptance criteria verified**: Each criterion from AI_PROMPT.md Section 4 has been checked and confirmed (or marked not met with reasoning)
- [ ] **All tests passing**: `swift test` shows 0 failures for changed code (or pre-existing failures documented separately)
- [ ] **Clean build**: `swift build` completes successfully without errors
- [ ] **Manual testing complete**: TASK3 report confirms visual quality verification was performed
- [ ] **No regressions found**: Flying bugs (mosquito, wasp) and burrowing bugs (beetle) verified working correctly
- [ ] **Traceability matrix complete**: All requirements mapped to implementation and tests with evidence
- [ ] **Code quality verified**: Bug.swift changes reviewed for clarity, comments, conventions
- [ ] **Self-verification checklist complete**: All 8 items from AI_PROMPT.md Section 6 checked with evidence
- [ ] **Final status determined**: Clear COMPLETE/INCOMPLETE/NEEDS_REVIEW decision made with justification
- [ ] **Final validation report exists**: Comprehensive report created at TASKΩ/FINAL_VALIDATION_REPORT.md

## Impact Analysis

- **Directly impacted:**
  - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/TRACEABILITY_MATRIX.md` (created)
  - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/TEST_RESULTS.md` (created)
  - `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASKΩ/FINAL_VALIDATION_REPORT.md` (created)

- **Indirectly impacted:**
  - If validation finds issues, may need to return to TASK1, TASK2, or TASK3 for fixes
  - User's understanding of whether the requirement "keep bugs on the path at all times" has been satisfied
  - Project completion status and readiness for deployment/delivery

## Follow-ups

None identified at planning stage. Follow-ups will be determined based on validation findings and documented in FINAL_VALIDATION_REPORT.md.
