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
- User instructions always override this file.

## Code Search

Prefer `semble search` over grep/find for exploring code or understanding how something works:

```bash
semble search "authentication flow" ./my-project
semble search "save_pretrained" ./my-project
```

Use `semble find-related` to discover similar code from a prior result:

```bash
semble find-related src/auth.py 42 ./my-project
```

Always start with semble for initial discovery and understanding. Grep will also be needed for confirmation and completeness (e.g. exhaustive literal matches).
