# Adopting the harness in an existing project

A walkthrough of installing this harness into a project that already has code, then running one task
through the workflow. Stack-agnostic by design — `<...>` marks something you must read out of the
target repository rather than assume.

## 1. Install the files

From the target project's root:

```bash
# harness core
cp -r <path-to>/harness-foundation/.claude/agents      .claude/agents
cp -r <path-to>/harness-foundation/.claude/skills      .claude/skills
cp    <path-to>/harness-foundation/templates/settings.template.json  .claude/settings.json

# project rules, to be filled in next
cp    <path-to>/harness-foundation/templates/CLAUDE.template.md CLAUDE.md
```

If the project already has a `CLAUDE.md`, do not overwrite it. Merge: keep its project knowledge,
and add the harness's operating principles plus the "Harness" pointer section.

## 2. Fill in `CLAUDE.md` from evidence

This is the step that decides whether the harness helps or misleads. Work from the repository:

| Section | Where the answer comes from |
| --- | --- |
| Tech stack | The manifest and lockfile — not the directory names |
| Commands | The task runner / manifest scripts / `Makefile` / **CI workflow** |
| Architecture | Reading the entry points and following one request end to end |
| Testing | The test directory's own files: framework, naming, fixtures |
| Git workflow | `git log --oneline -30`, branch protection, PR template |
| Important constraints | Ask the owner; this one is rarely written down anywhere |

**CI is the best source for commands**, because those are the commands that are known to run
green. Anything you cannot trace to a definition gets deleted from the table, not guessed.

A good first prompt in the target project:

> Read this repository and fill in the `<...>` placeholders in CLAUDE.md. Every command must come
> from a definition you can point to — CI config, task runner, or manifest. Delete any row you
> cannot source, and list what you deleted.

## 3. Add the project's verification commands to the policy

Once the commands are known, add them to `allow` in `.claude/settings.json` so validation does not
prompt every run — for example `"Bash(<test-command>:*)"`, `"Bash(<lint-command>:*)"`. Leave `deny`
alone. See `templates/README.md`.

## 4. Run a task through the workflow

A realistic first task, with the stage each step corresponds to:

```text
User:  "Fix the <X> handler so it rejects <invalid input> instead of throwing."

Explore     find the handler, its callers, and its tests
Understand  state what it does today and which callers depend on the current behaviour
Plan        `plan` skill -> files, blast radius, risks, ordered steps. User approves.
Implement   `implement` skill -> minimal change + a test that fails without it
Validate    `test` skill -> discover the real command, run it, record actual output
Review      `review` skill      -> findings with severity; fix blockers, re-review
Report      what changed, what was verified, what was not, what was assumed
```

What "good" looks like at each boundary:

- The plan names files that exist and a command that is defined. If it says "run the tests" without
  naming the command, discovery was skipped.
- The implementation diff contains nothing the plan did not call for — no drive-by formatting.
- The validation section quotes real output. "Tests pass" with no command and no output is not a
  validation.
- The review produces either findings with concrete failure scenarios, or an honest zero.

## 5. Promote what you repeat

After a few weeks, look at the corrections you keep typing. Any instruction you have given three
times belongs in the project's `CLAUDE.md` (if it is a rule) or in a new skill (if it is a
procedure). That is the loop that turns a harness from a starting configuration into the project's
accumulated knowledge — see `docs/skill-design.md#when-to-add-one`.

## Common adoption mistakes

| Mistake | Consequence |
| --- | --- |
| Copying `CLAUDE.md` and leaving placeholders | The agent works from a template describing no real project |
| Guessing commands instead of sourcing them | Confident reports about runs that never happened |
| Pasting the whole architecture doc into `CLAUDE.md` | Always-on context bloats; the rules that matter get diluted |
| Loosening `deny` to stop prompts | The guardrail is gone exactly where it was needed |
| Adding a role per technology | Roles stop being distinct modes of work; routing degrades |
