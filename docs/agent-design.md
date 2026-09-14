# Agent design

How to write a subagent for this harness, and when a new one is warranted.

## What an agent is

An agent is a **role**: a bounded responsibility plus the tools needed to fulfil it and nothing more.
It answers "who should do this kind of work, and what are they allowed to do".

An agent is *not* a procedure. The steps for planning live in `plan/SKILL.md`, not in
`architect.md` — so that the main agent can follow the procedure without delegating. The agent file
says what the role is accountable for, how it approaches problems, what it must not do, and what it
hands back.

## When to add one

Add an agent when **all** of these hold:

- The work is a genuinely distinct mode of thinking (analysing, changing, evaluating, diagnosing).
- It benefits from a different tool grant — usually a narrower one.
- Independence has value: you want this work judged by something that did not produce it.
- It recurs. A one-off does not need a role.

Do **not** add an agent for:

- A procedure with the same tools as an existing role — write a skill.
- A technology ("the React agent"). Stack knowledge belongs in the project's `CLAUDE.md`.
- A phase that is only ever run as part of another role's work.

Four roles cover most software work. Prefer sharpening an existing one over adding a fifth.

## File format

```markdown
---
name: kebab-case-name
description: What this role does + when to invoke it. Written for the selector, in third person.
tools: Read, Grep, Glob, Bash
model: inherit
---

# Role name

One sentence on what this role is for, and what it deliberately does not do.

## Responsibilities
## Method
## Constraints
## Output
```

### `description`

This is the only part of the file that is always in context. It is a routing key: it must say
**when** to use the role, not just what it is. Include the triggering situations in the words a user
would use ("before any non-trivial change", "after an implementation is complete", "when something
is broken and the cause is unknown"), and state what it does not do.

### `tools`

The strongest guardrail available. Grant the minimum:

| Role | Grant | Why |
| --- | --- | --- |
| `architect` | `Read, Grep, Glob, Bash, WebSearch, WebFetch` | Must read widely; must not edit. |
| `implementer` | `Read, Write, Edit, Grep, Glob, Bash, TodoWrite` | The only role that changes files. |
| `reviewer` | `Read, Grep, Glob, Bash` | Independence requires it cannot rewrite what it judges. |
| `debugger` | `Read, Grep, Glob, Bash` | Prevents fix-by-trial-and-error. |

Omitting `Write` and `Edit` is what makes "analysis only" real instead of aspirational. Note that
`Bash` is a broad grant — a read-only role can still write files through a shell. That gap is closed
by the procedural constraint in the agent body and by `deny` rules in `.claude/settings.json`; be
aware of it when granting `Bash` to a role you intend to be read-only.

### `model`

Use `inherit` unless the role has a specific reason to differ. Pinning a model in a reusable harness
ages badly.

## Writing the body

- **Be specific to the role.** "Be careful" and "write good code" apply to everything and therefore
  guide nothing. "Enumerate the blast radius explicitly; an unlisted file is a claim that it is
  unaffected" guides something.
- **State the failure mode you are preventing.** A constraint with a reason survives pressure; a bare
  prohibition gets rationalised away.
- **Define the output shape.** The next role in the pipeline consumes it; a fixed shape makes a
  missing section visible.
- **Keep it under roughly 100 lines.** Longer means procedure has crept in — move it to a skill.
- **Link rather than repeat.** Point at the skill and at `docs/`.

## Anti-patterns

| Anti-pattern | Why it fails |
| --- | --- |
| The do-everything agent | No routing signal; no independence; every tool granted. |
| Role that duplicates its skill verbatim | Two copies drift; the reader cannot tell which wins. |
| Read-only role granted `Edit` "just in case" | The guardrail is now advisory. |
| Description that only says what it is | The selector cannot tell when to use it. |
| Pinned model / hardcoded paths | Not portable to the next project. |

## Checklist

- [ ] `name` is kebab-case and matches the filename.
- [ ] `description` states when to invoke, and what the role does not do.
- [ ] `tools` is the minimum the role needs.
- [ ] The body has Responsibilities, Method, Constraints, Output.
- [ ] Constraints explain the failure they prevent.
- [ ] No procedure duplicated from a skill — linked instead.
- [ ] The role is listed in `README.md`.
- [ ] `bash scripts/validate-harness.sh` passes.
