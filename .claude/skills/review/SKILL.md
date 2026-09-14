---
name: review
description: Review a change against the things a generic reviewer cannot know — this project's architecture boundaries, conventions, and domain rules — after delegating generic correctness and quality to the built-in /code-review. Use before committing or merging, or when asked to review a diff, branch, or pull request.
---

# Review

## Purpose

Catch the defects that are only defects **in this project**: a crossed module boundary, a pattern
that contradicts the surrounding code, a domain invariant that the diff quietly breaks.

Generic review — correctness, edge cases, security, performance, readability — is already done well
by Claude Code's built-in `/code-review`. This skill does not reimplement it. It **runs it, then adds
the project layer on top**, and merges the two into one verdict.

```text
/code-review  (built-in)      generic correctness, edge cases, security, performance
      +
architecture boundary check   layering, dependency direction, public surface
      +
project convention check      does this look like the code around it?
      +
domain rule check             invariants the project's CLAUDE.md declares
      =
one severity-ranked report
```

## When to use

After any implementation, before commit or merge, and whenever the user asks for a review of a diff,
branch, file, or pull request.

Skip the project layer only when the project has no documented architecture, conventions, or domain
rules **and** none can be inferred from neighbouring code — in which case say so, and report the
built-in's findings alone.

## Inputs

- The change: `git diff`, `git diff <base>...HEAD`, a PR, or named files.
- **The project's `CLAUDE.md`** — its Architecture, Development rules, and Important constraints
  sections are the source of truth for this skill. Without it, the project layer has nothing to check
  against except neighbouring code.
- The code around the change: the modules it imports, the callers it affects, its existing tests.

## Procedure

### 1. Delegate the generic pass

Run the built-in `/code-review` over the same scope first, and keep its findings. Do not re-derive
them: a duplicated finding wastes the author's attention and makes the report look larger than it is.

If the built-in is unavailable in this runtime, say so in the report and use the fallback checklist
at the bottom of this file instead.

### 2. Architecture boundary check

Read the Architecture section of the project's `CLAUDE.md`, then check the diff against it:

- **Layering** — does a lower layer now import from a higher one? Does a module reach past its
  declared interface into another's internals?
- **Dependency direction** — does the change introduce a cycle, or a dependency the architecture
  forbids?
- **Public surface** — does it change something with external consumers (API, schema, event payload,
  file format, CLI flags) without the migration the project requires?
- **Ownership of state** — does it mutate state owned by another component?
- **Escape hatches** — a workaround around a boundary (re-export, dynamic import, reflection, a
  helper in a shared folder) is a finding even when it works.

When the project documents no architecture, infer the boundaries from the existing import graph and
report the missing documentation as a `minor` finding of its own.

### 3. Project convention check

Compare the change to the code immediately around it, not to a general style ideal:

- Naming, file placement, and module structure.
- Error handling: thrown vs returned, error types, message format, what gets logged and at what level.
- The project's established patterns for the thing being done — if the codebase has one way to do
  this and the change invents a second, that is the finding.
- Test placement, naming, fixture and mocking style.
- Anything the project's `CLAUDE.md` Development rules section states explicitly.

A convention deviation is `minor` by default, `major` when it will propagate — a new pattern in a
widely-copied file teaches everyone the wrong thing.

### 4. Domain rule check

Check the invariants this project declares in `CLAUDE.md` (Important constraints) and in its own
code — validation rules, permission models, currency/unit handling, tenancy isolation, audit
requirements, generated files that must not be hand-edited, data that must never be touched.

These are the findings a generic reviewer structurally cannot produce, and they are usually the most
expensive ones to miss. Weight your attention here.

### 5. Merge and rank

- Drop any project-layer finding the built-in already reported.
- **Prove each remaining finding**: a concrete input or state, and the wrong result or the rule it
  breaks. A finding without a constructible failure is dropped, not downgraded.
- Rank all findings — the built-in's and yours — most severe first, in one list.

## Severity

| Severity | Meaning | Action |
| --- | --- | --- |
| `blocker` | Incorrect, unsafe, breaks existing behaviour, or violates a declared constraint | Must not merge |
| `major` | Real defect, significant risk, or a boundary violation that will propagate | Fix before merge unless explicitly deferred |
| `minor` | Narrow, low-impact issue; convention deviation | Cheap to fix, worth fixing |
| `suggestion` | Optional improvement, not a defect | Author's discretion |

## Validation

- [ ] The generic pass was actually run (or its absence is stated in the report).
- [ ] The project's `CLAUDE.md` was read — or its absence is reported as a finding.
- [ ] Each of the three project-layer checks was performed, or explicitly marked not applicable.
- [ ] Every finding has a concrete failure scenario or a named rule it violates.
- [ ] No finding duplicates one the built-in already reported.
- [ ] Severities reflect impact, not effort; preferences are `suggestion`, never `major`.

## Failure handling

- **The built-in `/code-review` is unavailable** — say so plainly and run the fallback checklist.
  Never present a project-layer-only review as a full review.
- **The project has no `CLAUDE.md`** — infer conventions from neighbouring code, state that the
  project layer is based on inference rather than declared rules, and report the missing file as a
  finding. Offer to generate one from `templates/CLAUDE.template.md`.
- **A rule appears to be violated but may be intentional** — report it as a question with the
  evidence, not as a `blocker`. Architecture documents go stale; the code may be right and the
  document wrong.
- **Cannot determine what the change is meant to do** — ask, rather than reviewing against a guess.
- **The change is too large to review meaningfully** — say so and review it module by module.
- **Nothing is wrong** — report zero findings and approve. Do not manufacture suggestions.

## Output

```text
Scope      — what was reviewed (commits/files)
Generic    — /code-review run: yes/no; findings carried over
Verdict    — approve | approve with comments | changes required

[severity] file:line — one-sentence statement of the defect
  Source:  built-in | architecture | convention | domain
  Failure: concrete input/state -> wrong result, or the rule it breaks
  Fix:     smallest change that addresses it

Not reviewed — anything out of scope or unverifiable, and why
```

Fixes are the author's job: report, do not rewrite, unless the user asks you to apply them.

---

## Fallback: no built-in generic reviewer

Only when step 1 could not run. Cover, in this order, and say in the report that this fallback was
used: correctness on the normal path; edge cases (empty, null, zero, boundary, duplicate, unicode,
very large, concurrent); regression against existing callers and tests; security (injection,
unvalidated input, authz gaps, secrets, unsafe deserialisation, path traversal); performance where it
plausibly matters (N+1, work in hot loops, unbounded growth); readability and duplication; and
whether a test exists that would fail without this change.
