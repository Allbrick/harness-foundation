---
name: refactor
description: Improve the structure of existing code without changing its observable behaviour — extract, rename, deduplicate, simplify — with before/after equivalence verified. Use when asked to clean up, simplify, restructure, or reduce duplication, and never bundled with a behaviour change.
---

# Refactor

## Purpose

Change the shape of code while keeping what it does identical, and be able to demonstrate that
nothing changed.

## When to use

- The user explicitly asks for cleanup, simplification, deduplication, or restructuring.
- A planned feature is blocked by existing structure, and the user has agreed to prepare the ground
  first — as a *separate* change.

Do **not** refactor opportunistically during a feature or bug fix. Unrequested restructuring hides
the real change and inflates review cost.

## Inputs

- The specific code to restructure and the reason it needs restructuring.
- The tests that currently cover it — these are the equivalence evidence.
- The conventions the result must match.

## Procedure

1. **Define the invariant.** Write down exactly what observable behaviour must not change: public
   API, return values, side effects, error types and messages, output format, performance
   characteristics that callers depend on.
2. **Establish the safety net first.** Run the existing tests and record the result. If coverage of
   the target code is thin, add characterisation tests that pin current behaviour *before* touching
   anything — including behaviour that looks wrong. (Wrong-looking behaviour is a separate finding,
   not something to fix mid-refactor.)
3. **Take one transformation at a time** — extract function, rename, inline, move, deduplicate,
   simplify a conditional. Keep each step independently revertible.
4. **Re-run the tests after each step**, not only at the end. The step that broke them should still
   be the last one you made.
5. **Keep the diff honest.** No behaviour tweaks, no new features, no API changes, no reformatting
   of untouched code riding along.
6. **Compare before and after.** Confirm the invariant list from step 1 still holds, item by item.

## Validation

- [ ] The full available test suite passes, with the same results as before the refactor.
- [ ] No test was modified to accommodate the new structure (except mechanical renames of the
      symbols that moved).
- [ ] Public API, error behaviour, and output formats are unchanged.
- [ ] The diff contains no behaviour change — verifiable by reading it.
- [ ] The result is measurably simpler: fewer branches, less duplication, clearer names. If it is
      not, the refactor was not worth making.

## Failure handling

- **Tests are missing or too weak to prove equivalence** — stop. Report that the refactor cannot be
  verified, and propose adding characterisation tests first as a separate step.
- **A test fails mid-refactor** — revert to the last green step and re-approach in smaller moves.
  Never edit the test to match the new code.
- **A behaviour change turns out to be unavoidable** — stop and report it. It needs its own decision
  and its own change.
- **A latent bug is discovered** — report it; do not fix it inside the refactor.

## Output

```text
Motivation    — why this structure needed to change
Invariants    — what had to stay identical
Steps         — the transformations applied, in order
Equivalence   — tests run before and after, with results
Result        — what improved, concretely (duplication removed, branches reduced, ...)
Not done      — bugs or smells observed and deliberately left alone
```
