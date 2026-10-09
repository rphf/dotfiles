# Playwright MCP files

- The Playwright MCP can only write inside the repository (its output folder and the repository root). A relative `filename` for a screenshot or snapshot lands in the repository.
- Give screenshots and snapshots a name, then move each file to `~/out` at once. Check `git status` afterwards: no Playwright file may stay in the repository.
- The browser opens at 1920x1080 (`PLAYWRIGHT_MCP_VIEWPORT_SIZE` in `settings.json`). For a mobile check, call `browser_resize` with a phone size such as 390x844, and call it again with 1920x1080 before you go back to desktop.
