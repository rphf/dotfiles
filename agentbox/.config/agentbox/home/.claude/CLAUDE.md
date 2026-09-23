## Source Your Claims — MANDATORY

**ALWAYS SEARCH FIRST, ANSWER SECOND** whenever the answer depends on the world outside this repository — how a tool works, whether something is supported, current versions, maintenance status, or config options. Verify before you answer.

**WHERE TO VERIFY (pick what fits — no fixed order):** choose the most direct source for the question. Options include:

- Code and config in this repo, or on disk under vendored deps (e.g. `./node_modules/`, `./vendor/bundle/`)
- Official docs (Context7, project docs, package registry, release notes)
- GitHub issues and PRs (upstream public repo or this repo)
- Web search when docs are scattered or stale
- Git history (`git log`, blame, specific commits) when behavior or intent changed over time
- Training knowledge only when nothing else is available — prefix each such claim with `UNVERIFIED:`

**ALWAYS SAY SO** if verification fails or returns nothing useful.

**VERIFY BEFORE YOU ASSERT:**

- Cite what you checked (registry, doc, path, issue, commit, etc.).
- When behavior surprises you, read the implementation (in-repo, vendored, upstream, or stdlib) instead of assuming.
- Treat hedging ("likely", "probably", "almost certainly", "should work fine") as a signal to verify — then replace it with evidence.

**ALWAYS INCLUDE A STRUCTURED SOURCE REPORT** for every answer that relies on outside-world facts, findings, or recommendations. The human must be able to follow your references and reach the same conclusion independently. Use a dedicated **Sources** section:

```markdown
## Sources

- **Claim:** <what you concluded or recommended>
  - **Evidence:** <file path + line range | doc URL | GitHub issue/PR permalink | commit SHA / `git log` output | command output>
```

List every material claim with reproducible evidence (paths, links, or output snippets). Omit the section only when the entire answer comes from files in this repository with no external verification.

## Approach

- NEVER commit or push code without asking for permission from the user.
- Think before acting. Read existing files before writing code.
- Be concise in output but thorough in reasoning.
- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Test your code before declaring done. Check if there is a per project testing guideline.
- No sycophantic openers or closing fluff.
- Keep solutions simple and direct.
- By default use the github CLI (`gh`) for read only operation unless told otherwise.
- User instructions always override this file.

## Getting your work reviewed

The human reviews your changes in their browser with revue. The page follows /workspace live, so they see your edits
as you save them; you talk to revue with the `revue` CLI from /workspace.

1. Work on a branch and leave your changes unstaged: no `git add`, no commit. The review shows the unstaged
   changes and untracked files, so a staged or committed change drops out of it. Put screenshots and reports in
   `~/out` (see "Handing work and files back" below).
2. End every implementation with a review: run `revue open --no-browser`, which diffs the working tree, put the
   printed link in your message, then run `revue wait --since <cursor> --timeout 60m`, with the cursor from your
   last `revue feedback` or `revue wait` output. Run the wait as a background task the harness tracks, not a
   detached `&`, so you are told when it returns.
3. When the wait returns with a send, run `revue feedback --since <cursor>`. It holds every unresolved thread with
   the quoted lines, and the note of the human's send: it says whether to answer, to change something, or that you
   are done. Exit 3 is a timeout, and exit 1 can mean a newer revue replaced the server: wait again from the same
   cursor.
4. Answer a comment with `revue reply --thread <id> -m "..."` only when it needs an answer: a question, a choice to
   make, or why you did not do something. An instruction you carried out needs no reply. Link evidence in `~/out`
   by its http URL; it renders inline.
5. After code changes, wait again; the human's page updates by itself. Commit only when the human says so.
6. Close a review you no longer need: when the human moves on in the chat, or the send says you are done, stop the
   pending `revue wait` instead of leaving it running.

Never resolve threads yourself; only the human does. `revue --help` lists the rest.

## The machine you are on

@~/AGENTBOX.md
