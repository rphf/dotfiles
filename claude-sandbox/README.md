# claude-sandbox

Run Claude Code against any repo, on a throwaway git worktree, inside a Docker
container. Interactive by default; background mode for fire-and-walk-away
agents. Your main worktree and host machine stay untouched.

## Install

```bash
# from ~/dotfiles
stow claude-sandbox

# build the image (one time; rebuild after editing Dockerfile or scripts)
docker build -t claude-sandbox:latest ~/.claude-sandbox

# one-time, global: ignore sandbox worktrees in every repo you use
echo '.worktrees/' >> ~/.config/git/ignore
```

`stow` symlinks:

- `~/.claude-sandbox/` → this package's `.claude-sandbox/` (Dockerfile, scripts)
- `~/.local/bin/claude-sandbox` → this package's wrapper

Ensure `~/.local/bin` is on your `PATH`.

One-time Claude authentication (persisted in the `claude-sandbox-home` Docker
volume, survives image rebuilds):

```bash
claude-sandbox login /login
# follow the browser flow, then /exit
```

## Usage

Two modes, same worktree model:

### Interactive (default) — `claude-sandbox run -n NAME`

Attaches a TTY and drops you into Claude's normal UI. Your terminal is the
Claude session. `/exit` or Ctrl-D ends it; the container auto-removes (safe —
see [State lifecycle](#state-lifecycle)); worktree, branch, and logs persist
for review.

`-n NAME` is **required** — it becomes the session id, branch suffix, and
container name, so every session is findable by meaning:

```bash
cd any-repo
claude-sandbox run -n tip-feature "implement tips per docs/tipping.md"
# → id:        cs-tip-feature
# → branch:    claude-sandbox/cs-tip-feature
# → worktree:  <repo>/.worktrees/cs-tip-feature
# → container: cs-tip-feature
#
# chat, run tools, iterate; /exit when done
# resume/cleanup hints print on exit

claude-sandbox resume cs-tip-feature "also update the changelog"
claude-sandbox cleanup cs-tip-feature
```

Name rules: alphanumeric plus `.`, `_`, `-`. `run` fails cleanly on
collisions — an existing state file or a branch named `claude-sandbox/cs-<name>`.

Start with no initial prompt: `claude-sandbox run -n tip-feature`.
Long prompts from a file: `claude-sandbox run -n tip-feature -f prompt.md`.

### Background — `--bg`

No TTY. Claude runs headless and streams a JSONL to
`~/.local/state/claude-sandbox/logs/<id>.jsonl`. Useful for kicking off several
agents in parallel, or a long autonomous refactor you don't want to babysit.

```bash
claude-sandbox run --bg -n refactor-billing "do the billing refactor"

claude-sandbox list                            # what's running / finished
claude-sandbox logs cs-refactor-billing        # follow assistant output
claude-sandbox logs cs-refactor-billing --net  # follow DNS egress log
claude-sandbox stop cs-refactor-billing        # kill mid-session

# when it finishes, pick up interactively to iterate:
claude-sandbox resume cs-refactor-billing
```

### Pick from fzf instead of typing ids

Omit the id on `resume`, `stop`, `cleanup`, or `review` to get an fzf picker
over your sessions (shows repo, branch, running/stopped marker, start time,
with a JSON preview pane):

```bash
claude-sandbox cleanup       # pick one
claude-sandbox resume        # pick, then chat
claude-sandbox stop          # pick a running one and kill it
```

### Review the agent's work in your main worktree — `review`

When you want to test Claude's branch against your real dev server / editor
layout (which lives in your main worktree), `review` stashes any dirty state
and `git switch`es into the sandbox branch:

```bash
claude-sandbox review                      # fzf picker over claude-sandbox/* branches
claude-sandbox review -n tip-feature       # by name
claude-sandbox review tip-feature          # -n optional
claude-sandbox review cs-tip-feature       # or the cs- prefix
```

What it does, always in the **main** worktree (first entry of
`git worktree list`), regardless of where you invoke it from:

1. `git stash push --include-untracked` if anything is uncommitted.
2. `git switch <branch>`.
3. Prints how to undo (`git switch -` + `git stash pop`).

If the branch is still checked out in its sandbox worktree (you haven't
`cleanup`'d yet), `git switch` refuses; `review` restores the stash and
tells you to cleanup first.

## State lifecycle

Session state lives in three places. Understanding this matters because
**killing a TTY unexpectedly is safe** — everything except the live container
is durable.

| State | Location | On container exit | On `cleanup` |
|---|---|---|---|
| Container (runtime process) | Docker | removed (`--rm`) | removed |
| Conversation `<uuid>.jsonl` | `claude-sandbox-home` volume | kept | removed (this session only) |
| Auth token, shell history, mise toolchains | `claude-sandbox-home` volume | kept | kept (shared across sessions) |
| Worktree files | `<repo>/.worktrees/<id>/` | kept | removed |
| Branch `claude-sandbox/<id>` | host git repo | kept | **kept** (your work to review) |
| `<id>.jsonl` / `.net.log` / `.prompt` / `.session-uuid` | `~/.local/state/claude-sandbox/logs/` | kept | **kept** (audit trail) |
| `<id>.json` session metadata | `~/.local/state/claude-sandbox/state/` | kept | removed |

**Resume after a TTY kill**: close the terminal, kill the container, close
your laptop — all fine. `claude-sandbox resume <id>` spins up a fresh
container on the same volume + worktree + Claude session UUID; Claude reads
its own conversation file and picks up where it stopped.

**The `claude-sandbox-home` volume is shared across every run** (interactive
and background). Sharing is what makes "log in once, keep mise toolchains
forever" work. Each session has its own UUID so conversations stay isolated.
To nuke everything (re-login, reinstall toolchains):
`docker volume rm claude-sandbox-home`.

## Isolation & mounts

**Isolated from the container:**

- `~/.ssh`, `~/Library`, iCloud, Keychain, browser cookies, any host file
  outside the current repo
- The whole macOS userland — Claude sees only a Debian slim environment

**Mounted into the container:**

- Session worktree at `/workspace/<id>` — so `pwd` (and Claude's status line)
  tell you which feature you're on at a glance
- The whole repo root at its host absolute path (same host path inside the
  container, so the worktree's `.git` file — which carries an absolute host
  path — resolves without rewriting). Both mount points are the same
  underlying files; editing through either path hits the same host inode.
- Named volume `claude-sandbox-home` (auth, shell history, mise installs)
- `~/.local/state/claude-sandbox/logs/` at `/logs` (session + DNS logs land on
  the host)

**Not mounted:** your host `~/.gitconfig`. It brings in macOS-only paths
(SSH signing keys under `~/.ssh`, host includes, aliases referencing host
tools) that break inside Linux. Instead, `GIT_CONFIG_GLOBAL` points at a
minimal config baked into the image.

**Opt-in:** SSH agent forwarding. Default off — the agent can't push to
GitHub without you asking:

```bash
CLAUDE_SANDBOX_SSH=1 claude-sandbox run "..."
```

On Docker Desktop for Mac, the wrapper uses
`/run/host-services/ssh-auth.sock`.

## Commit authorship

Commits made inside the sandbox are authored by
`Claude Code <noreply@anthropic.com>` (override with `CS_CLAUDE_NAME` /
`CS_CLAUDE_EMAIL`). A `commit-msg` hook baked into the image auto-appends

```
Co-authored-by: <your host user.name> <your host user.email>
```

to every commit, so the branch carries a clean record of who prompted the
work. This matches the expected workflow: Claude's commits inside the sandbox
are *attributions*, not merge signatures. You review the branch from your main
worktree (`claude-sandbox review`) and land the real merge commit yourself.

The hook uses `git interpret-trailers --if-exists doNothing`, so amending a
commit or re-committing doesn't duplicate the trailer.

## Network

No outbound firewall — any domain is reachable. Every DNS lookup the container
makes is logged to `~/.local/state/claude-sandbox/logs/<id>.net.log` (one
`<timestamp> dns <domain>` line each). Review a few sessions to learn what's
normal (expect `api.anthropic.com`, `registry.npmjs.org`, `github.com`,
whatever package index the project uses). If something surprising shows up,
you can add blocking later.

Host services are reachable at `host.docker.internal:<port>` (your Rails
server, Postgres, Vite, etc.).

## Toolchains inside the sandbox

`mise` is installed system-wide. When Claude `cd`s into a project that pins
Node / Ruby / Python via `.mise.toml` or `.tool-versions`, mise auto-installs
and activates the right version. Installs persist in the `claude-sandbox-home`
volume, so the second session in the same project is instant.

Platform caveat: the container is Linux. iOS Simulator, Xcode, and
macOS-native toolchains don't work inside — run those on the host.

### Gitignored tool configs

`git worktree add` only checks out tracked files. If your project keeps its
tool-version config gitignored (e.g. `.mise.toml` with local-only overrides),
Claude would otherwise land in a worktree with no way to pick the right
Node/Ruby/Python version. `run` ports a small allowlist from the main worktree
after the worktree is created:

```
mise.toml  .tool-versions  .nvmrc  .ruby-version  .python-version  .node-version
```

Sensitive files (`.env`, credentials, `.netrc`, etc.) are intentionally NOT in
this list. If your project needs something else — e.g. a gitignored config or
lockfile that a build step requires — extend the list with `CS_PORT_FILES`
(colon-separated, repo-relative paths):

```bash
CS_PORT_FILES=".env.test:config/bootstrap.local.yml" claude-sandbox run -n foo ...
```

### Seeding prebuilt caches (node_modules, vendor/bundle, …)

By default the wrapper clones `node_modules` and `vendor/bundle` from your
main worktree into the sandbox, so Claude doesn't have to re-run
`yarn install` / `bundle install` on every session. On macOS APFS we use
`cp -cR` (clonefile(2)): instant and copy-on-write — writes inside the
sandbox stay isolated from main. On non-APFS disks we fall back to a plain
copy (slower, still safe). If the directory doesn't exist in main, the clone
is silently skipped — nothing to do.

Extend the default list with `CS_PORT_DIRS` (colon-separated):

```bash
CS_PORT_DIRS=".venv:target/debug" claude-sandbox run -n rust-thing "..."
# clones node_modules + vendor/bundle + .venv + target/debug
```

Caveat: the cache matches your main worktree's `yarn.lock` / `Gemfile.lock`.
If the sandbox branch has different deps, the agent still needs to
`yarn install` (which is now fast since most packages are already present).

### Compiling native dependencies

The base image intentionally omits `build-essential` (gcc/make/g++/libc-dev) —
~250 MB saved. Pure-JS npm packages, Ruby/Python wheels with prebuilt binaries,
etc. all work without it.

If a session hits a package that needs to compile from source (signs:
`node-gyp` errors, `prebuild-install` missing binaries for your arch), add
`build-essential` back to the `apt-get install` line in
`.claude-sandbox/Dockerfile` and rebuild. The claude user inside the
container has narrow sudo (log-egress only), so the agent can't install it
mid-session itself.

## Maintenance

- **Rebuild** after editing Dockerfile or scripts:
  `docker build -t claude-sandbox:latest ~/.claude-sandbox`
- **Stuck session**: `claude-sandbox stop <id>`
- **Shell inside a running session**: `docker exec -it <id> zsh`
- **Prune orphan project dirs** inside the shared volume (sessions that died
  without going through `cleanup`): `claude-sandbox prune`. Leaves active
  sessions and log files alone.
- **Nuke volume state** (re-login, reinstall toolchains):
  `docker volume rm claude-sandbox-home`
- **Nuke runtime logs + state files** on host: `rm -rf ~/.local/state/claude-sandbox`
- **Reclaim Docker build cache** (separate from anything above; affects ALL
  your docker builds, not just claude-sandbox): `docker buildx prune -af`

## Files

Config (version-controlled, stow-linked into `~/`):

- `.claude-sandbox/Dockerfile` — image definition
- `.claude-sandbox/run-agent.sh` — container entrypoint (interactive / `--bg`)
- `.claude-sandbox/log-egress.sh` — passive DNS logger started by the entrypoint
- `.claude-sandbox/commit-msg-hook.sh` — appends `Co-authored-by` trailer
- `.local/bin/claude-sandbox` — host-side CLI
  (`run` / `list` / `logs` / `resume` / `review` / `stop` / `cleanup` / `prune` / `login`)

Runtime state (not version-controlled, machine-local):

- `~/.local/state/claude-sandbox/logs/<id>.jsonl` — Claude session stream (bg)
- `~/.local/state/claude-sandbox/logs/<id>.net.log` — DNS egress log
- `~/.local/state/claude-sandbox/logs/<id>.prompt` — prompt that started it
- `~/.local/state/claude-sandbox/logs/<id>.session-uuid` — UUID used by `resume`
- `~/.local/state/claude-sandbox/state/<id>.json` — session metadata (repo, worktree, branch)

Override via `CS_HOME` and `CS_STATE_HOME`.
