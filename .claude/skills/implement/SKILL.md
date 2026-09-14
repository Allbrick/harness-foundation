---
name: implement
description: Execute an approved plan — re-read the code, make the minimal change in the project's existing conventions, add tests, run the real validation commands, and review the diff. Use when the approach is settled and code needs to be written or modified.
---

# Implement

## Purpose

Convert an approved plan into a verified, minimal change that a reviewer can check step by step.

## When to use

After a plan exists and the user has accepted the approach — or for a change small and clear enough
that planning would be ceremony. Not for exploration: if you find yourself deciding the design while
editing, stop and use `plan`.

## Inputs

- The accepted plan (or the explicit instruction, for small changes).
- The current contents of the files it names.
- The project's conventions and its real validation commands.

## Procedure

1. **Confirm the plan** is still valid: does it name files that exist, in the state it assumed?
2. **Re-read the target code** immediately before editing it, including its tests. Never edit from
   memory or from the plan's summary alone.
3. **Change the minimum.** Solve the stated problem and nothing else. Unrelated defects you notice
   go in the follow-ups list, not in the diff.
4. **Match the local idiom.** Naming, file layout, error handling, logging, imports, comment density
   and test structure come from the surrounding code, not from your preference. Adding a dependency
   requires explicit approval.
5. **Implement**, one plan step at a time, keeping the tree in a working state where possible.
6. **Add tests** for the behaviour you changed: the intended path plus at least one edge or failure
   case. A regression fix gets a test that fails without the fix.
7. **Validate statically** — run the project's formatter, linter, and typechecker if they exist.
8. **Run the tests** — the targeted ones first, then the broader suite the project provides.
9. **Review the diff yourself** (`git diff`). Remove debug output, stray TODOs, commented-out code,
   unrelated formatting, and anything the plan did not call for.

## Validation

- [ ] Every plan step is done, or its omission is reported.
- [ ] Lint / typecheck / test / build run — using commands that exist — with real output recorded.
- [ ] New behaviour is covered by a test that would fail without the change.
- [ ] `git diff` contains only intended changes.
- [ ] No new dependency, no new config, no deleted test that was not explicitly agreed.

## Failure handling

- **Validation fails** — report the actual output. Fix it if the cause is inside your change and the
  plan's scope; otherwise stop and report. Never disable, skip, or delete a test to get a green run.
- **The plan is wrong or impossible** — stop at that step and report the conflict with evidence.
  Do not silently redesign mid-implementation.
- **No test infrastructure exists** — implement, state clearly that automated verification was not
  possible, and describe how the change was checked instead. Do not invent a framework or a command.
- **The change is growing past the plan** — stop, report the new blast radius, and re-plan.

## Output

```text
Changes     — files touched, one line each: what and why
Tests       — added/updated, and what they pin down
Validation  — commands run and their actual results (or: none available, with reason)
Deviations  — where reality differed from the plan
Follow-ups  — problems observed and deliberately left alone
```

Then run `review` (or the `reviewer` agent) before committing.
