# Harness engineering

The design philosophy behind this repository. Read this if you are changing the harness, adapting it
to another agent runtime, or deciding whether a new rule belongs in `CLAUDE.md`, an agent, a skill,
or here.

---

## Prompt vs harness

A **prompt** is an instruction you give once. A **harness** is the structure around the model that
makes good behaviour the default, repeatedly, without the user having to ask for it.

| | Prompt | Harness |
| --- | --- | --- |
| Lifetime | One turn | Persistent across sessions and projects |
| Author | Whoever is typing | The team, versioned in the repository |
| Reliability | Depends on remembering to say it | Structural — it applies whether or not anyone remembers |
| Failure mode | Forgot to include the constraint | Constraint is wrong, and can be fixed once |
| Reviewable | No | Yes, as a diff |

The distinction matters because "the agent did something reckless" is almost never fixed by writing
a better one-off prompt. It is fixed by making the reckless action harder to reach: removing the
tool from the role, adding a deny rule, or making the procedure require evidence before action.

A harness has four kinds of component:

1. **Context** — what the agent knows, and when it knows it.
2. **Roles** — who does what, and with which tools.
3. **Procedures** — how a recurring task is carried out.
4. **Guardrails** — what cannot happen, regardless of instructions.

Everything in this repository is one of those four.

---

## Context engineering

The model's context window is a budget, not a storage location. Every token of standing instruction
competes with the code the agent actually needs to read, and instructions that are always present
but rarely relevant are worse than absent: they dilute attention and get ignored, which teaches the
agent that rules in that file are optional.

Principles used here:

- **Small always-on core.** `CLAUDE.md` holds only rules that apply to every task. It is a dozen
  principles, not a manual.
- **Load procedure on demand.** A skill body is read when the task matches, not before.
- **Reference, do not inline.** `docs/` explains *why*; agents and skills link to it rather than
  repeating it. One source of truth per fact.
- **Description is an index entry.** An agent's or skill's `description` is what the model sees when
  deciding what to load. It must state *when to use this*, not just what it is.

---

## Progressive disclosure

The concrete layering:

```text
CLAUDE.md              always loaded         minimal rules that apply to every task
agent description      always loaded         enough to choose a role
skill description      always loaded         enough to choose a procedure
agent / SKILL.md body  loaded on selection   the full procedure for this task
docs/                  loaded on demand      rationale, design, adaptation
```

The rule of thumb: **information should be loaded at the moment it changes a decision, and not
before.** If a paragraph would not change what the agent does on this task, it does not belong in
the always-on layer.

A corollary that is easy to get wrong: making a rule *more prominent* is not the same as making it
*more effective*. If an agent keeps skipping validation, moving the rule into `CLAUDE.md` in bold
helps less than putting a validation checklist at the end of the procedure it is already following.

---

## Agent specialization

One agent with every tool and every responsibility is worse than several with clear boundaries, for
three reasons:

1. **Attention.** A role description that covers analysis, implementation, and review gives the model
   no strong signal about what to prioritise right now.
2. **Independence.** An agent that just wrote code is a poor judge of that code. A separate reviewer
   with no authorship history evaluates the result rather than defending it.
3. **Capability as a guardrail.** The architect, reviewer, and debugger in this harness have no
   file-editing tools. That is not an instruction they might override under pressure — it is a
   capability they do not have. "Cannot" beats "should not".

The four roles map onto the distinct modes of software work: understand (`architect`), change
(`implementer`), evaluate (`reviewer`), and diagnose (`debugger`). See `docs/agent-design.md`.

---

## Workflow orchestration

Roles are useful only if there is a defined order in which they act. The default pipeline is:

```text
Explore -> Understand -> Plan -> Implement -> Validate -> Review -> Report
```

Each stage produces an artifact the next one consumes — a map, a plan, a diff, a test result, a
findings list. This has two benefits: the handoff is inspectable by a human at any point, and a
failure is attributable to a stage rather than to "the agent".

Orchestration is proportional. A one-line fix runs the pipeline implicitly in a single turn;
a multi-module feature runs it explicitly across subagents. Over-orchestrating small work is its own
failure mode — it burns context and hides a trivial change inside ceremony. See `docs/workflow.md`.

---

## Verification loop

The central claim of this harness: **code that has not been verified is not finished, and saying it
is finished is the most damaging thing an agent can do.** An incorrect change costs an hour; an
incorrect change reported as verified costs trust in every subsequent report.

So every procedure in this repository ends with an explicit `Validation` section, and every one has
a `Failure handling` section that says what to do when validation fails. The two rules that matter
most:

- **Run what exists; never invent a command.** A fabricated `npm test` that was never run produces a
  confident report about nothing. The `test` skill therefore begins with discovery, not execution.
- **Never make the check pass by weakening the check.** Deleting a failing test, loosening an
  assertion, or bypassing a hook converts a visible problem into an invisible one.

When nothing can be verified — no tests exist, the environment is unavailable — the requirement is
not to fake it but to *say so*, precisely, in the report.

---

## Guardrails

Guardrails are limits that hold regardless of what the conversation asks for. This harness places
them at three levels:

| Level | Mechanism | Example |
| --- | --- | --- |
| Capability | Tool grants in agent frontmatter | `reviewer` has no `Edit` tool |
| Policy | `deny` rules in `.claude/settings.json` | `Read(./.env)`, `Bash(git push --force:*)` |
| Procedure | Explicit constraints in skills | "Never delete a failing test to get a green run" |

They are deliberately redundant. Procedural rules are the weakest — they can be argued out of — and
capability limits are the strongest. Anything genuinely dangerous should be blocked at the capability
or policy level, with the procedural rule present only as an explanation.

Guardrails also have a cost: a policy that denies too much produces constant prompting, and a user
who clicks through prompts reflexively has no guardrail at all. Deny what is destructive or
confidential; allow what is read-only; ask about what is consequential but normal. See
`.claude/settings.json`.

---

## Reproducibility

The same request, made twice, should produce work of the same shape. Not identical text — models are
not deterministic — but the same steps, the same checks, and the same report structure.

This is what makes agent work reviewable. When every implementation report has the same sections, a
reviewer can spot a missing validation line immediately. When the procedure lives in a versioned
file, a bad outcome can be traced to a rule and the rule can be fixed.

Three practices support it:

- **Fixed output shapes.** Each skill defines its report format.
- **Explicit inputs.** Each skill names what it needs, so a missing input is visible rather than
  silently assumed.
- **Promote repeated prompts into skills.** If you have corrected the agent the same way three
  times, that correction belongs in a skill, not in your typing.

---

## Applying this to a new harness

When you extend this repository or adapt it for a project, ask in order:

1. **Is this always relevant?** Yes -> `CLAUDE.md`, one line. No -> keep going.
2. **Is it about *who* does the work?** Yes -> an agent.
3. **Is it a repeatable *procedure*?** Yes -> a skill.
4. **Is it a limit that must hold regardless?** Yes -> a tool grant or a permission rule.
5. **Is it rationale?** Yes -> `docs/`.

If a rule fits nowhere, it is usually project-specific knowledge: it belongs in the adopting
project's own `CLAUDE.md`, built from `templates/CLAUDE.template.md`.
