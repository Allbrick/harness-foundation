# harness-foundation

A reusable **harness** for AI coding agents: the operating principles, roles, procedures, and safety
policy that make agent-assisted development repeatable across projects.

Claude Code is the first supported runtime. The content is deliberately vendor-neutral so it can be
carried to other agents — see [`docs/portability.md`](docs/portability.md).

---

## What is harness engineering?

A **prompt** is something you type once. A **harness** is the structure around the model that makes
good behaviour the default without anyone having to ask for it: what the agent knows and when, who
does which kind of work, how a recurring task is carried out, and what is simply not permitted.

The distinction matters because most bad agent outcomes are not fixed by better wording. They are
fixed structurally — by removing a tool from a role, adding a deny rule, or making a procedure
require evidence before action. A harness is versioned, reviewable as a diff, and improves over time;
a prompt is none of those things.

Full rationale: [`docs/harness-engineering.md`](docs/harness-engineering.md).

## The problem this repository solves

Working with a coding agent without a harness produces a familiar set of failures:

| Failure | What the harness does about it |
| --- | --- |
| Reports work as done without running anything | Every procedure ends with a validation checklist; every report must state what was *not* verified |
| Invents `npm test`-style commands that do not exist | The `test` skill starts with discovery; "never invent a command" is a standing rule |
| Edits far beyond what was asked | Minimal-change principle; plan-first with an explicit blast radius |
| Reviews its own work and approves it | `reviewer` and `architect` have no file-editing tools |
| Fixes bugs by changing code until the symptom disappears | `debugger` has no editing tools and follows an evidence-and-hypothesis procedure |
| Same corrections retyped every session | Repeated corrections get promoted into skills |
| Runs something destructive | Deny rules for destructive commands and secret files |

## Quick start with Claude Code

```bash
git clone https://github.com/Allbrick/harness-foundation.git
```

