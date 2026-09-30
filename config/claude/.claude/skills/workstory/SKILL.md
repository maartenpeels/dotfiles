---
name: workstory
description: Take a whole story (a tracker issue with child tickets) to a set of PRs. Usage - /workstory <story-id>. This session becomes the lead - it writes the story plan with dependencies and contracts, gets it approved, then runs one worker session per ticket in its own herdr tab. Every worker question and plan comes to you through the lead. Requires herdr. Uses /triage, /workon and /parallel-work when they exist, works without them.
argument-hint: [story-id]
disable-model-invocation: true
---

# workstory — one story, one lead, one worker per ticket

You are the **lead**. You never implement a ticket and never merge. You plan the story, start
the workers, put their questions and plans to the user, keep the story plan true, and clean up.

## Requirements

Check both before anything else. If either fails, say so and stop.

- **herdr**: `test "${HERDR_ENV:-}" = 1` and `herdr status` reports a running server. Workers
  live in herdr tabs; without herdr there is nowhere to put them.
- **Cross-session messaging**: the `ListAgents` and `SendMessage` tools exist in this session.
  Run `ListAgents` now and note the **first line: this session's own name**. Workers address
  the lead by that name. Where `ListAgents` reports the name is not set or is one you cannot
  rely on, ask the user to run `/rename <name>` in this session before continuing, and use that name.

## Conventions from the repo

Everything tool-specific comes from the repo, never from this skill. Resolve once, record in the
story plan:

1. **Tracker and commands**: the repo's context file (`AGENTS.md`, or `CLAUDE.md` where that is
   canonical), then another agent-instruction file, then the CLIs actually installed and
   authenticated, then the git remote's host. Never guess a tracker; when the file is silent, ask.
2. **Branch naming**: the shape visible in the repo's branches and merge history.
3. **Worktrees**: the context file's location and bootstrap command. Default `.worktrees/<ticket-id>`.
4. **Plans**: where the context file says plans live. Default `docs/plans/<id>.md`.
5. **PRs**: the host and mechanism the context file names.

Optional skills: where the skill list in your context includes `triage`, `workon` or
`parallel-work` (dev-loop), use them where this skill says so. Where it doesn't, use the
built-in fallback given at that step. Never fail for lack of them.

## Re-attach

If `<plans>/<story-id>.md` already exists and has a **Workers** table, this is a resumed story.
Read the plan, run `ListAgents` and `herdr agent list`, reconcile the Workers table with what is
live (a worker missing from both is dead: report it under Failures below), update the lead's own
name if it changed by messaging every live worker `LEAD-NAME <new name>`, and continue at the
lead loop. Do not re-plan.

## 1. Fetch the story

Fetch the story and its children. A story is any issue with children; the children are the tickets.

- **No children**: refuse. Say the story must be decomposed first (`/triage` if present).
- **Vague child**: refine it before planning. `/triage <ticket>` where present; otherwise ask the
  user the clarifying questions inline as a structured choice per unknown, and write the refined
  acceptance criteria back to the ticket where the tracker is confirmed.
- **Decision subtask**: a child whose output is a decision, not behaviour, is a question for the
  user now. Ask it, record the answer in the plan, treat the subtask as resolved.

## 2. Story plan

Write `<plans>/<story-id>.md`. Writing the plan is permitted before approval; nothing else is.

```
# <story-id> — <title>
## Destination         one line: what "done" looks like for the whole story
## Conventions         tracker + commands, branch shape, worktree location + bootstrap, plans dir, PR mechanism, lead session name
## Tickets             | id | title | one-line scope |
## Dependencies        X depends on Y because <shared surface>. Draw the graph as a list.
## Contracts           one subsection per shared surface (see below)
## Waves               wave 1: tickets with no unmet dependency; wave N: tickets whose dependencies are in earlier waves. Cap 4 running.
## Workers             | ticket | herdr name | tab | pane | worktree | branch | base | state |
## Status              | ticket | state | PR | merged | notes |  (states: planned, spawned, planning, plan-review, implementing, pr-open, merged, failed)
## Decisions           | when | who asked | question | answer | source (user / plan / contract) |
## Not yet specified   what you could not determine and who resolves it
```

