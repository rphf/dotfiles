## Source Your Claims

When your answer or your work depends on how something works — a library method, a package version, a config option, an API surface — **go verify it and cite the source.** Don't assume based on training data; look it up so the human can verify your claim independently. You can skip verification for truly stable fundamentals (core language features, standard CLI flags), but default to checking.

- **Verify behavior at the source.** If something doesn't behave as you expected, read its implementation directly (e.g. in `node_modules/`, the package source, or the relevant stdlib) rather than doubling down on assumptions. Report what you found and where (file path + line number, doc URL, etc.).
- **Check current versions and docs.** Never state that version X.Y.Z is "the latest" or that a config option exists based on training data alone. Use Context7, web search, or the package registry to confirm, and include a link or reference.
- **Cite decisions and findings.** When reporting a finding or recommending a course of action, include the path, URL, or command output that supports it. The human should be able to follow your references and reach the same conclusion independently.
- **Default to primary sources.** The priority order is: read the actual code/config > query official docs (Context7, web search) > fall back to training knowledge. If you must fall back, say so explicitly.

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