To work **on** the harness, open this repository — `CLAUDE.md`, the agents, and the skills load
automatically. To **use** it in another project, see [Applying it to a project](#applying-it-to-a-project).

Once installed in a project:

| You want to | Do this |
| --- | --- |
| Plan a change | Invoke the `plan` skill, or the `architect` agent for larger work |
| Implement an approved plan | `implement` skill, or the `implementer` agent |
| Review a diff | `review` skill, or the `reviewer` agent |
| Diagnose a bug | `debug` skill, or the `debugger` agent |
| Restructure without behaviour change | `refactor` skill |
| Run or write tests | `test` skill |
| Commit | `commit` skill |

Verify the harness itself at any time:

```bash
bash scripts/validate-harness.sh
```

## CLAUDE.md vs agents vs skills vs settings

The four layers do different jobs, and mixing them is the most common way a harness goes wrong:

| Layer | Answers | Lives in | Loaded |
| --- | --- | --- | --- |
| **Principles** | How should the agent behave, always? | `CLAUDE.md` | Always in context |
| **Agents** | *Who* does this kind of work, with which tools? | `.claude/agents/` | Description always; body when selected |
| **Skills** | *How* is this task carried out, step by step? | `.claude/skills/` | Description always; body when selected |
| **Settings** | What is allowed, asked about, or forbidden? | `.claude/settings.json` | Enforced by the runtime on every tool call |

Rules of thumb:

- Always relevant and one line long -> `CLAUDE.md`.
- About responsibility and capability -> an **agent**.
- A repeatable sequence of steps -> a **skill**.
- Must hold no matter what the conversation says -> **settings**, or a narrower tool grant.
- Explains *why* -> [`docs/`](docs/), loaded only on demand.
- Already provided by the runtime -> **do not rebuild it**; compose over it (see
  [`docs/skill-design.md`](docs/skill-design.md#do-not-reimplement-what-the-runtime-already-does)).

This layering is [progressive disclosure](docs/harness-engineering.md#progressive-disclosure):
context is spent on what changes the current decision, not on everything that might matter someday.

## Inventory

### Agents — [`docs/agent-design.md`](docs/agent-design.md)

| Agent | Responsibility | Can edit files? |
| --- | --- | --- |
| [`architect`](.claude/agents/architect.md) | Requirements, codebase analysis, blast radius, design, plan | No |
| [`implementer`](.claude/agents/implementer.md) | Executes an approved plan; tests; validates | Yes |
| [`reviewer`](.claude/agents/reviewer.md) | Owns the merge verdict: delegates the generic pass, adds the project layer | No |
| [`debugger`](.claude/agents/debugger.md) | Reproduction, evidence, hypothesis, root cause, minimal fix | No |

### Skills — [`docs/skill-design.md`](docs/skill-design.md)

| Skill | Procedure |
| --- | --- |
| [`plan`](.claude/skills/plan/SKILL.md) | Requirement → relevant code → architecture → blast radius → risks → ordered steps |
| [`implement`](.claude/skills/implement/SKILL.md) | Re-read → minimal change in the local idiom → tests → validate → diff review |
| [`review`](.claude/skills/review/SKILL.md) | Delegates the generic pass to the built-in `/code-review`, then adds architecture boundaries, project conventions, and domain rules |
| [`debug`](.claude/skills/debug/SKILL.md) | Symptom → reproduction → evidence → hypothesis → root cause → minimal fix → regression test |
| [`refactor`](.claude/skills/refactor/SKILL.md) | Structure change with behaviour held constant and equivalence proven |
| [`test`](.claude/skills/test/SKILL.md) | Discover the real test setup first; never invent a command |
| [`commit`](.claude/skills/commit/SKILL.md) | Diff analysis, logical grouping, Conventional Commits |

### Workflow — [`docs/workflow.md`](docs/workflow.md)

```text
Explore → Understand → Plan → Implement → Validate → Review → Report
```

Scaled to the task: a one-line fix runs it implicitly in a single turn; a multi-module change runs it
across separate agents (`architect → implementer → reviewer`, or `debugger → implementer → reviewer`
for a bug). A stage may be skipped — but never silently.

## Applying it to a project

```bash
cd <your-project>
mkdir -p .claude
cp -r <path-to>/harness-foundation/.claude/agents .claude/agents
cp -r <path-to>/harness-foundation/.claude/skills .claude/skills
cp    <path-to>/harness-foundation/templates/settings.template.json .claude/settings.json
cp    <path-to>/harness-foundation/templates/CLAUDE.template.md CLAUDE.md   # then fill it in
```

Then fill in `CLAUDE.md` **from evidence in that repository** — stack from the manifest, commands
from the task runner or CI config, architecture from following one request end to end. Delete any
placeholder you cannot source; a fabricated command is worse than a missing one.

Finally, add the project's real verification commands to `allow` in `.claude/settings.json` so
validation does not prompt on every run.

Walkthrough, including what "good" looks like at each stage:
[`examples/adopting-an-existing-project.md`](examples/adopting-an-existing-project.md).

## Adding an agent

1. Read [`docs/agent-design.md`](docs/agent-design.md) — in particular, when a new role is *not*
   warranted (most of the time, the answer is a skill).
2. Copy [`templates/agent.template.md`](templates/agent.template.md) to `.claude/agents/<name>.md`.
3. Write a `description` that says **when** to use the role; grant the **minimum** `tools`.
4. Add it to the inventory above and run `bash scripts/validate-harness.sh`.

## Adding a skill

1. Read [`docs/skill-design.md`](docs/skill-design.md). Promote a prompt into a skill once you have
   typed it three times — and **check for a built-in first**. If the runtime already does part of the
   job, the skill composes over it instead of reimplementing it; `review` is the worked example.
2. Copy [`templates/skill.template.md`](templates/skill.template.md) to
   `.claude/skills/<name>/SKILL.md`.
3. Fill in all seven sections — `Failure handling` is the one that earns the file.
4. Add it to the inventory above and run `bash scripts/validate-harness.sh`.

## Customising for a project

| Need | Where it goes |
| --- | --- |
| Stack, commands, architecture, constraints | The project's own `CLAUDE.md`, from the template |
| A procedure specific to this codebase | A new skill in that project's `.claude/skills/` |
| A domain-specific role | A new agent in that project's `.claude/agents/` |
| Allowing the project's verification commands | `allow` in that project's `.claude/settings.json` |
| Changing a harness-wide default | This repository, so every project inherits it |

Two rules keep adoption from decaying: **never loosen `deny`** to stop prompts, and **never put
project-specific commands in the harness** — they belong to the project, and baking one in here
teaches the agent that guessing commands is acceptable.

## Repository contents

```text
CLAUDE.md            always-loaded operating principles
.claude/             agents, skills, permission policy (canonical definitions)
docs/                design rationale — loaded on demand, not automatically
templates/           starting points for projects, agents, and skills
examples/            worked adoption walkthrough
scripts/             dependency-free structural self-check
```

This repository has no package manager, build system, or test runner, and does not need one: its
content is Markdown plus one JSON policy file. See
[`docs/architecture.md`](docs/architecture.md).
