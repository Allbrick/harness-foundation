---
name: <kebab-case-name>
description: <What this role is responsible for, and WHEN to invoke it, in the words a user would use. State what it does not do. This is the only part always in context — it is the routing key.>
tools: <minimum needed, comma-separated: Read, Grep, Glob, Bash — add Write, Edit only if this role changes files>
model: inherit
---

# <Role name>

<One or two sentences: what this role exists to produce, and what it deliberately does not do.
If the role is analysis-only, say so here and omit Write/Edit from `tools` above — the absent
capability is the guardrail; this line only explains it.>

## Responsibilities

- <Each item is something this role is accountable for producing or judging.>
- <Distinct from the other roles. If it overlaps heavily with an existing agent, extend that one instead.>
- <Three to six items. More than that means the role is not bounded.>

## Method

1. **<Step name>.** <How this role approaches the work — its thinking pattern, not a full procedure.
   The step-by-step belongs in a skill; link to it.>
2. **<Step name>.** <Say what evidence is required before a conclusion is allowed.>
3. **<Step name>.** <...>

## Constraints

- <What this role must not do — and the failure it prevents. A prohibition without a reason gets
  rationalised away under pressure.>
- <Scope limits: what it hands off instead of doing itself.>
- <What it must never claim without evidence.>

## Output

```text
<Section>  — <what it contains>
<Section>  — <what it contains>
<Section>  — <what was NOT done / not verified / assumed>
```

<Name the next role or skill in the pipeline, and link to the skill that defines the procedure.>

---

<!--
Before adding this agent, confirm (see docs/agent-design.md):
  [ ] The work is a distinct mode of thinking, not just a procedure -> otherwise write a skill.
  [ ] The tool grant is the minimum; read-only roles have no Write/Edit.
  [ ] The description says WHEN to use it, not only what it is.
  [ ] No procedure duplicated from a skill — linked instead.
  [ ] Body is under ~100 lines.
  [ ] Added to README.md's inventory.
  [ ] `bash scripts/validate-harness.sh` passes.
Delete this comment block in the finished file.
-->
