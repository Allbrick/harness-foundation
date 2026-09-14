# Templates

Starting points for adopting or extending the harness. Each is meant to be copied and filled in, not
referenced in place.

| File | Copy to | Purpose |
| --- | --- | --- |
| `CLAUDE.template.md` | `<project>/CLAUDE.md` | The adopting project's always-on rules and project knowledge |
| `settings.template.json` | `<project>/.claude/settings.json` | Safe baseline permission policy |
| `agent.template.md` | `.claude/agents/<name>.md` | A new role |
| `skill.template.md` | `.claude/skills/<name>/SKILL.md` | A new procedure |

## Filling in `CLAUDE.template.md`

Work from the repository, not from memory of similar projects:

- **Commands** — take them from the project's task runner, manifest scripts, `Makefile`, or CI
  workflow. CI is the most reliable source, because those commands are known to work. **Delete any
  row you cannot point to a definition for.** A wrong command is worse than a missing one: it
  produces confident reports about runs that never happened.
- **Architecture** — write only what cannot be learned by reading one file. Skip the directory tree.
- **Important constraints** — this is the section that prevents damage. Be specific about what must
  never be touched automatically.

Keep the result short. Detailed procedure belongs in a skill; rationale belongs in `docs/`.

## Filling in `settings.template.json`

The baseline is deliberately stack-agnostic: it allows read-only inspection, asks before
consequential actions (commit, push, network, infrastructure), and denies destructive commands and
access to secret files.

Adapt it in one direction only — **add the project's verification commands to `allow`** once you
know them, so that lint, typecheck, test, and build runs do not prompt every time. For example, a
project whose test command is `<runner> test` would add `"Bash(<runner> test:*)"`.

Do not loosen `deny`. If a denied rule blocks legitimate work, that is a decision for the project's
owner, and the rule should be narrowed deliberately rather than removed.

Note that `Bash(...)` rules match command prefixes, so a broad allow entry grants more than it
appears to. Prefer the narrowest prefix that covers the real usage.

## Adding an agent or a skill

Read `docs/agent-design.md` or `docs/skill-design.md` first — each ends with the checklist the
template's trailing comment block repeats. Delete that comment block before finishing, add the new
file to the inventory in the root `README.md`, and run:

```bash
bash scripts/validate-harness.sh
```
