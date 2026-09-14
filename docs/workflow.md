# Workflow

The order in which work happens, and how much structure to apply to a given task.

## The default pipeline

```text
User Request
    │
    ▼
 Explore      find the relevant code; do not read the whole repository
    │
    ▼
 Understand   state what it does today, and why it is shaped that way
    │
    ▼
 Plan         approach, blast radius, risks, ordered steps
    │
    ▼
 Implement    minimal change in the existing idiom, with tests
    │
    ▼
 Validate     lint / typecheck / test / build, using real commands
    │
    ▼
 Review       generic pass (built-in) + architecture, conventions, domain rules
    │
    ▼
 Report       what changed, what was verified, what was not
```

Each stage hands the next a concrete artifact:

| Stage | Produces | Skill |
| --- | --- | --- |
| Explore | A list of relevant files, with reasons | — |
| Understand | Current behaviour and constraints | — |
| Plan | Ordered steps + blast radius + risks | `plan` |
| Implement | A diff | `implement` |
| Validate | Real command output | `test` |
| Review | Severity-ranked findings | `review` |
| Report | A summary a human can act on | — |

**A stage may not be skipped silently.** Skipping is a decision worth one line in the report:
"no plan — single-line change in a file already read", "not validated — this project has no test
runner".

## Scaling the workflow to the task

Ceremony has a cost. Match the structure to the work:

| Task | Structure |
| --- | --- |
| Typo, comment, one-line fix in a file already read | Implement + validate. Say why planning was skipped. |
| Single-file change with clear intent | Full pipeline, in one turn, no subagents. |
| Multi-file / multi-module change, new subsystem, risky refactor | Explicit role separation across subagents. |
| Bug of unknown cause | Debug pipeline (below) before anything else. |

If you are unsure, do the lighter version and say what you skipped. The user can ask for more.

## Role separation

For substantial work, separate the roles so that no agent grades its own homework:

```text
architect      analysis, design, plan            (no edit tools)
    │
    ▼
implementer    code, tests, validation           (full tools)
    │
    ▼
reviewer       findings, severity, verdict       (no edit tools)
```

For a bug:

```text
debugger       reproduce, evidence, root cause   (no edit tools)
    │
    ▼
implementer    minimal fix + regression test
    │
    ▼
reviewer       verify the fix addresses the cause, not the symptom
```

For a refactor:

```text
architect      define invariants and target structure
    │
    ▼
implementer    transform in small steps (`refactor` skill)
    │
    ▼
reviewer       confirm behaviour is unchanged, diff contains no feature work
```

### Handoff contract

Each handoff is a document, not a vibe. The downstream role must be able to work from it without
re-deriving the upstream analysis, and must **re-read the actual code** rather than trusting the
summary. If an artifact is missing the information the next role needs, that is a defect in the
upstream stage — send it back rather than guessing.

## Feedback loops

The pipeline is not one-way:

- **Validation fails** -> back to Implement; if the cause is unclear, to the debug pipeline.
- **Review returns `blocker` or `major`** -> back to Implement, then re-review.
- **Implementation contradicts the plan** -> back to Plan. Do not redesign inside the editor.
- **The change outgrows its plan** -> stop, report the new blast radius, re-plan.

A loop that runs more than twice on the same point is a signal that the problem is upstream —
usually an unclear requirement. Stop and ask.

## Reporting

Every completed task ends with, at minimum:

```text
What changed      files and the reason for each
How it was verified  commands run and their real results
What was not done  skipped stages, deferred findings, known gaps
Assumptions       anything decided without confirmation
```

The last two lines are the ones that matter most. A report that lists only successes is not a
report.
