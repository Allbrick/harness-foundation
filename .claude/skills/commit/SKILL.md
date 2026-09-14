---
name: commit
description: Analyse the staged and unstaged diff, group it into coherent changes, and write Conventional Commits messages that explain why. Use when the user asks to commit, or to summarise or split the current changes.
---

# Commit

## Purpose

Produce commits that a future reader can understand without reconstructing the session: one logical
change each, with a message that explains the reason.

## When to use

When the user asks to commit, stage, or summarise changes. **Only when they ask** — never commit as
an unrequested side effect of finishing work.

## Inputs

- `git status` — what is staged, unstaged, and untracked.
- `git diff` and `git diff --staged` — the actual content of the change.
- `git log --oneline -20` — the repository's existing message conventions, which win over the
  defaults below.

## Procedure

1. **Read the full diff**, staged and unstaged. Never write a message from memory of what you did;
   the diff is the source of truth and may contain more than you remember.
2. **Check what is about to be included.** Look for debug output, secrets, credentials, large
   binaries, editor/IDE state, generated artifacts, and unrelated edits. Raise anything suspicious
   before staging it.
3. **Match the local convention.** Read recent history first. If the repository uses a different
   format (ticket prefixes, no type prefix, a different language), follow it.
4. **Group into logical commits.** One coherent change per commit. If the working tree mixes a fix,
   a refactor, and a feature, propose splitting them and stage per group rather than committing a
   single blob.
5. **Write the message.**

   ```text
   <type>(<optional scope>): <imperative summary, <= 72 chars, no trailing period>

   <why this change was needed, and what it does at a level the diff does not show>
   <any behaviour change, migration step, or follow-up the reader must know>
   ```

   Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`, `style`.
   Breaking changes: `!` after the type/scope, plus a `BREAKING CHANGE:` footer.

   The subject says *what*; the body says *why*. Omit the body only when the subject fully explains
   the change.
6. **Commit**, then confirm with `git status` that the tree is in the expected state.

## Validation

- [ ] The message describes what the diff actually contains.
- [ ] Nothing unintended is staged: no secrets, no `.env`, no IDE state, no debug leftovers.
- [ ] The format matches the repository's existing history.
- [ ] The subject is imperative mood and within 72 characters.
- [ ] Each commit is one logical change.

## Failure handling

- **A pre-commit hook fails** — report the output and fix the underlying cause. Never bypass hooks
  (`--no-verify`) or signing unless the user explicitly asks.
- **The diff contains a secret or credential** — stop immediately, report it, and do not stage it.
- **Changes are unrelated to each other** — propose a split; commit a mixed tree only if the user
  says to.
- **On the default branch** and the project protects it — say so and offer to branch first.
- **Nothing to commit** — say so; do not create an empty commit.

## Output

```text
Grouping   — the commits proposed, and what goes in each
Message    — the full message for each
Excluded   — anything deliberately left unstaged, with reasons
Result     — commit hashes and the resulting git status
```

Pushing, tagging, and opening pull requests are separate actions that need their own explicit
request.
