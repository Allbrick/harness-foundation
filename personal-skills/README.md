# Personal skills

Skills that operate **on** harnesses rather than inside one. They must be available before you enter
a target project, so they are installed to `~/.claude/skills/` and are usable in every local
repository.

| Skill | Purpose |
| --- | --- |
| [`adopt-harness`](adopt-harness/SKILL.md) | Install the foundation into a project and specialise it from repository evidence |
| [`audit-harness`](audit-harness/SKILL.md) | Detect drift between a repository and the harness that describes it |

## Why they live here and not only in `~/.claude/`

A skill that exists only under `~/.claude/skills/` is unversioned, unreviewable as a diff, and
invisible to everyone else — which contradicts what this repository claims a harness is. So the
canonical source is here, under version control, and `~/.claude/skills/` is a **deployment target**.

They are kept out of `.claude/skills/` because that directory is copied wholesale into adopting
projects. These two are for the operator, not for the project.

## Install

```bash
mkdir -p ~/.claude/skills
cp -r personal-skills/adopt-harness ~/.claude/skills/
cp -r personal-skills/audit-harness ~/.claude/skills/
```

Re-run after pulling changes. On a platform with symlink support you can link instead of copying, so
updates land automatically:

```bash
ln -s "$PWD/personal-skills/adopt-harness" ~/.claude/skills/adopt-harness
ln -s "$PWD/personal-skills/audit-harness" ~/.claude/skills/audit-harness
```

## Use

```text
/adopt-harness              analyse, propose, then install and specialise after approval
/adopt-harness analyze      analysis only — writes nothing but the project profile
/adopt-harness install      baseline foundation only, no specialisation
/adopt-harness specialize   route findings into layers, assuming a profile exists

/audit-harness              compare the current repository against the harness describing it
```

`/adopt-harness` converges a project onto the harness once. `/audit-harness` keeps them converged as
the project moves. The link between them is `.claude/project-profile.md`, which adoption writes into
the target repository: the claims, their evidence paths, and the commit they were verified against.

These skills follow the same seven-section structure as the project skills in `.claude/skills/` —
see [`docs/skill-design.md`](../docs/skill-design.md).

## Note on stack names

Unlike the project skills, these files may name concrete file names (`package.json`,
`pnpm-lock.yaml`, `.github/workflows/`) as **candidates to look for during discovery**. That is not
the harness assuming a stack: a discovery procedure has to enumerate what it is searching for. The
rule that still holds absolutely is that nothing discovered may be written into a project's
`CLAUDE.md` or `settings.json` unless it was actually found and verified there.
