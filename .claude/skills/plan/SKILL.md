---
name: plan
description: Produce an implementation plan before writing code — clarify the requirement, locate the relevant code, map the blast radius, weigh approaches, and list risks. Use before any non-trivial change, when a request spans multiple files or modules, or when the user asks how something should be built.
---

# Plan

## Purpose

Turn a request into an ordered, executable plan grounded in what the repository actually contains,
so that implementation is mechanical and its blast radius is known in advance.

## When to use

- Before implementing anything beyond a single obvious edit.
- When the change touches more than one module, a public interface, data shape, or shared state.
- When the user asks "how would you do X" or "what would this involve".

Skip it for a typo, a one-line fix in a file you have already read, or a change the user has already
specified line by line.

## Inputs

- The request, including any constraints and explicit non-goals.
- The repository itself — read, do not recall.
- Project conventions: root `CLAUDE.md`, contributing docs, config files.

## Procedure

1. **Restate the requirement** in your own words, including what is *not* being asked for. If two
   readings would produce materially different work, ask now.
2. **Find the relevant code.** Search by symbol, by feature name, by error string, and by directory
   convention — a single search angle misses things. Read the files you find, and the tests that
   cover them.
3. **Describe the current architecture** of that area: entry points, call flow, ownership of state,
   the boundaries the code respects.
4. **Map the blast radius.** List every file affected and why — callers, subclasses/implementations,
   tests, fixtures, configuration, documentation, generated code. Use search to prove each claim.
5. **Consider approaches.** For structural work, compare at least two and state why the loser loses:
   risk, blast radius, or fit with existing convention.
6. **Identify risks**: behaviour that could regress, migration/compatibility concerns, concurrency,
   security surface, performance, and anything you could not verify.
7. **Write the plan.** Ordered steps; each step names its files, its change, and how it will be
   checked. Include the tests to add and the validation commands to run — only commands the
   repository actually defines.

## Validation

Before presenting the plan, confirm:

- [ ] Every file named exists (verified by reading or listing, not assumed).
- [ ] Every command named was found in the repository's own config or docs.
- [ ] The blast-radius list came from search results, not intuition.
- [ ] Each step is independently checkable.
- [ ] Non-goals are stated.

## Failure handling

- **Cannot locate the relevant code** — report what you searched for and ask for a pointer. Do not
  plan against a guessed structure.
- **Requirement is ambiguous in a way that changes the design** — present the interpretations and
  ask. Do everything that does not depend on the answer first.
- **The change looks larger than the request implies** — say so with the evidence, and offer a
  smaller scoped alternative before proceeding.

## Output

```text
Requirement    — restated, with non-goals
Current state  — how the area works today (file:line)
Blast radius   — affected files/tests/docs, one reason each
Approach       — chosen design; alternatives rejected and why
Risks          — what could break; what is unverified
Plan           — ordered steps, each with files and its check
Validation     — the commands that will prove it works
Open questions — decisions needed from the user
```

Hand the plan to `implement` (or the `implementer` agent) once the user accepts it.
