# ADR 0004: Non-Destructive Verification Gate

- Date: 2026-03-23
- Status: Accepted

## Context

Normle needs stable verification entrypoints for humans, Codex, and
`pre-commit`. Those entrypoints must explain missing prerequisites, reuse the
same CI artifact layout, and avoid mutating tracked files during the final gate.

## Decision

Adopt a staged verification contract:

1. `check_environment.sh` diagnoses prerequisites.
2. `format_swift.sh` is the explicit autofix step after Swift edits.
3. `lint_swift.sh` is non-destructive.
4. `verify_repository_state.sh` runs targeted checks and always writes CI run artifacts.
5. `verify_task_completion.sh` is the non-destructive final gate and fails if the worktree changes.
6. `verify_pre_commit.sh` reruns the same non-destructive final gate for `pre-commit`.

## Consequences

- `pre-commit` becomes a thin wrapper around `verify_pre_commit.sh`.
- SwiftLint is resolved from the project-managed `SimplyDanny/SwiftLintPlugins`
  package instead of an external binary requirement.
- CI run artifacts stay under `.build/ci/runs/<RUN_ID>/`.
- Final verification semantics are explicit and reviewable.
