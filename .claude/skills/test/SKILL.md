---
name: test
description: Discover the project's real test setup, run the relevant tests, and write tests that match the existing conventions. Use when verifying a change, when asked to add or run tests, or when you need to know whether the project has test infrastructure at all.
---

# Test

## Purpose

Verify behaviour using the project's own test infrastructure — and report honestly when there is
none, rather than inventing a command.

## When to use

Before reporting any implementation complete; when adding coverage; when a test fails; and whenever
you need to state what "verified" means in this repository.

## Inputs

- The behaviour to verify.
- The repository: its test directories, config files, CI definitions, and contributor docs.

## Procedure

### 1. Discover — always first

Never assume a runner. Find it:

- **Task definitions**: the scripts/tasks section of the project's manifest or build file, `Makefile`
  / `Justfile` / `Taskfile`, and any `scripts/` directory.
- **CI**: workflow files under `.github/workflows/`, or the equivalent CI config. CI runs the
  commands that actually work — this is the most reliable source.
- **Docs**: root `CLAUDE.md`, `README`, `CONTRIBUTING`.
- **Test files themselves**: their location, naming pattern, imports, and assertion style tell you
  the framework and the conventions.

Record the exact commands you found and where you found them.

### 2. Run

- Run the **narrowest relevant selection first** (single test or file) for a fast signal, then widen
  to the suite the change could affect.
- Use the project's own invocation, including any required environment setup that its docs specify.
- Capture real output. Never summarise a run you did not perform.

### 3. Write

- Match the existing conventions exactly: framework, file location, naming, setup/teardown,
  fixtures, mocking approach, assertion style.
- Cover the intended behaviour, at least one edge case, and the failure path.
- For a bug fix, write the test so that it **fails without the fix** — then confirm it does.
- Test observable behaviour through public interfaces, not private implementation detail.
- Keep tests deterministic: no reliance on wall-clock time, network, ordering, or shared mutable
  state unless the project already does so deliberately.

## Validation

- [ ] Every command run was discovered in the repository, not guessed.
- [ ] The reported result is the real output of a real run.
- [ ] New tests follow the existing file layout and naming.
- [ ] A regression test was confirmed to fail before the fix.
- [ ] No test was skipped, disabled, or loosened to make the run pass.

## Failure handling

- **No test infrastructure exists** — say so explicitly: "this project has no test runner; the
  change was verified by <what you actually did>". Do not add a framework, a config, or a fake
  command. Proposing to set one up is a separate, offered change.
- **The test command fails to start** (missing dependency, missing environment) — report the exact
  error and what it needs. Do not work around it by inventing another command.
- **A test fails** — report the failure and its output. Determine whether the cause is your change
  or a pre-existing failure, and say which. Run `debug` if the cause is unclear.
- **A pre-existing test is already failing** — report it as a separate finding; do not fix it
  silently inside an unrelated change.
- **Tests are slow or flaky** — report it; do not delete or `skip` them to get a clean run.

## Output

```text
Discovery   — commands found, and where they are defined
Run         — what was executed and the real result
Added       — new/updated tests and the behaviour each pins down
Failures    — what failed, and whether this change caused it
Gaps        — what remains unverified, and why
```
