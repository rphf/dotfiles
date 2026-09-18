# home

What every agent finds in its home directory. `agentbox up` mounts this tree read-only at `/agent-home` in the
container and overlays it onto `/home/agent`: directories are merged, files are linked in place. So an agent reads
this config live and cannot change it, while its own state (`.claude/projects`, credentials, shell history) lives
beside it in the agent's home volume. Delete a file here and its link disappears at the next `up`.

```
.zshrc                   shell for `agentbox sh`, small on purpose: vi mode with cursor shapes, history, a prompt
                         that names the sandbox. A plugin manager belongs on your machine, not in a container.
.claude/CLAUDE.md        instructions every agent gets, ending with the import of the generated ~/AGENTBOX.md
.claude/settings.json    model, and how much an agent may do without asking: in a sandbox, everything
.claude/skills/          procedures worth repeating, loaded by name at session start
.config/lazygit/         lazygit, same theme and delta renderer as the Mac
```

Real files only, no symlinks pointing outside this directory: this tree is the only thing from the host an agent
can read, and a symlink out of it would either dangle or widen that.

Seeded 2026-09-17 from the `agents` and `claude` packages of `~/dotfiles`, deliberately as a copy rather than a
link: agents should be free to differ from the Mac setup. Keep the two in sync by hand.
