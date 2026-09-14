# Architecture

How this repository is laid out, what each layer is responsible for, and the rules that keep the
layers from bleeding into each other.

## Layout

```text
harness-foundation/
├── CLAUDE.md                  always-loaded operating principles
├── README.md                  human entry point
├── .claude/                   Claude Code adapter (canonical definitions)
│   ├── settings.json          permission policy
│   ├── agents/                role definitions + tool grants
│   │   ├── architect.md
│   │   ├── implementer.md
│   │   ├── reviewer.md
│   │   └── debugger.md
│   └── skills/                repeatable procedures
│       ├── plan/SKILL.md
│       ├── implement/SKILL.md
│       ├── review/SKILL.md
│       ├── debug/SKILL.md
│       ├── refactor/SKILL.md
│       ├── test/SKILL.md
│       └── commit/SKILL.md
├── docs/                      design rationale (loaded on demand)
├── templates/                 starting points for adopting projects
├── examples/                  worked adoption walkthrough
└── scripts/validate-harness.sh   structural self-check
```

## The four layers

| Layer | Answers | Lives in | Loaded |
| --- | --- | --- | --- |
| Principles | How should the agent behave, always? | `CLAUDE.md` | Always |
| Roles | Who performs this kind of work, with what tools? | `.claude/agents/` | Description always; body on selection |
| Procedures | How is this task carried out, step by step? | `.claude/skills/` | Description always; body on selection |
| Policy | What is allowed, asked about, or forbidden? | `.claude/settings.json` | Enforced by the runtime |

Rationale sits beside them in `docs/`, and is never loaded automatically.

### Layer rules

- **A principle is one line.** If it needs a procedure, it is a skill; `CLAUDE.md` links to it.
- **An agent describes a role, not a procedure.** `architect.md` says what an architect is
  responsible for and what it may not do; the step-by-step lives in `plan/SKILL.md`. This keeps a
  procedure usable without delegating to a subagent.
- **A skill describes a procedure, not a role.** A skill must be runnable by the main agent as well
  as by a subagent.
- **Policy is not documentation.** Anything in `settings.json` is enforced by the runtime; anything
  enforced only by prose belongs in a skill's constraints.
- **One source of truth.** When an agent and a skill overlap, the skill owns the steps and the agent
  links to it. Duplicated text drifts.
- **Do not rebuild the runtime.** Where the runtime already provides a capability, the harness
  composes over it rather than reimplementing it — `review` delegates the generic pass to the
  built-in `/code-review` and owns only the project layer. A hand-written copy of a built-in freezes
  on the day it was written while the original keeps improving.

## Why `.claude/` is canonical

Claude Code requires agents at `.claude/agents/*.md` and skills at `.claude/skills/<name>/SKILL.md`.
Two designs were possible:

1. Keep vendor-neutral sources in a `harness/` directory and generate `.claude/` from them.
2. Make `.claude/` canonical and keep the *content* vendor-neutral.

This repository uses (2). Generation would need a build step and a sync check, and any drift between
source and generated copy would silently produce two different harnesses. Instead, only the
frontmatter is Claude-specific; every file body is plain Markdown that another runtime can consume
directly. The mapping to other agents is documented in `docs/portability.md`.

Trade-off accepted: adopting this harness for a non-Claude agent requires a mechanical copy step
rather than a build.

## Information flow

```text
User request
   │
   ├─ CLAUDE.md principles ─────────► always in context
   │
   ├─ agent/skill descriptions ─────► selection
   │        │
   │        └─ chosen body loaded ──► procedure followed
   │                 │
   │                 └─ docs/ read only if the task needs rationale
   │
   └─ settings.json ────────────────► every tool call checked by the runtime
```

## Extension points

| You want to | Add | Also update |
| --- | --- | --- |
| A new role | `.claude/agents/<name>.md` from `templates/agent.template.md` | README inventory |
| A new procedure | `.claude/skills/<name>/SKILL.md` from `templates/skill.template.md` | README inventory |
| A new always-on rule | One line in `CLAUDE.md` | — (justify why it must be always-on) |
| New rationale | A file in `docs/` | Link from whatever needs it |
| Project-specific setup | The adopting project's own files, from `templates/` | — |

## Constraints on this repository

- **No build system, package manager, or test runner**, and none should be added without a stated
  reason. The content is Markdown plus one JSON file.
- **No project-specific commands anywhere.** Not in `settings.json`, not in skills, not in
  templates' example text. This harness is applied to projects whose stack it cannot know.
- **`scripts/validate-harness.sh` is the only executable**, deliberately POSIX shell with no runtime
  dependency, so this repository stays stack-free while still having a real verification step.