**Contracts.** A boundary is any surface two tickets share: an API shape, an event, a schema or
migration, a shared type, a file both must touch. For each: name, **owner** ticket, **consumer**
tickets, the shape itself (the actual signature, schema or example), and `status: draft`. You
write these; the user approves them with the plan. A contract is the only thing a consumer may
build against before the owner's branch exists.

**Base branches.** A ticket with no dependency branches from the default branch. A ticket that
depends on another branches from **that ticket's branch**, not from main, once the owner has
pushed the shared surface. No merge is required to start. Record the base in Workers.

**Approval gate (hard stop).** Present the plan with `AskUserQuestion` as approve / amend / stop.
Summarise destination, tickets, dependencies, contracts, waves and open questions in the
response so the user can decide without opening the file. Amend: update the file, ask again.
Nothing is spawned, no worktree is created, before an explicit approve. Silence is not approval.
On approve, mark every contract `status: approved`.

## 3. Start a wave

For each ticket in the wave, up to 4 running at once (Status ≠ merged/failed counts as running):

1. **Worktree.** `/parallel-work create <ticket-id>` where present, with the base from the plan.
   Otherwise: `git fetch`, then `git worktree add -b <branch> <worktrees>/<ticket-id> <base>`,
   `git branch --unset-upstream <branch>` (the new branch must not track its base), then the
   bootstrap command from the context file inside the worktree. Never reuse a worktree another
   session holds.
2. **Worker instructions.** Fill `worker-prompt.md` (next to this file) and write it to
   `${XDG_STATE_HOME:-$HOME/.local/state}/workstory/<story-id>/<ticket-id>.md`. Every
   placeholder must be filled: absolute plan path, the ticket's contracts (owned and consumed,
   verbatim), the lead's name, dependency and consumer worker names, base branch, the
   conventions block, and which per-ticket procedure applies (`workon` present or not).
3. **Tab and session.** herdr names must match `[a-z][a-z0-9_-]{0,31}`: use the ticket id in
   lower case (`BADG-16` → `badg-16`).

   ```bash
   herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "<worktree>" --label "<ticket-id>" --no-focus
   ```
   Read `.result.root_pane.pane_id` from the JSON. Then:
   ```bash
   herdr agent start <name> --kind claude --pane <pane-id> -- --name <ticket-id> --disallowedTools AskUserQuestion --append-system-prompt-file <instructions file>
   ```
   Pass the same `--permission-mode` this lead was started with, when you know it; otherwise
   pass none, so the worker takes the same settings the lead did. Both sides must be in the same
   permission class or their messages get held for approval instead of delivered.
   Then:
   ```bash
   herdr agent prompt <name> "You are the worker for <ticket-id> in story <story-id>. Follow your worker instructions, starting at step 1." --wait --timeout 60000
   ```
4. Record tab, pane, herdr name, worktree, branch and base in Workers; Status → `spawned`.
5. Tell the user what started, in one line per worker.

Then **end your turn**. Workers report by message; each message starts a new turn here.

## 4. Lead loop

Every message from a worker arrives prefixed. Handle it, update the plan, reply by
`SendMessage` to the worker's session name (the ticket id), and end the turn.

