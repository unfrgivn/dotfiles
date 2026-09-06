---
name: stacked-prs
description: Plan, create, update, review, and safely merge GitHub stacked pull requests when a ticket has ordered dependent phases or the user wants smaller chained PRs and squash commits. Use for stacked, chained, dependent, or layered PR requests, but not for independent work that can target trunk separately and should not be stacked merely because a ticket is large.
---

# Stacked PRs

Use this workflow to keep each phase small, independently reviewable, and represented by its own squash commit. A stack is an ordered dependency chain, not a project-management grouping:

```text
trunk <- phase-1 <- phase-2 <- phase-3
```

The bottom PR targets trunk. Every upper PR targets its immediate parent, and may depend only on the same or lower layers. GitHub native stacks are same-repository only.

## Boundaries and safety

- Planning is read-only. Do not create or switch branches, commit, push, install extensions, create/edit/close/merge PRs, rewrite history, delete branches, or mutate tickets unless the user explicitly authorizes that action.
- Never use plain `--force`. A history rewrite requires showing affected branches and PRs, a clean worktree, explicit authorization, and `--force-with-lease`.
- Do not auto-commit, auto-push, auto-merge, or use auto-merge. Do not silently install `github/gh-stack`.
- Native stacks require a same-repository linear history. Cross-fork stacks and GitHub Desktop are unsupported. Server-side Rebase stack may force-push and can create unsigned commits.
- Stop on dirty worktrees, ambiguous ancestry or ownership, non-linear history, cross-fork dependencies, a closed middle PR, conflicts, failed checks, or unclear scope. Explain recovery; do not improvise mutations.
- A closed middle PR blocks layers above it. A completed stack cannot be extended; start a new stack for later work.

## Plan first

Inspect repository guidance, the ticket/spec, current branch and base, worktree status, ancestry, open PRs, and existing stack state. Use read-only commands and GitHub inspection. Distinguish an actual dependency from merely related work; independent phases should each target trunk.

Produce this ordered table before taking action:

| Phase | Purpose | Branch | Immediate base | Scope | Validation | Dependency/unlock |
|---|---|---|---|---|---|---|
| 1..n | concise behavior | branch | trunk/parent | included/excluded files | tests/checks | what it enables |

Enforce that the bottom layer is independently valid, each upper layer depends only on same/lower layers, every layer is coherent, testable, and reviewable, and unrelated work is excluded. State the expected PR order and identify risks. Confirm the plan and authorized actions before mutation.

## Create

1. Prefer native GitHub support when available. Run `gh stack --help` first. If unavailable, explain that the public-preview stack feature may require the `github/gh-stack` extension and ask before installing it; never require or install that dependency silently.
2. With authorization, use native commands as appropriate: `gh stack init`, `gh stack add`, `gh stack submit`, `gh stack view`, `gh stack rebase --upstack`, `gh stack push`, and `gh stack sync --prune`. Inspect help and repository state before selecting a command.
3. If the user declines installation or native support is unavailable, use a clearly labeled **manual stack**: create branches bottom-up and create each PR with existing Git and `gh pr create --base <immediate-parent>`. Warn that native automatic retarget and sync behavior will not apply.
4. Build strictly bottom-up from each immediate parent. Before each PR, verify `git diff <parent>...<branch>` contains only that layer and run relevant validation.
5. When PR creation is authorized, invoke the existing `create-pr` skill if available, passing the immediate parent as the base. Keep this workflow's stack metadata even when that skill is unavailable.
6. Give each PR a compact stack position/table, its immediate parent, phase purpose, exact scope, validation, and remaining dependency. Do not make the PR description pretend the diff is against trunk when it is against a parent.

## Update and review

- Review each PR as `immediate-parent...head`. Review against trunk only for the bottom layer. Check base/head metadata, ancestry, changed files, checks, and whether the phase remains independently understandable.
- Put a correction on the branch that owns the behavior. Then rebase or sync descendants bottom-up so fixes propagate without duplicating ownership.
- Before any rebase or force-with-lease, require a clean worktree, preview all affected branches, PRs, and commit-range changes, and obtain authorization for the history rewrite. Treat `gh stack push` as a history-rewriting operation; do not run it if the installed command cannot provide lease-safe updates. Re-run layer validation afterward.
- After rebasing, verify every affected PR's base/head metadata, three-dot diff, ancestry, and checks. Resolve conflicts explicitly; stop if ownership or intended result is unclear.

## Merge

- Safe default: merge one PR at a time, bottom-up, using squash merge. This preserves one reviewed phase per resulting commit. Invoke the existing `merge-pr` skill per layer when available.
- After each lower merge, run or offer `gh stack sync --prune` when native support is available. Before the next merge, verify its base, head, immediate-parent diff, ancestry, and checks.
- Merging a whole or contiguous stack from a higher PR requires an explicit request. First preview every affected PR and resulting commit, then report the tradeoff and obtain authorization. Never use auto-merge.
- Do not delete branches unless asked. Do not proceed past failed checks, conflicts, a closed middle PR, or a base/head mismatch.

## Output contract

Label the response **Plan**, **Status**, **Action**, **Next layer**, or **Blockers** as applicable. Always include the current stack order, immediate parent for the relevant layer, inspected diff/check state, mutations performed (or “none”), and the exact next authorized step. For a blocker, name the evidence, impact, and safe recovery choice.

## Official sources

- [GitHub Docs: Stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/stacked-pull-requests)
- [GitHub Docs: About stacked pull requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs)
- [GitHub Docs: Stacked PR CLI commands](https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands)

Stacked pull requests are public preview. Re-check the official documentation and `gh stack --help` if CLI behavior differs from this workflow.
