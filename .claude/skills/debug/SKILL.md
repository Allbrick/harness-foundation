---
name: debug
description: Diagnose a bug by reproducing the symptom, gathering evidence, testing hypotheses, and isolating root cause before proposing a minimal fix. Use for crashes, wrong output, failing tests, regressions, and any "it does not work" report whose cause is unknown.
---

# Debug

## Purpose

Find the actual cause of a failure, with evidence, so the fix addresses the defect rather than the
symptom.

## When to use

Whenever something is broken and you do not already know why. If the cause is already established,
skip to `implement`.

## Inputs

- The symptom: error message, stack trace, wrong output, failing test name.
- How to trigger it: steps, input, environment.
- When it last worked, if known.

## Procedure

```text
Symptom -> Reproduction -> Evidence -> Hypothesis -> Verification -> Root cause -> Minimal fix -> Regression test
```

1. **Symptom.** Record observed vs expected behaviour precisely. Copy the real error and stack
   trace. A vague symptom produces a vague diagnosis — pin it down first.
2. **Reproduction.** Find the smallest deterministic trigger. If the failure is intermittent, record
   the conditions and frequency; that is data, not a dead end. If you cannot reproduce it, say so
   before going further.
3. **Evidence.** Read the code along the failure path. Observe real state — existing logs,
   instrumentation, a failing test run, or a throwaway script kept outside the repository tree. Use
   history (`git log -S`, `git bisect`) when the behaviour used to be correct.
4. **Hypothesis.** State a specific, falsifiable claim, e.g. `user` is null at `service.ts:88`
   because `load()` returns early when the cache is cold. Write down what observation would
   disprove it.
5. **Verification.** Test it. Confirm or discard. Discarded hypotheses stay in the report — they are
   what makes the conclusion trustworthy.
6. **Root cause.** The earliest point where state first diverges from intent; the throwing line is
   usually downstream of it. Keep asking "why" until the next answer is a design decision rather
   than a defect.
7. **Minimal fix.** Smallest change at the root cause, with its blast radius. If only a
   symptom-level fix is available, say so and explain the tradeoff.
8. **Regression test.** A test that fails before the fix and passes after. Write it before the fix
   where the project's workflow allows.

## Validation

- [ ] The symptom was reproduced, or the failure to reproduce is documented.
- [ ] The root cause is supported by observation, not by inference alone.
- [ ] Competing explanations were ruled out, with reasons.
- [ ] The proposed fix demonstrably removes the symptom in the reproduction.
- [ ] A regression test exists that fails without the fix.

## Failure handling

- **Not reproducible** — report what you tried, what you observed, and what further information
  (logs, version, environment, input) would help. Do not fix by guesswork.
- **Root cause is outside the codebase** (dependency, environment, data, upstream service) — report
  it with evidence and propose a workaround plus its cost.
- **Multiple independent causes** — report each separately and fix them in separate changes.
- **The fix is much larger than the bug** — report the tradeoff and let the user choose between a
  contained mitigation and the full correction.

## Output

```text
Symptom         — observed vs expected
Reproduction    — exact steps, or why it could not be reproduced
Evidence        — observations with file:line references
Hypotheses      — considered; confirmed or ruled out, with reasons
Root cause      — the defect and where it originates
Minimal fix     — proposed change and its blast radius
Regression test — what to add so this cannot return silently
Confidence      — high | medium | low, and what would raise it
```

Hand the diagnosis to `implement`; review the resulting fix with `review`.
