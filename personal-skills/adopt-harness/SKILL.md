---
name: adopt-harness
description: Install the harness-foundation into a project and specialise it from evidence — survey what is already there, reconstruct how the repository actually works, write a verified project profile, then route each finding to the right control layer (CLAUDE.md, skill, agent, settings, validator, docs). Use when onboarding a repository to the harness, or when asked to set up Claude Code for a project. Takes an optional stage argument: analyze | install | specialize.
---

# Adopt harness

## Purpose

Turn a generic harness into **this project's** harness, on evidence rather than assumption.

The output is not "more Markdown for Claude to read". It is project knowledge placed in the layer
that can actually enforce it, plus an honest record of what is still unknown.

```text
DISCOVER → MODEL → TRACE → VERIFY → INSTALL → SPECIALIZE → VALIDATE → REPORT UNKNOWNS
```

Discovery comes **before** installation. An existing project may already carry a Claude, Cursor, or
Codex configuration, and overwriting it destroys knowledge that took someone months to accumulate.

## When to use

- Onboarding a repository to the harness for the first time.
- Asked to "set up Claude Code" or "configure the agent" for an existing codebase.
- A project has a `CLAUDE.md` that was never grounded in the repository and needs rebuilding.

Do **not** use it for ongoing maintenance of an already-adopted project — that is `audit-harness`,
which detects drift between the repository and the harness.

## Inputs

- The target repository, checked out, at a known commit.
- The path to a `harness-foundation` checkout (ask if it is not obvious; do not guess).
- Optional stage argument:

  | Argument | Runs | Writes |
  | --- | --- | --- |
  | *(none)* | Phases 1–6, pausing for approval before the first write | Yes, after approval |
  | `analyze` | Phases 1–4 | Only `.claude/project-profile.md` |
  | `install` | Phase 5a — baseline files only | Yes |
  | `specialize` | Phases 4–6, assuming a profile exists | Yes |

**Default behaviour is analysis first.** Present the findings and the planned changes, and get
approval before writing anything other than the profile.

## Procedure

### Phase 1 — Preflight: what is already here

Read `adoption-checklist.md` for the full survey list and merge rules. In summary: inventory the
existing agent configuration (`CLAUDE.md`, `.claude/`, `AGENTS.md`, `.cursor/`,
`.github/copilot-instructions.md`), then classify:

| State | Meaning | Rule |
| --- | --- | --- |
| `CLEAN` | No agent configuration at all | Install freely |
| `PARTIAL` | Some Claude config, incomplete | Add what is missing; never replace what exists |
| `EXISTING` | A working harness is already here | Diff and merge, file by file, with the user deciding |

**Never overwrite an existing file in phases 5–6 without showing the diff and getting approval.**

Configuration for other agents is *evidence*, not competition: a `.cursor/rules/` file that says
"always use the repository pattern" is a documented project convention. Read it into the model
rather than deleting it.

### Phase 2 — Repository reconstruction

Follow `repository-analysis.md`. It defines the evidence priority order (topology → build/runtime →
architecture → flow → development workflow → verification → deployment → domain invariants) and,
critically, when to **stop**: you are done when the completion criteria in Validation are met, not
when you run out of files.

### Phase 3 — Trace (mandatory, not optional)

Directory names are a hypothesis, never a conclusion. "It uses a layered architecture" inferred from
folder names is exactly the kind of confident wrongness this harness exists to prevent.

Pick one representative feature and trace, with file references at every hop:

1. **One execution path**, from user action to the system boundary (network, disk, queue, DB).
2. **One return path**, from the boundary back to what the user sees — including the transform and
   cache layers it passes through.
3. **One state mutation cycle**, from change through persistence to whatever makes the change visible
   again.

This is what reveals state ownership, dependency direction, the real API boundary, caching, error
handling, and side effects. Without it the rest of the model is decoration.

### Phase 4 — Project model

Write `.claude/project-profile.md` — the evidence ledger. Format and required sections are in
`repository-analysis.md`. Three rules make it worth having:

- **Every claim names its evidence** (files, with paths). A claim without evidence is not a claim.
- **The `Unknown` section is mandatory and must not be empty.** Recording what you could not
  determine is the single most effective anti-hallucination measure here.
- **Record the commit it was verified against, and the evidence paths per section**, so
  `audit-harness` can later re-check only what changed instead of redoing the whole analysis.

The profile is not loaded into context automatically. It exists so that this skill, `audit-harness`,
and a human reviewer can all check the harness against something falsifiable.

### Phase 5 — Install and specialise

