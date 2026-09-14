# Portability

Claude Code is the first supported runtime. This file records what is genuinely vendor-specific,
what is not, and how to carry the harness to another coding agent.

> Other agents' configuration formats change frequently. Treat the concrete file names below as a
> starting point and verify them against that tool's current documentation before relying on them.
> The conceptual mapping is stable; the file paths are not.

## What is vendor-specific

At the format level, only three things:

| Vendor-specific | Where |
| --- | --- |
| Directory layout (`.claude/agents/`, `.claude/skills/<name>/SKILL.md`) | Fixed by the runtime |
| Frontmatter keys (`name`, `description`, `tools`, `model`) | Fixed by the runtime |
| Permission rule syntax (`Bash(git status:*)`, `Read(./.env)`) | Fixed by the runtime |

One further Claude-specific assumption is deliberate: the `review` skill **composes over** the
built-in `/code-review` rather than reimplementing generic review. That is a capability dependency,
not a format dependency, and the skill carries its own fallback checklist for runtimes that have no
equivalent — see the end of `.claude/skills/review/SKILL.md`. When porting, decide first whether the
target has a generic reviewer: if it does, delegate to it and keep the project layer; if it does not,
the fallback becomes the generic pass.

Everything else — every principle, procedure, checklist, severity scale, and report shape — is plain
Markdown prose with no Claude-specific assumption in it. That is deliberate: porting should be a copy
and a frontmatter rewrite, not a rewrite of the content.

## The portable concepts

| Concept | Purpose | Claude Code | Elsewhere |
| --- | --- | --- | --- |
| Always-on rules | Baseline behaviour | `CLAUDE.md` | `AGENTS.md`; a Cursor always-applied rule; the tool's instruction file |
| Role | Bounded responsibility + tool grant | `.claude/agents/*.md` | A named mode/persona, or a section in the instruction file invoked by name |
| Procedure | Repeatable task steps | `.claude/skills/*/SKILL.md` | A rule/prompt file, a custom command, or a referenced document |
| Policy | What is allowed / asked / denied | `.claude/settings.json` | The tool's approval or sandbox settings |
| Rationale | Why the harness is shaped this way | `docs/` | Unchanged — it is just Markdown |

## Porting checklist

1. **Copy `docs/` and `templates/` as they are.** No changes needed.
2. **Map the always-on rules.** Copy the body of `CLAUDE.md` into the target's instruction file.
   Many tools read a root `AGENTS.md`; where that is the case, a short `AGENTS.md` that points at
   the same content avoids maintaining two copies.
3. **Map the roles.** If the target has no subagent concept, keep the role files as documents and
   invoke them by reference ("act as the reviewer defined in `agents/reviewer.md`"). The procedural
   constraints still apply; the *capability* guardrail does not, so lean harder on the policy layer.
4. **Map the procedures.** Skill bodies transfer unchanged. Replace the frontmatter with whatever the
   target uses for description/trigger metadata; if it has none, reference the files explicitly by
   path in the instruction file.
5. **Re-express the policy.** Permission rule syntax is never portable. Re-derive from intent:
   read-only inspection allowed, consequential actions confirmed, destructive and secret-touching
   actions denied. Do not machine-translate the rule strings.
6. **Re-check the guardrail levels.** Ask, for the new runtime: which limits are enforced by
   capability, which by policy, and which are only prose? Anything that drops to prose-only and
   matters should be compensated elsewhere.

## What to preserve when adapting

If a constraint of the target runtime forces a compromise, preserve these in order of importance:

1. **Verification before completion**, and honest reporting of what was not verified.
2. **Never inventing commands** that the repository does not define.
3. **Minimal, in-scope change.**
4. **Evidence before assertion.**
5. **Separation of implementation from review** — degrade to separate *phases* with a fresh reading
   of the diff if separate agents are unavailable.

Layout, naming, and file format are all negotiable. Those five are the harness.