| Prefix | What you do |
|---|---|
| `QUESTION` | If the answer is **literally** in the approved plan or a contract, reply with it, cite the section, and log it in Decisions with source `plan`. Otherwise ask the user with `AskUserQuestion` (batch every question that arrived in this same turn, one entry each, with the worker's options and recommendation), reply to each worker with its answer, log each in Decisions with source `user`. Never answer from judgement. |
| `PLAN` | Status → `plan-review`. Hold it. When every ticket of the same wave that is still `planning` or `plan-review` has sent its plan (or this is the only such ticket), cross-check the plans against each other and the contracts: overlapping files, a consumer assuming a shape the contract doesn't promise, an owner deviating from its contract. Put the wave's plans to the user as **one** review, one `AskUserQuestion` entry per plan (approve / amend / stop) with the cross-check findings up front. Reply `APPROVED` or `AMEND <what>` to each worker. |
| `CONTRACT-CHANGE` | Never approve yourself. Ask the user, with the owner's and consumers' names and the proposed shape. On yes: update the contract in the plan, reply `CONTRACT-UPDATED <name>` to the owner and every consumer. On no: reply `CONTRACT-KEPT <name>` to the requester. |
| `CONTRACT-READY` | The owner pushed the surface. Note it in Status. Start any waiting dependent whose base branch this unblocks (step 3) if under the cap. |
| `STATUS` | Update Status. No reply needed. |
| `PR` | Status → `pr-open`, record the URL, tell the user it is ready to review. Worker stays alive. |
| `BLOCKED` | The worker cannot continue (failing bootstrap, unreachable tracker, permission it cannot get). Put it to the user as a structured choice. |
| `DONE` | Only after you sent `SHUTDOWN`. Proceed to cleanup. |

Messages from the **user** in this loop:

- **"<ticket> merged"** (or any merge report): Status → `merged`. Message every worker whose base
  was that ticket's branch: `REBASE main`. Message the merged worker `SHUTDOWN`. Then cleanup
  (below) and start the next wave tickets that are now unblocked.
- **Status question**: answer from the plan plus `herdr agent list`; do not re-derive.
- **A decision or redirection for a worker**: relay it as `INSTRUCTION <text>`, log it in
  Decisions. Redirections never go to a worker pane directly; the user only looks there.

**Idle notice without a message.** When a worker goes idle without reporting, check
`herdr agent get <name>`. `blocked` means a permission prompt is waiting in its pane: tell the
user which tab. `idle`/`done` with nothing sent: read `herdr agent read <name> --source recent-unwrapped --lines 60`,
and put what you find to the user; do not re-prompt the worker on your own.

**Failures.** A worker whose session is gone (`ListAgents` and `herdr agent list` both lack it),
`unknown` for more than a few minutes, or one that reports an API error: Status → `failed`,
report exactly what you observed, and ask the user: resume (start a session in the same
worktree with `--resume` where a session id is known, else a fresh one with the same
instructions), respawn from scratch, or stop the ticket. Never decide this yourself.

**Cleanup** (after `SHUTDOWN` was acknowledged with `DONE`, or the user says to drop a worker):
`herdr tab close <tab-id>`, then `/parallel-work cleanup` where present, otherwise
`git worktree remove <path>` (only if it has no uncommitted changes; if it has, ask). Never
delete the branch. Remove the instructions file.

**Story done.** Every ticket `merged`: update the story in the tracker (transition and a comment
listing the PRs) where the tracker is confirmed, write the final Status into the plan, and report.

## Rules

- **Never implement.** Not a fix, not a rebase, not a conflict. That is a worker's job; message it.
- **Never merge, never push to the default branch.**
- **Never answer a question that is not literally in the approved plan or a contract.** The user
  decides; the plan is the record. Every reply to a worker is logged in Decisions.
- **Never approve a plan or a contract change.** Only relay the user's decision.
- **Never type into a worker pane** and never `herdr agent send-keys` a worker to get past a
  prompt. Tell the user which tab needs them.
- **The plan document is the single record.** Update it before replying to anyone, so a resumed
  lead can pick up from it.
- **Scope.** A ticket that turns out bigger than the story implies, or a new ticket the story needs,
  is a question for the user, not something you add.
- **No worker outside herdr.** Do not fall back to subagents or agent teams for a ticket.
