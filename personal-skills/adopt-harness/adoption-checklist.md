# Adoption checklist

Loaded for phase 1 (preflight survey and merge rules) and phase 5a (baseline install) of
`adopt-harness`.

## Phase 1 — Preflight survey

Inventory before touching anything. For each item: present or absent, and if present, what it says.

### Agent configuration

| Path | If present |
| --- | --- |
| `CLAUDE.md` (root and nested) | Read fully. Existing project knowledge — the most valuable thing here |
| `.claude/settings.json` | Read. Existing permission policy, possibly hard-won |
| `.claude/settings.local.json` | Note only. Personal, usually gitignored — never edit |
| `.claude/agents/`, `.claude/skills/` | List and read descriptions. Existing roles and procedures |
| `.claude/project-profile.md` | Adoption already ran. This is a re-adoption — use `audit-harness` instead unless the user wants a rebuild |
| `AGENTS.md` | Cross-tool instruction file. Read as project convention evidence |
| `.cursor/rules/`, `.cursorrules` | Read as evidence. Do not delete |
| `.github/copilot-instructions.md` | Read as evidence. Do not delete |

### Repository basics

`README`, `CONTRIBUTING`, `docs/`, package/project manifests, lockfiles, CI configuration, `.gitignore`,
git history shape (`git log --oneline -20`, branch list).

### State classification

| State | Condition | Rule |
| --- | --- | --- |
| `CLEAN` | No agent configuration of any kind | Install the baseline freely |
| `PARTIAL` | Some Claude configuration, incomplete or thin | Add only what is missing. Never replace what exists |
| `EXISTING` | A functioning harness is already present | Diff every file; the user decides each merge |

**The overwrite rule, in all three states:** show the diff, get approval, then write. A file that
exists was written by someone for a reason you have not yet discovered.

### Merging an existing `settings.json`

Never replace it. Merge by intent:

- Take the **union of `deny`**. A denial in either policy stays denied — removing one silently is the
  single most damaging edit available in this phase.
- Keep every existing `allow`; add foundation entries that are missing. Do not "tidy" existing rules.
- Where `ask` and `allow` conflict for the same command, the stricter wins unless the user says
  otherwise.
- Preserve unrecognised keys untouched.
- Show the resulting diff before writing.

### Merging an existing `CLAUDE.md`

The existing project knowledge is the asset; the foundation's principles are the addition.

- Keep every project-specific section as written.
- Add operating principles and the harness pointer if absent.
- Where the existing file contradicts a foundation principle, **report the conflict; do not resolve
  it silently.** The project may have a reason.
- Flag commands in the existing file that you could not trace to a definition — that is a finding for
  the report, not an edit to make unannounced.

### Merging existing agents and skills

- A project skill that overlaps a foundation skill: keep the project one, report the overlap. Local
  procedure usually encodes something learned in production.
- Same name, different content: never silently replace. Show both.
- Existing agent with a wider tool grant than the foundation's equivalent: report it as a finding —
  a "read-only" role holding `Edit` is a guardrail that is not actually there.

## Phase 5a — Baseline install

Only after phases 1–4. Commands assume `$FOUNDATION` points at a `harness-foundation` checkout and
the working directory is the target repository.

```bash
mkdir -p .claude
cp -r "$FOUNDATION/.claude/agents"  .claude/agents
cp -r "$FOUNDATION/.claude/skills"  .claude/skills
cp    "$FOUNDATION/templates/settings.template.json" .claude/settings.json
cp    "$FOUNDATION/templates/CLAUDE.template.md"     CLAUDE.md
```

Optionally, so the project can verify its own harness structure:

```bash
mkdir -p scripts && cp "$FOUNDATION/scripts/validate-harness.sh" scripts/
```

On `PARTIAL` or `EXISTING`, replace each `cp` above with the corresponding merge rule. Do not run a
bulk copy and then repair afterwards — that destroys the original before anyone has read the diff.

At the end of 5a the harness is installed and **still entirely generic**. It asserts nothing about
this project. Specialisation (5b) is what makes it true.

### Post-install checks

- [ ] `.claude/settings.local.json`, if it existed, is untouched.
- [ ] Nothing that existed before was replaced without an approved diff.
- [ ] `CLAUDE.md` still contains its placeholders — they are filled in 5b, from the profile.
- [ ] `.gitignore` does not exclude `.claude/` (if it does, ask: the harness is meant to be shared).

## Final report checklist

Before declaring adoption complete:

- [ ] The profile exists, names its commit, and its `Unknown` section is non-empty.
- [ ] Every command written anywhere was traced to a definition or run successfully.
- [ ] Every finding was routed through `classification-rules.md`, and the routing is in the report.
- [ ] Findings deliberately **not** written down are listed with reasons.
- [ ] Proposed project skills each cite observed recurrence.
- [ ] Pre-existing configuration is preserved or merged with an approved diff.
- [ ] The project's own verification commands were run, with real output reported.
- [ ] The report states what was skipped and what remains unverified.
