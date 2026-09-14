# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

`harness-foundation` is a **harness** for AI coding agents, not an application. Its deliverables are
the operating rules, agent roles, skills, and templates that other projects copy and adapt. Claude
Code is the first supported runtime; the underlying concepts are kept portable to other agents (see
`docs/portability.md`).

Because the harness *is* the product, a change here changes agent behaviour in every project that
adopted it. Review these files with the same rigour you would apply to code.

## Operating principles

These apply to work in this repository and to work in any repository that adopts this harness.

1. **Evidence over assumption.** Read the actual files, config, and history before concluding
   anything. "The project probably uses X" is not a finding.
2. **Understand before changing.** Identify what the existing code does and why it is shaped that
   way before altering it.
3. **Know the blast radius.** Before editing, find every caller, test, and document affected.
4. **Minimal change.** Change the smallest surface that solves the stated problem. Leave unrelated
   code alone even when it is imperfect.
5. **Preserve existing behaviour.** Do not alter public behaviour, signatures, or output formats
   that were not part of the request.
6. **Plan before implementing.** For anything beyond a trivial edit, produce a plan of files,
   changes, and risks first.
7. **Verification before completion.** Unverified code is not done. Run whatever the project
   actually provides — lint, typecheck, tests, build — and review the diff. If nothing can be run,
   say so explicitly instead of implying success.
8. **Never invent commands.** Do not guess build/test/lint commands, scripts, or file paths. If the
   command is not discoverable in the repository, report that it is missing.
9. **Prefer the skill.** When a skill covers the task (`plan`, `implement`, `review`, `debug`,
   `refactor`, `test`, `commit`), follow it instead of improvising a procedure.
10. **Separate responsibilities.** Keep architecture, implementation, and review distinct — across
    subagents when the task is large, across phases when it is not. Do not let the author of a
    change be its only reviewer.
11. **Report failure honestly.** Surface failing tests, skipped steps, unresolved errors, and
    assumptions you had to make. Never present a partial result as complete.
12. **No unrequested refactoring.** Large-scale restructuring, renaming, dependency changes, and
    reformatting require explicit user approval.

## Where things live

Load only what the current task needs — see `docs/harness-engineering.md#progressive-disclosure`.

| Path | Holds | Read it when |
| --- | --- | --- |
| `CLAUDE.md` | Always-loaded baseline rules | Always (this file) |
| `.claude/agents/*.md` | Role definitions and their tool grants | Delegating to a specialised role |
| `.claude/skills/*/SKILL.md` | Repeatable procedures | Performing that kind of task |
| `.claude/settings.json` | Permission policy | Changing tool safety rules |
| `docs/` | Design rationale | Changing the harness itself |
| `templates/` | Starting points for new projects/agents/skills | Bootstrapping or extending |
| `examples/` | Worked adoption walkthrough | Applying the harness elsewhere |

## Working in this repository

- There is **no package manager, build system, or test runner here**, and none should be added
  without a stated reason. The content is Markdown plus one JSON policy file.
- Validation command (POSIX shell; Git Bash on Windows):

  ```bash
  bash scripts/validate-harness.sh
  ```

  It checks required files, skill/agent frontmatter, `settings.json` shape, and intra-repo links.
  Run it before reporting any change to this repository as complete.
- When adding an agent or skill, start from `templates/agent.template.md` or
  `templates/skill.template.md` so structure stays uniform, and update `README.md`'s inventory.
- Keep `CLAUDE.md` short. Detailed procedure belongs in a skill; rationale belongs in `docs/`.
