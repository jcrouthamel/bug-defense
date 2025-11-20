# USER ACTION REQUIRED - Manual Gameplay Testing

## Status Overview

### ✅ Completed (Automated)
All code-based verification has been completed successfully:

1. **Build & Launch** - Game built and launched successfully
2. **Code Inspection** - All TASK0-TASK3 implementations verified
3. **Acceptance Criteria (Code)** - 8 out of 12 criteria verified via code inspection

### ⏳ Pending (Requires Manual Testing)
The following items require **interactive gameplay testing** which cannot be automated:

- **Item 2:** Validate tower placement on roads (visual feedback, console messages)
- **Item 3:** Validate bug path following (observe bug movement)
- **Item 4:** Validate map transitions (progress to wave 10)
- **Item 5:** Validate edge cases (house protection, bounds checking)

---

## What You Need To Do

### The game is running - please perform these manual tests:

### Test 1: Tower Placement on Roads (5 minutes)
1. Move your cursor/finger over a **road tile** → preview should be **RED**
2. Click on the road tile → placement should be **REJECTED**
3. Check Terminal/Console for: `❌ Cannot place on road: (X,Y)`
4. Move cursor over a **non-road tile** → preview should be **GREEN**
5. Click on the non-road tile → tower should be **PLACED**
6. Check Terminal/Console for: `✅ Can place at: (X,Y)`

**Expected:** Road placement blocked, adjacent placement works

---

### Test 2: Bug Path Following (5 minutes)
1. Click **"Start Wave"** to spawn bugs
2. **Observe bug movement** → bugs should follow the visible road path
3. Check Terminal/Console for: `🛣️ Using predefined road path for [bugType]`
4. **Verify NO messages like:** `🚧 Road is blocked!`
5. Progress to a wave with **flying bugs** (mosquito/wasp)
6. **Observe flying bugs** → should follow road (NOT fly direct to house)

**Expected:** All bugs follow road path smoothly

---

### Test 3: Map Transitions (15-20 minutes)
1. Play through **waves 1-9**
2. Complete **wave 10** → map should change
3. **Observe new map** loads with different road layout
4. **Attempt tower placement** on new map's road → should be rejected
5. If bugs are alive during transition, check console for: `🛣️ [Recalc] Using predefined road path`
6. **Verify towers** placed before map change remain

**Expected:** New map road protected, existing towers preserved

---

### Test 4: Edge Cases (5 minutes)
1. **House Protection:** Try to place tower on house → should fail with `❌ Cannot place on house`
2. **Out of Bounds:** Try to place tower outside grid → should fail with `❌ Out of bounds`
3. **Duplicate:** Place tower at position A, try again at A → should fail with `❌ Structure already exists`
4. **Road Adjacency:** Place towers in all 4 directions next to road (not on it) → all should succeed
5. **Spot Check:** Try road placement on Maps 5, 10, 15, 20 → all should reject

**Expected:** All validation checks work correctly

---

## How To Mark Tests Complete

After you've completed the manual tests above:

### If ALL tests pass:
1. Edit `/Users/jrc/Code/bug-defense/bug-defense-main/.claudiomiro/TASK4/TODO.md`
2. Mark items 2-5 as `[X]` (completed)
3. Change first line from `Fully implemented: NO` to `Fully implemented: YES`

### If ANY test fails:
1. Document which test failed and what you observed
2. Keep TODO.md first line as `Fully implemented: NO`
3. Add failure notes to items 2-5 in TODO.md
4. Report the issue for investigation

---

## Quick Reference: What To Look For

### ✅ SUCCESS indicators:
- Red preview on road tiles
- Green preview on valid tiles
- Console messages: `❌ Cannot place on road`, `✅ Can place at`, `🛣️ Using predefined road path`
- Bugs follow visible road path (both ground and flying)
- Map transitions load new roads correctly

### ❌ FAILURE indicators:
- Can place tower on road
- Preview always green or always red
- Console messages: `🚧 Road is blocked!` (should NOT appear)
- Bugs deviate from road path
- Flying bugs fly direct to house
- Map transition breaks road protection

---

## Automated Verification Results (Reference)

The following has been **automatically verified via code inspection**:

✅ TASK0: Road placement validation exists (GameScene.swift:862-866)
✅ TASK1: Bug spawn uses road path only (GameScene.swift:510-526)
✅ TASK2: Path recalculation uses road path only (GameScene.swift:1031-1040)
✅ TASK3: isRoadPathBlocked() function removed from codebase
✅ AC2: Preview color logic implemented (GameScene.swift:692-695, 841-844)
✅ AC4: No flying bug special pathfinding logic
✅ CQ1: Console logging uses emoji prefixes
✅ CQ2: No breaking changes to core systems

---

## Questions?

- See `VALIDATION_STATUS.md` for detailed test procedures
- See `TODO.md` for complete task context and acceptance criteria
- All automated checks passed - only manual gameplay testing remains
