---
name: audit-harness
description: Detect drift between a repository and the harness that describes it — stale commands, superseded architecture, dead constraints, guardrails that no longer bind, and skills nobody uses. Use periodically on an adopted project, after a major refactor or dependency change, or when the agent starts making confidently wrong assumptions about the codebase.
---

# Audit harness

## Purpose

A harness describes a repository at a moment in time. The repository keeps moving. When `CLAUDE.md`
still names a library that was replaced two quarters ago, the harness does not merely fail to help —
it **actively pushes the agent toward wrong behaviour**, with the authority of a project rule.

This skill finds that gap, using the evidence ledger adoption left behind.

## When to use

- Periodically on an adopted project (a quarter is a reasonable default).
- After a major refactor, migration, dependency swap, or restructuring.
- When the agent starts asserting things about the codebase that are no longer true.
- Before onboarding someone new, who will trust `CLAUDE.md` literally.

If the project has never been adopted (no `.claude/project-profile.md`), use `adopt-harness` instead.

## Inputs

- The target repository at its current commit.
- `.claude/project-profile.md`, including the commit it was verified against and its trailing
  `audit:evidence` block.
- The current harness: `CLAUDE.md`, `.claude/settings.json`, `.claude/agents/`, `.claude/skills/`.

## Procedure

### 1. Establish the delta

```bash
git log --oneline <profile-commit>..HEAD | wc -l     # how much has happened
git diff --stat <profile-commit>..HEAD               # where it happened
```

If the profile names no commit, or the evidence block is missing, the incremental path is
unavailable: say so and fall back to re-running `adopt-harness analyze`.

### 2. Re-verify only what moved

For each section of the profile, diff **its own evidence paths**:

```bash
git diff <profile-commit>..HEAD -- <paths from audit:evidence for that section>
```

A section whose evidence is untouched is presumed still valid — note it as unchecked rather than
claiming it was verified. A section whose evidence changed gets re-read and re-confirmed against the
current code.

This is the whole reason adoption records evidence paths: a full re-analysis every quarter is a cost
nobody pays twice, so the audit quietly stops happening.

### 3. Run the drift checks

Follow `drift-checklist.md`. It covers the six categories: commands, architecture, constraints,
permissions, harness usage, and the profile's own `Unknown` list.

### 4. Classify each finding

| Severity | Meaning |
| --- | --- |
| `stale` | The harness states something no longer true — actively misleading. Fix first |
| `missing` | Something now true that the harness does not capture |
| `unused` | Harness content nothing uses — costs context, earns nothing |
| `unenforced` | A rule stated in prose that could now be enforced by settings or a check |

`stale` outranks everything. A missing rule leaves the agent uninformed; a stale rule leaves it
confidently wrong, which is worse.

### 5. Report, then fix only what is approved

Present findings with evidence. Apply fixes only for what the user approves — an audit that silently
rewrites the harness is indistinguishable from drift itself.

When fixes are applied, update the profile: refresh the claims, the `Verified against commit`, and
the evidence paths.

## Validation

- [ ] The profile's commit and evidence block were used, or their absence was reported.
- [ ] Every profile section is marked verified, re-verified, or explicitly unchecked.
- [ ] Every `stale` finding cites both the harness text and the contradicting repository evidence.
- [ ] Command claims were re-traced to definitions — not assumed still valid.
- [ ] The profile's previous `Unknown` items were revisited: resolved, still unknown, or now moot.
- [ ] Nothing was rewritten without approval.
- [ ] If changes were applied, the profile's commit and evidence paths were updated.
- [ ] `bash scripts/validate-harness.sh` passes, if the project has it.

## Failure handling

- **No profile** — report that the project was never adopted, or that the profile was deleted, and
  offer `adopt-harness`. Do not audit against nothing.
- **Profile has no commit or evidence block** (hand-written, or from an older adoption) — fall back
  to full re-analysis and say that the audit was not incremental.
- **The delta is enormous** (a rewrite, not an evolution) — stop the incremental path and recommend
  re-adoption. An audit that reports fifty `stale` findings is telling you the profile is obsolete.
- **The harness and the code disagree, and the code looks wrong** — report both. A constraint may be
  a rule the code is currently violating, not a stale rule. Do not "fix" the harness to match a
  regression.
- **A command now fails** — distinguish "the command changed" from "the build is broken right now".
  Only the first is harness drift.
- **A project skill is unused** — propose removal, but check history first: a skill for quarterly
  work looks unused in a monthly window.

## Output

```text
Delta        — commits and files changed since the profile's commit
Coverage     — profile sections re-verified vs presumed valid (unchecked)

[severity] <harness location> — what it claims
  Now:      what the repository actually shows, with file:line
  Evidence: paths that changed
  Fix:      the smallest correction

Unknown      — previously unknown items: resolved / still open / no longer relevant
Applied      — what was changed, after approval
Deferred     — findings reported but not acted on, and why
```

## Supporting files

| File | Loaded for |
| --- | --- |
| `drift-checklist.md` | Step 3 — the six drift categories and how to check each |
