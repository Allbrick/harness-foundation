# CLAUDE.md

> **This file is a TEMPLATE, not active guidance** — which is why it is named `CLAUDE.template.md`
> rather than `CLAUDE.md`: a file called `CLAUDE.md` anywhere in a tree can be picked up as real
> instructions, and a template full of placeholders is the last thing that should be.
>
> To use it:
>
> ```bash
> cp templates/CLAUDE.template.md <your-project>/CLAUDE.md
> ```
>
> Then fill in every `<...>` from what the repository actually contains, and delete this blockquote
> along with any section that does not apply. Delete a placeholder rather than guessing at it — an
> empty section is honest, a fabricated command is not.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

<What this project is, in two or three sentences: what it does, who uses it, and what it is not.
Include the one thing a newcomer most often gets wrong.>

## Tech stack

<Language and version, runtime, framework, package manager, database, key third-party services.
Only what is actually present — check the manifest and lockfile, do not infer from folder names.>

## Architecture

<The cross-file structure that cannot be learned by reading a single module:
- the main components and what each owns
- how a request / job / event flows through them
- where state lives, and who is allowed to mutate it
- module boundaries that must not be crossed, and why
- deliberate design decisions that look wrong without their history>

<Keep this to what is non-obvious. Do not list the directory tree; it is discoverable.>

## Commands

<Only commands defined in this repository — in its task runner, manifest scripts, Makefile, or CI
config. Delete any row you cannot point to a definition for.>

| Purpose | Command |
| --- | --- |
| Install dependencies | `<...>` |
| Run locally | `<...>` |
| Build | `<...>` |
| Lint | `<...>` |
| Format | `<...>` |
| Typecheck | `<...>` |
| Test (all) | `<...>` |
| Test (single file) | `<...>` |
| Test (single case) | `<...>` |

<Note any required environment setup — env vars, services that must be running, generated files that
must exist first — and where the values come from. Never inline a secret.>

## Development rules

<Project-specific constraints that override or extend the harness defaults. Examples of the kind of
thing that belongs here:
- code that is generated and must not be edited by hand
- APIs, schemas, or file formats with external consumers
- migration or versioning rules
- performance or compatibility budgets
- areas that require a human decision before being changed>

## Testing

<Framework, where tests live, naming convention, how to run a single test, what must be mocked and
what must not, fixture/factory conventions, and what "adequately tested" means here.>

## Git workflow

<Branch naming, commit message format, whether the default branch is protected, PR expectations,
required checks, who reviews. If Conventional Commits are used, say so; if not, describe what is.>

## Important constraints

<The things that cause real damage when an agent gets them wrong:
- destructive operations that must never run automatically
- files and directories that are off limits
- data, environments, or credentials that must never be touched
- anything that requires explicit human approval before acting>

## Harness

This project uses the [harness-foundation](https://github.com/Allbrick/harness-foundation) harness.
Its operating principles, agents, and skills apply here; the sections above add project-specific
knowledge on top and take precedence where they conflict.
