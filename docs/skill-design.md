# Skill design

How to write a skill for this harness, and when a repeated prompt has earned promotion.

## What a skill is

A skill is a **repeatable procedure**: the steps for a recurring kind of task, plus how to check the
result and what to do when the check fails. It answers "how is this done here", independently of who
does it.

Skills and agents are orthogonal. A skill can be followed by the main agent or by any subagent; an
agent may use several skills. Keeping them separate is what lets a small task follow the right
procedure without the cost of delegation.

## When to add one

Promote a prompt into a skill when:

- You have given the same instructions three times.
- The task has a right order that is easy to get wrong (validate before reporting, reproduce before
  fixing).
- Getting it wrong is expensive — data loss, silent regressions, false "done" reports.
- The procedure is stable enough to be worth versioning.

Do **not** add a skill for:

- A single-use prompt. Just write the prompt.
- Knowledge rather than procedure — that is `docs/`, or the project's `CLAUDE.md`.
- A role. That is an agent.
- Something the runtime already does well. Check for a built-in first.

## Required structure

Every skill in this repository uses the same seven sections. Uniformity is the point: a reader can
find the failure handling of any skill without reading it top to bottom.

```markdown
---
name: kebab-case-name
description: What the procedure does + when to use it. One or two sentences.
---

# Title

## Purpose           why this exists; the outcome it guarantees
## When to use       triggering situations, and when to skip it
## Inputs            what must be available before starting
## Procedure         ordered, concrete steps
## Validation        a checklist that proves the procedure was followed
## Failure handling  what to do when a step fails — the section that earns the file
## Output            the exact shape of the report
```

### `description`

Always in context; this is the routing key. State the trigger conditions in the user's vocabulary
("when asked to commit", "when something is broken and the cause is unknown", "before any
non-trivial change"). A description that only names the topic will not be selected reliably.

### Procedure

- Ordered steps, imperative mood.
- Each step is an action with an observable result. "Consider the architecture" is not a step;
  "describe the current behaviour of each component you intend to change, with file references" is.
- Put discovery before action. The `test` skill runs discovery first precisely so that no command is
  ever invented.
- Say what *not* to do at the point where the temptation occurs, not in a preamble.

### Validation

A checkbox list that can be answered honestly with yes or no. If an item cannot be checked without
guessing, rewrite it. This section is what converts "I followed the procedure" from a claim into
something inspectable.

### Failure handling

The most valuable section, and the one most often omitted. Cover at least:

- The input is missing or ambiguous.
- A step cannot be completed in this repository (no test runner, no reproduction, no access).
- The result is wrong and the cause is outside the current scope.
- The work turns out larger than the request implied.

The answer is almost never "do your best quietly". It is: report precisely, propose the next step,
and do not disguise the gap.

### Output

A fixed report shape. Always include what was *not* done, what was not verified, and what was
assumed — otherwise reports drift toward listing only successes.

## Naming

- Verb or verb-phrase, kebab-case: `plan`, `implement`, `review`, `debug`.
- The directory name is the skill name and must match the frontmatter `name`.
- **Never take a built-in skill's name.** A local skill that shadows a built-in leaves the user
  unable to tell which one ran. This harness's review skill is named `review` for exactly this
  reason — Claude Code ships `/code-review`, and the two do different jobs.

## Do not reimplement what the runtime already does

Before writing a skill, check whether the runtime already provides it. If it does, the skill's job is
to **compose**, not to duplicate:

```text
built-in capability   +   what only this project knows   =   the skill
```

`review` is the worked example. Generic correctness, edge cases, security, and performance are done
well by the built-in `/code-review`, so the skill delegates that pass and spends its own procedure on
the three things a generic reviewer structurally cannot know: architecture boundaries, project
conventions, and domain rules. It then merges both into one ranked report.

Why this matters beyond tidiness:

- **A duplicate degrades.** A hand-written generic checklist is frozen at the day it was written;
  the built-in improves with the product. The copy silently becomes the worse of the two.
- **Attention is the scarce resource.** Procedure spent re-deriving what is already handled is
  procedure not spent on the project-specific checks nobody else will do.
- **Duplicated findings look like more review than happened.** Two passes reporting the same defect
  inflates the report and buries the findings that are actually new.

When you do compose over a built-in, the skill must still handle its absence: state which runtime
capability it assumes, and give a fallback for runtimes that lack it (see the end of
`.claude/skills/review/SKILL.md`). That is what keeps the composition portable.

## Anti-patterns

| Anti-pattern | Why it fails |
| --- | --- |
| No `Failure handling` | The agent improvises at exactly the moment improvisation is most costly. |
| Validation you cannot answer | Becomes a formality; reports stay green while work degrades. |
| Hardcoded commands (`npm test`) | Wrong in most projects; teaches the agent to invent commands. |
| Skill that is really a role | Cannot be followed without delegating. |
| 400-line skill | Nobody follows step 37; split it or cut it. |
| Vague description | Never selected, or selected for the wrong task. |
| Reimplements a built-in | Freezes a copy that stops improving, and duplicates findings. Compose instead. |
| Shadows a built-in's name | The user cannot tell which one ran. |

## Checklist

- [ ] Directory name matches frontmatter `name`, and does not shadow a built-in skill.
- [ ] Does not duplicate a runtime built-in; composes over it, with a fallback if it is absent.
- [ ] `description` states what *and* when.
- [ ] All seven sections present.
- [ ] Steps are concrete and ordered; discovery precedes action.
- [ ] No project-specific commands, paths, or tools.
- [ ] Validation items are answerable yes/no.
- [ ] Failure handling covers missing input, impossible step, and scope growth.
- [ ] Output includes what was not done.
- [ ] Listed in `README.md`.
- [ ] `bash scripts/validate-harness.sh` passes.
