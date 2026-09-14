# Drift checklist

Loaded for step 3 of `audit-harness`. Six categories, most damaging first.

## 1. Commands — the highest-value check

A stale command is the worst kind of drift: the agent runs it, it fails or silently does the wrong
thing, and the failure is attributed to the code rather than to the harness.

For every command in `CLAUDE.md` and every `allow` rule in `.claude/settings.json`:

- [ ] Is it still defined where the profile said it was?
- [ ] Does the task runner / manifest / CI still name it?
- [ ] Did the package manager, task runner, or CI system change underneath it?
- [ ] Are there commands in CI now that the harness does not know about? (`missing`)
- [ ] Do `allow` entries still match how the commands are actually invoked?

Re-trace, do not assume. A command that was green a quarter ago is a claim with an expiry date.

## 2. Architecture and stack

Compare the profile's Architecture, Stack, Flow, and State ownership sections against current
evidence:

- [ ] Do the manifests still list the frameworks and libraries the profile names? A replaced
      state-management or data-fetching library makes every related harness rule actively wrong.
- [ ] Does the traced execution path still exist? Walk the first two hops; if they moved, re-trace.
- [ ] Have new top-level units appeared — a new workspace package, a new service, a new entry point?
- [ ] Do the dependency-direction rules still hold, or has the import graph changed?
- [ ] Has the state ownership model changed (new cache layer, new store, moved boundary)?

**Version bumps within a library are not drift.** Replacement, removal, or a changed boundary is.

## 3. Constraints and domain invariants

The most expensive category to get wrong, and the easiest to miss — these rarely announce themselves
in a diff:

- [ ] Does each "Important constraint" still correspond to something real?
- [ ] Do the do-not-edit paths still exist, and are there new generated directories not covered?
- [ ] Are the domain invariants still enforced in code? If an invariant moved from application code
      into a database constraint, the rule changes shape.
- [ ] Have new invariants appeared — new validation, new permission model, new tenancy rule?
      (`missing`)
- [ ] Is a stated constraint being violated by current code? Report it as a code finding; do not
      delete the rule to make the audit clean.

## 4. Permissions

- [ ] Do `deny` rules still cover the paths that matter? New secret files, new generated output, new
      production configuration may be uncovered. (`missing`)
- [ ] Is any `deny` now blocking legitimate routine work? Narrow it deliberately — never delete it
      to reduce prompting.
- [ ] Do `allow` entries still correspond to commands that exist? (`stale`)
- [ ] Is anything in `ask` or `allow` that should now be denied outright — a destructive script added
      since adoption?
- [ ] Are there rules stated only in prose that the runtime could now enforce? (`unenforced`)

## 5. Harness usage

Content nobody uses costs context on every task and earns nothing:

- [ ] Do the project skills describe procedures still in use? Check history and CI for the work they
      cover before proposing removal — quarterly work looks unused in a monthly window.
- [ ] Do project agents still describe distinct modes of work, or has one become a duplicate?
- [ ] Has a procedure been repeated often enough to deserve promotion to a skill? (`missing`)
- [ ] Does any local skill now duplicate something the runtime provides? It should compose over the
      built-in instead. (`unused`)
- [ ] Does `CLAUDE.md` contain anything discoverable by reading one file? It should not be there.
- [ ] Do read-only agents still lack `Edit`/`Write`, or has a grant widened since adoption?

## 6. The `Unknown` list

The section adoption was required to fill. Revisit every item:

- [ ] **Resolved** — the answer now exists in the repository. Move it into the relevant section with
      its evidence.
- [ ] **Still unknown** — keep it, and note that it survived an audit. An item unknown across two
      audits is worth asking a human about.
- [ ] **No longer relevant** — the subsystem was removed. Delete it and say so.

An `Unknown` list that never changes usually means nobody is reading the profile — which is itself a
finding worth reporting.

## Judgement rules

- **Not every difference is drift.** A repository is allowed to change without the harness being
  wrong. Drift is when the harness makes a *claim* that is no longer supported.
- **Prefer deleting a stale rule over rewriting it into vagueness.** "Prefer the appropriate pattern"
  helps nobody and cannot go stale, because it never said anything.
- **Report the asymmetry.** `stale` findings are more urgent than `missing` ones: an uninformed agent
  asks, a misinformed one proceeds.
- **Do not expand the harness during an audit.** Missing rules are proposed, not added — a periodic
  check that quietly grows the harness turns into unreviewed scope creep on a schedule.
