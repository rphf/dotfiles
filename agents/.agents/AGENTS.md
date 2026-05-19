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