**5a. Baseline.** Copy the foundation — agents, skills, `settings.template.json` →
`.claude/settings.json`, `CLAUDE.template.md` → `CLAUDE.md`. Still generic: assume no stack.
On `PARTIAL`/`EXISTING`, apply the merge rules instead of copying over.

**5b. Route every finding to a layer.** This is the most important judgement in the skill, and
`classification-rules.md` is the decision procedure. Never dump findings into `CLAUDE.md` by default:

```text
finding
  ├─ applies to every task, always      → CLAUDE.md (one line)
  ├─ a repeated multi-step procedure    → a project skill
  ├─ a distinct mode of work + tools    → a project agent
  ├─ enforceable at tool-call time      → settings.json
  ├─ detectable by a script             → a validator or hook
  └─ background rationale               → docs/
```

**Only commands verified green** (in CI config, or run successfully here) may enter `settings.json`
`allow`. Never widen `deny`'s gaps to reduce prompting.

### Phase 6 — Verify and gap report

1. Run the project's own verification commands, as recorded in the profile. Real output only.
2. Re-read the written `CLAUDE.md` as if you were a new agent: is every command sourced, every
   claim supported by the profile?
3. **Gap analysis** — against the four roles (`architect`, `implementer`, `reviewer`, `debugger`)
   and seven skills, ask: *what recurring work in this project does the generic harness fail to
   express?* Propose a project-specific skill **only** where you observed the work actually
   recurring in the repository — in scripts, CI steps, docs, or commit history. "Might be nice" is
   not evidence.
4. Report unknowns, assumptions, and everything deliberately not written.

## Validation

The completion criterion is **not** "many files were read". It is that you can explain, each from
repository evidence:

- [ ] One main execution path, end to end, with file references.
- [ ] One data return path, including transforms and caching.
- [ ] State ownership: what owns which state, and who may mutate it.
- [ ] The build, test, and deployment paths.
- [ ] The major dependency boundaries and their direction.
- [ ] The development commands — every one traced to a definition.
- [ ] At least one core domain invariant.
- [ ] What remains `Unknown`, stated explicitly.

And for the harness itself:

- [ ] No file was overwritten without an approved diff.
- [ ] No command in `CLAUDE.md` or `settings.json` that was not verified.
- [ ] Every profile claim carries evidence paths.
- [ ] Each finding sits in the layer that can enforce it, not merely in prose.
- [ ] Proposed project skills are backed by observed recurrence.
- [ ] `bash scripts/validate-harness.sh` passes, if the foundation's validator was installed.

## Failure handling

- **Repository too large to hold** — do not read it all. Follow the evidence priority order, trace
  one representative feature, and record the rest as `Unknown` with the areas not covered. Breadth
  without depth produces a confident, useless model.
- **No CI, no task runner, no documented commands** — write no commands at all. `Unknown` is the
  correct answer; propose asking the owner. A fabricated command is worse than a missing one.
- **`EXISTING` harness conflicts with the foundation** — present both versions and let the user
  decide per file. The existing one usually encodes something learned the hard way.
- **The trace cannot be completed** (generated code, dynamic dispatch, missing service) — report how
  far you got and what blocked it. A partial trace with an honest boundary beats a guessed one.
- **A convention is inconsistent across the codebase** — that is a finding, not a decision for you.
  Report both patterns with counts and ask which is intended.
- **Secrets encountered** — never read `.env` or credential files, and never copy their contents
  into the profile. Record that configuration exists and where, not what it contains.
- **The user asks to skip analysis and just install** — install the baseline, and state plainly that
  the harness is generic and unverified against this repository until specialisation runs.

## Output

```text
Preflight     — state (CLEAN | PARTIAL | EXISTING) and what was found
Repository    — topology, stack, architecture, each with evidence paths
Traces        — the three traces, with file references
Profile       — path to .claude/project-profile.md and the commit it was verified against
Installed     — files created or merged; diffs shown for anything pre-existing
Specialised   — each finding and the layer it was routed to, with the reason
Gaps          — proposed project skills/agents, each with the observed recurrence
Verification  — commands run and their real output
Unknown       — what could not be determined, and what would settle it
Not done      — anything skipped, and why
```

Re-run `audit-harness` periodically: repositories change, and a harness describing last quarter's
architecture actively misleads.

## Supporting files

| File | Loaded for |
| --- | --- |
| `adoption-checklist.md` | Phase 1 survey and merge rules; phase 5a install steps |
| `repository-analysis.md` | Phase 2–4 evidence priority, trace method, profile format |
| `classification-rules.md` | Phase 5b routing decisions |
