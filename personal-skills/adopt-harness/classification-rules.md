# Classification rules

Loaded for phase 5b of `adopt-harness`. Decides **where each finding goes**.

This is the judgement that determines whether adoption produced a harness or just more documentation.
Everything routed to prose is advisory; only some layers can actually enforce anything.

## The decision procedure

Ask in this order, and stop at the first yes.

```text
1. Can the runtime block it at tool-call time?      → settings.json
2. Can a script detect a violation?                 → validator / hook
3. Is it a distinct mode of work needing its own
   tool grant and independence?                     → a project agent
4. Is it a multi-step procedure that recurs?        → a project skill
5. Does it apply to EVERY task, regardless of
   what is being built?                             → CLAUDE.md, one line
6. Is it background rationale a task rarely needs?  → docs/
7. None of the above                                → leave it out
```

The order is deliberate: **enforcement beats instruction.** A rule that the runtime denies cannot be
argued out of; the same rule as a sentence in `CLAUDE.md` competes for attention with everything else
in the file. Prose is the fallback, not the default.

Step 7 is real. A finding that is discoverable by reading one file — a function's signature, a
directory's contents — should not be written down anywhere. It costs context on every task and goes
stale on its own.

## Worked examples

| Finding | Layer | Why |
| --- | --- | --- |
| "Only one package manager is used here; the others must not be" | `settings.json` deny + one `CLAUDE.md` line | Denial makes the mistake impossible; the line explains it |
| "Lint, typecheck, test and build are these commands, green in CI" | `settings.json` allow | Verified commands, so validation stops prompting |
| "Connecting a new API endpoint is always the same 8 steps" | a project skill | A recurring procedure with a right order |
| "This directory is generated; never hand-edit it" | `settings.json` deny on the path + `CLAUDE.md` constraint | Enforceable, and expensive to get wrong |
| "Imports must not cross from the domain layer into the UI layer" | validator or lint rule, if one exists; otherwise `CLAUDE.md` | Mechanically checkable — prefer the check |
| "Money is stored in minor units as integers" | `CLAUDE.md` — Important constraints | Applies to every change touching money; silently wrong otherwise |
| "The cache is invalidated by key prefix, for historical reasons" | `docs/` | Background; needed only when touching caching |
| "This module handles the legacy import format" | nowhere | Discoverable by opening the module |

## Layer-specific rules

### `settings.json`

- **Allow only verified commands.** A command enters `allow` when it is defined in the repository
  *and* known to run green — in CI, or because it was run successfully during adoption. Nothing else.
- Use the narrowest prefix that covers real usage; `Bash(...)` rules match by prefix and grant more
  than they appear to.
- **Never loosen `deny` to reduce prompting.** If a deny rule blocks legitimate work, narrow it
  deliberately and say so in the report — do not delete it.
- Add project-specific denials for paths that must never be touched: generated output, migration
  history, production configuration, vendored code.

### A project skill

Create one only when **all** hold:

- The procedure was observed recurring — in scripts, CI steps, docs, or commit history. Not
  "this seems like it would come up".
- It has a right order that is easy to get wrong.
- The generic seven skills cannot express it well.
- It is stable enough to be worth versioning.

Follow `templates/skill.template.md`: all seven sections, `Failure handling` included. If the
runtime or the generic harness already does most of the job, **compose over it** rather than
reimplementing — the same rule that makes the foundation's `review` skill delegate its generic pass.

### A project agent

The highest bar. Four roles already cover understand / change / evaluate / diagnose. Add one only
when the work is a genuinely distinct mode of thinking **and** wants a different tool grant — most
often a narrower one. A role per technology ("the frontend agent") degrades routing and is the most
common way an adopted harness decays.

### `CLAUDE.md`

- One line per rule. If it needs a procedure, it is a skill, and `CLAUDE.md` links to it.
- It must survive the question *"does this change what the agent does on a task that has nothing to
  do with it?"* If no, it does not belong in the always-on layer.
- Commands only if traced to a definition. Delete any row you cannot source.
- Target: the project sections of `templates/CLAUDE.template.md`, filled from the profile. Keep it
  short — every line competes with the code the agent needs to read.

### `docs/` and `project-profile.md`

Rationale, history, and the detailed model. Not loaded automatically, so length is cheap here and
expensive everywhere else. When a `CLAUDE.md` line needs three paragraphs of justification, the line
stays and the paragraphs move here.

## Anti-patterns

| Anti-pattern | Consequence |
| --- | --- |
| Pasting the whole profile into `CLAUDE.md` | Always-on context bloats; the rules that matter get diluted and ignored |
| Writing a rule as prose when the runtime could deny it | The guardrail is advisory exactly where it needed to be absolute |
| Creating skills for work not yet observed | The harness grows without getting more useful; selection degrades |
| Recording a command that was never run | Teaches the agent that guessing commands is acceptable |
| Adding an agent per technology | Roles stop being distinct modes of work |
| Writing what one file already shows | Context cost on every task, and it goes stale alone |

## Report format for this phase

For every finding, one line:

```text
<finding> → <layer> : <why this layer> [evidence: <path>]
```

And explicitly list findings **deliberately not written down**, with the reason. That list is
evidence of judgement; its absence usually means everything was dumped into `CLAUDE.md`.
