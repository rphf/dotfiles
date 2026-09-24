# Playwright MCP files

- The Playwright MCP can only write inside the repository (its output folder and the repository root). A relative `filename` for a screenshot or snapshot lands in the repository.
- Give screenshots and snapshots a name, then move each file to `~/out` at once. Check `git status` afterwards: no Playwright file may stay in the repository.
