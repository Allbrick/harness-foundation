---
name: <kebab-case-name>
description: <What the procedure does, and WHEN to use it, in the words a user would use. One or two sentences. This is the routing key — a description that only names the topic will not be selected reliably.>
---

# <Skill name>

## Purpose

<The outcome this procedure guarantees, in one or two sentences. If you cannot state what would go
wrong without it, the skill is not needed.>

## When to use

- <Triggering situation.>
- <Triggering situation.>

<And when to skip it — the cheap case where following this would be ceremony.>

## Inputs

- <What must be available before starting.>
- <Where it comes from — a previous skill's output, the user, the repository itself.>
- <If an input is missing, that is handled under Failure handling, not assumed away.>

## Procedure

1. **<Discovery step>.** <Find out what is actually there. Discovery comes before action so that
   nothing — command, path, symbol — is ever invented.>
2. **<Step>.** <An action with an observable result. Not "consider X"; "state X, with file references".>
3. **<Step>.** <Say what not to do at the point the temptation arises.>
4. **<Step>.** <...>

## Validation

- [ ] <Answerable yes or no without guessing.>
- [ ] <Checks that the procedure was actually followed, not that it felt right.>
- [ ] <Includes the verification step: what was run, and did it really pass.>

## Failure handling

- **<A required input is missing or ambiguous>** — <report precisely what is missing and ask; do
  everything that does not depend on the answer first.>
- **<A step is impossible in this repository>** (no test runner, no reproduction, no access) —
  <say so explicitly; never fabricate the missing thing.>
- **<The check fails>** — <report the real output; never make the check pass by weakening it.>
- **<The work is larger than the request implied>** — <stop, report the new scope, re-plan.>

## Output

```text
<Section>     — <what it contains>
<Section>     — <what it contains>
Not done      — <what was skipped, deferred, or left unverified, and why>
Assumptions   — <anything decided without confirmation>
```

<Name the skill or role that comes next.>

---

<!--
Before adding this skill, confirm (see docs/skill-design.md):
  [ ] It is a procedure, not a role (role -> agent) and not knowledge (knowledge -> docs/).
  [ ] It has been needed at least three times.
  [ ] The runtime does not already do this. If it partly does, this skill COMPOSES over the built-in
      rather than reimplementing it — and handles the built-in being absent.
  [ ] Directory name matches frontmatter `name`, and does not shadow a built-in skill's name.
  [ ] All seven sections are present and filled in.
  [ ] No project-specific commands, paths, or tool names anywhere.
  [ ] Validation items are answerable yes/no.
  [ ] Failure handling covers missing input, impossible step, and scope growth.
  [ ] Output includes what was not done.
  [ ] Added to README.md's inventory.
  [ ] `bash scripts/validate-harness.sh` passes.
Delete this comment block in the finished file.
-->
