# Repository analysis

Loaded for phases 2–4 of `adopt-harness`. Defines what evidence to gather, in what order, when to
stop, and the format of the project profile.

## The governing rule

**Read to answer a question, not to cover the repository.** A large codebase cannot be held in
context and does not need to be. You are reconstructing a model good enough to make development
judgements — not producing a summary of every file.

Stop when the completion criteria in `SKILL.md` are met. Everything not covered goes in `Unknown`.

## Evidence priority

Work down this list. Each tier narrows where to look in the next; skipping ahead means guessing.

### 1. Topology — what kind of repository is this?

Look for: the VCS root and its history shape, workspace/monorepo manifests, package and project
manifests, lockfiles, language/compiler configuration, container and orchestration files, and the
top-level source directories.

Produce: is it single-package or a workspace? Which unit is the primary deliverable? What are the
other units and how do they relate? What language(s) and toolchain?

> A lockfile identifies the package manager authoritatively. The presence of a directory named
> `apps/` does not.

### 2. Build and runtime evidence

Look for: manifest script/task sections, `Makefile`/`Justfile`/`Taskfile`, `scripts/`, CI workflow
files, container build stages, and contributor docs.

Produce: how it is built, run locally, and packaged. **CI is the most reliable source** — those
commands are known to have run green.

Record each command *with the file that defines it*. A command you cannot trace does not exist.

### 3. Architecture evidence

Look for: the entry point(s), the directory layout *inside* the primary unit, dependency/import
configuration (path aliases, module boundaries, visibility rules), lint rules that constrain
imports, and any architecture documentation — treated as a claim to verify, not as truth.

Produce: the named layers or modules, what each owns, and the direction dependencies are supposed to
flow.

> Architecture docs go stale faster than code. When the doc and the imports disagree, the imports
> are the evidence and the disagreement is a finding.

### 4. Flow — see `Tracing` below

The tier that converts a folder listing into understanding. Mandatory.

### 5. Development workflow

Look for: branch names in history, commit message shapes (`git log --oneline -40`), PR/issue
templates, `CONTRIBUTING`, code owners, review requirements, hooks configuration.

Produce: how work actually enters this repository.

### 6. Verification workflow

Look for: test directories and their internal conventions, test configuration, coverage settings,
the CI job list, and any linter/type-checker/formatter configuration.

Produce: what "verified" means here — which commands, which gates are mandatory, what is expected of
a new test, and what is deliberately not tested.

### 7. Deployment and runtime

Look for: deployment workflows, environment configuration *names* (never values), infrastructure
definitions, migration tooling, feature flags, observability setup.

Produce: where this runs and what a mistake would affect. This feeds the "Important constraints"
section, which is the part of a project `CLAUDE.md` that prevents damage.

### 8. Domain invariants

Look for: validation logic, permission checks, schema constraints, unit/currency/timezone handling,
tenancy or isolation rules, audit trails, and generated files marked do-not-edit.

Produce: the rules that make a change *wrong in this project* even when the code compiles and the
tests pass. These are the most valuable findings and the hardest to recover later.

## Tracing

Three traces, each with `file:line` references at every hop. Pick one representative feature —
ideally one that is neither the simplest nor the most exotic.

```text
1. Execution path     user action ──► ... ──► system boundary (HTTP / DB / queue / disk)
2. Return path        boundary ──► transform ──► cache ──► what the user sees
3. Mutation cycle     change ──► persist ──► invalidate/refresh ──► visible again
```

What each trace is actually for:

| Trace | Reveals |
| --- | --- |
| Execution | Real call structure, where the abstraction boundaries are, which layers are ceremony |
| Return | Where data is reshaped, what is cached and for how long, how errors surface |
| Mutation | State ownership, consistency strategy, side effects, what invalidates what |

**Do not infer the trace from naming.** Open each file and confirm the next hop. If a hop is dynamic
(DI container, event bus, code generation, reflection), say so and record the boundary — that is a
real property of the architecture, not a failure.

## Project profile format

Write to `.claude/project-profile.md` in the target repository. It is committed: it is shared
knowledge and the baseline that `audit-harness` compares against.

```markdown
# Project profile

Verified against commit: <sha>            <!-- what the claims below were checked against -->
Produced by: adopt-harness

## Repository
<topology: workspace layout, primary deliverable, units and their relationship>
Evidence: <paths>

## Stack
<languages, runtimes, frameworks, package manager — versions where they matter>
Evidence: <paths>

## Architecture
<layers/modules, what each owns, intended dependency direction, boundaries that must hold>
Evidence: <paths>

## Flow
### Execution path
<hop ──► hop ──► hop, with file:line>
### Return path
<...>
### Mutation cycle
<...>

## State ownership
<what owns which state; who may mutate it; how it is invalidated>
Evidence: <paths>

## Verification
<commands, each traced to its definition; what is gated in CI; what "tested" means here>
Evidence: <paths>

## Development workflow
<branching, commit convention, review requirements>
Evidence: <paths>

## Domain invariants
<rules that make a change wrong even when it compiles>
Evidence: <paths>

## Unknown
<what could not be determined, and what would settle it — MUST NOT be empty>

<!-- audit:evidence
repository: <paths>
stack: <paths>
architecture: <paths>
flow: <paths>
state: <paths>
verification: <paths>
workflow: <paths>
invariants: <paths>
-->
```

### Why the trailing evidence block

`audit-harness` reads it and runs `git diff <profile-commit>..HEAD -- <paths>` per section. Only
sections whose evidence actually changed get re-verified. Without it, every audit is a full
re-analysis, which means audits stop happening.

Keep the paths in that block to the files that would *change the claim* if edited — usually 3–10 per
section, not every file read.

## Evidence discipline

| Write this | Not this |
| --- | --- |
| "pnpm workspace — `pnpm-workspace.yaml`, `pnpm-lock.yaml`" | "It is a pnpm monorepo" |
| "`<command>`, defined in `.github/workflows/ci.yml:24`" | "Tests are run with `<command>`" |
| "Server state is owned by the query cache — `src/api/client.ts:40`" | "It uses a standard data-fetching setup" |
| "Unknown: how sessions are invalidated; no auth module found under `src/`" | *silence* |

Three habits that keep the profile honest:

1. **Quote the path, always.** If you cannot name the file, you are inferring — mark it as inference
   or drop it.
2. **Separate observed from inferred.** Both are useful; conflating them is what produces confident
   wrong answers three weeks later.
3. **Never read secrets.** `.env`, key material, and credential files are denied by policy. Record
   that configuration exists and which keys are referenced in code — never values.
